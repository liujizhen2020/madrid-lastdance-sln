//
//  PeerIDManager.m
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "PeerIDManager.h"
#import "mp.h"
#import "../../Sources/BinaryCert.h"
#import "./x/NSData+FTServices.h"
#import "./x/NSData+IMFoundation.h"
#import <Security/Security.h>

NSString *kQueryErrorNetwork = @"QUERY_ERR_NETWORK";
NSString *kQueryErrorBadCode = @"QUERY_ERR_BAD_CODE";

static NSDictionary* genQueryHeaders(BinaryCert *bc, NSData *body);
static NSData* _genBodyData(NSArray *targets) __attribute__ ((always_inline));
static NSData* _queryCalcSHA1(BinaryCert *bc, NSData *bodyData, NSData *nonceData) __attribute__ ((always_inline));

@implementation PeerIDManager

+ (void)queryTargets:(NSArray *)targets withBinaryCert:(BinaryCert *)bc completeHandler:(PeerQueryHandler)handler {
    //NSLog(@"[id-query] start to query %ld targets", (long)[targets count]);
    // format targets
    NSMutableArray *uris = [NSMutableArray arrayWithCapacity:[targets count]];
    for (NSString *t in targets){
        NSString *ft = [PeerIDManager formatTarget:t];
        if (ft != nil){
            [uris addObject:ft];
        }
    }
    
    
    // send query request
    NSData *body = _genBodyData(uris);
    if (body == nil){
        NSError *bodyErr = [NSError errorWithDomain:@"ERR_GEN_BODY_DATA" code:441 userInfo:nil];
        handler(nil,bodyErr);
        return;
    }
    NSDictionary *headers = nil;
    @try {
        headers = genQueryHeaders(bc, body);
    } @catch (NSException *exception) {
        NSLog(@"[id-query] CATCH %@", exception);
        headers = nil;
    } @finally {
        if (headers == nil){
            NSError *headersErr = [NSError errorWithDomain:@"ERR_QUERY_HEADERS" code:442 userInfo:nil];
            handler(nil,headersErr);
            return;
        }
    }
    
    NSURL *qURL = [NSURL URLWithString:@"https://query.ess.apple.com/WebObjects/QueryService.woa/wa/query"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:qURL];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:body];
    [req setAllHTTPHeaderFields:headers];
    [req setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [req setValue:@"com.apple.madrid-lookup [Mac OS X,10.14,18A391,MacBookPro11,4]" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"application/x-apple-plist" forHTTPHeaderField:@"Content-Type"];
    //NSLog(@"[id query] dump req: \nheaders: \n %@ \nbody: \n %@", req.allHTTPHeaderFields, req.HTTPBody);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err = nil;
        if (error != nil){
            err = [NSError errorWithDomain:kQueryErrorNetwork code:400 userInfo:nil];
            handler(nil, err);
            return;
        }
        NSDictionary *rspDict = [NSPropertyListSerialization propertyListWithData:data options:0 format:nil error:nil];
        NSLog(@"[id-query] dict %@", rspDict);
        int retCode = [rspDict[@"status"] intValue];
        if (retCode != 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                // 5032
                NSError *badErr = [NSError errorWithDomain:kQueryErrorBadCode code:retCode userInfo:nil];
                handler(nil, badErr);
            });
            return;
        }
        
        NSDictionary *retDict = rspDict[@"results"];
        NSArray *retTargets = [retDict allKeys];
        NSMutableArray *mGoodTargets = [NSMutableArray array];
        for (NSString *rt in retTargets){
            NSDictionary *ret = [retDict objectForKey:rt];
            if (!ret){
                continue;
            }
            NSArray *identities = [ret objectForKey:@"identities"];
            if ([identities count] == 0){
                continue;
            }
            NSDictionary *identity = [identities firstObject];
            if (identity){
                //NSLog(@"* good target %@", rt);
                QueryResultItem *q = [QueryResultItem new];
                q.target = rt;
                q.pushTokenData = identity[@"push-token"];
                q.sessionTokenData = identity[@"session-token"];
                q.publicMPData = identity[@"client-data"][@"public-message-identity-key"];
                [mGoodTargets addObject:q];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            handler(mGoodTargets, nil);
        });
    }];
    [task resume];
    
}


+ (NSString *)formatTarget:(NSString *)target {
    NSString *uri = nil;
    do {
        if ([target containsString:@"@"]){
            uri = [NSString stringWithFormat:@"mailto:%@", [target lowercaseString]];
            break;
        }
        if ([target length] < 5){
            break;
        }
        if ([target hasPrefix:@"+"]){
            uri = [NSString stringWithFormat:@"tel:%@", target];
        }
        break;
    } while (1);
    return uri;
}

+ (NSString *)originTarget:(NSString *)target {
    NSString *uri = nil;
    do {
        if ([target containsString:@"tel:"]){
            uri = [target stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
            break;
        }
        if ([target containsString:@"mailto:"]){
            uri = [target stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
            break;
        }
        uri = target;
        break;
    } while (1);
    return uri;
}


@end


NSDictionary*
genQueryHeaders(BinaryCert *bc, NSData *body) {
    CFErrorRef err;
    NSDictionary *keyOpts = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                              (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                              (id)kSecAttrKeySizeInBits: @(2048) };
    
    SecKeyRef privKey = SecKeyCreateFromData((__bridge CFDictionaryRef)keyOpts, (__bridge CFDataRef)[bc idPrivKeyData], &err);
    if (privKey == NULL){
        NSLog(@"[id-query] can not create priv key, box %@", bc);
        @throw [NSException exceptionWithName:@"ERR_CREATE_QUERY_PRIV_KEY" reason:@"ERR_CREATE_QUERY_PRIV_KEY" userInfo:nil];
        return nil;
    }
    NSData *nonce = _genNonce(YES);
    NSData *sha1Data = _queryCalcSHA1(bc, body, nonce);
    NSData *sig = _calcSig(privKey, sha1Data);
    CFRelease(privKey);
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:5];
    headers[@"x-push-token"] = [bc.pushTokenData base64EncodedStringWithOptions:0];
    headers[@"x-id-self-uri"] = [PeerIDManager formatTarget:bc.email];
    headers[@"x-id-nonce"] = [nonce base64EncodedStringWithOptions:0];
    headers[@"x-id-sig"] = [sig base64EncodedStringWithOptions:0];
    headers[@"x-id-cert"] = [bc.idCertData base64EncodedStringWithOptions:0];
    return headers;
}


NSData*
_genBodyData(NSArray *targets)
{
    NSDictionary *bodyDict = @{ @"uris": targets };
    NSError *err;
    NSData *bodyData = [NSPropertyListSerialization dataWithPropertyList:bodyDict format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
    if (err){
        return nil;
    }
    if (bodyData == nil){
        return nil;
    }
    return [bodyData _FTCopyGzippedData];
}


NSData*
_queryCalcSHA1(BinaryCert *bc, NSData *bodyData, NSData *nonceData)
{
    NSMutableData *baseData = [NSMutableData data];
    // base: nonce
    [baseData appendData:nonceData];
    // base: bag key
    NSString *bagKey = @"id-query";
    NSData *bagKeyData = [bagKey dataUsingEncoding:NSUTF8StringEncoding];
    uint32_t bagKeyLen = (uint32_t)[bagKeyData length];
    bagKeyLen = CFSwapInt32HostToBig(bagKeyLen);
    [baseData appendBytes:&bagKeyLen length:0x4];
    [baseData appendData:bagKeyData];
    // base: query-string
    uint32_t queryLen = (uint32_t)0x0;
    [baseData appendBytes:&queryLen length:0x4];
    // base: body
    uint32_t bodyLen = (uint32_t)[bodyData length];
    bodyLen = CFSwapInt32HostToBig(bodyLen);
    [baseData appendBytes:&bodyLen length:0x4];
    [baseData appendData:bodyData];
    // base: push token
    uint32_t pushTokenLen = (uint32_t)[bc.pushTokenData length];
    pushTokenLen = CFSwapInt32HostToBig(pushTokenLen);
    [baseData appendBytes:&pushTokenLen length:0x4];
    [baseData appendData:bc.pushTokenData];
    return [baseData SHA1Data];
}
