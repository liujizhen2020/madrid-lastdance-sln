//
//  LegacySealer.m
//  FireFighter
//
//  Created by zebra on 2021/7/29.
//

#import "NBLegacySealer.h"
#import "fishhook.h"
#import <Security/Security.h>
#import <objc/runtime.h>
#import "../../Sources/BinaryCert.h"
#import "x/IDSMPPublicLegacyIdentity.h"
#import "x/IDSMPFullLegacyIdentity.h"
#import "util.h"

#define REF_EC_PRIV_KEY     @"ec-priv-key"
#define REF_RSA_PRIV_KEY    @"rsa-priv-key"

@interface NBLegacySealer()

@property (strong, nonatomic) BinaryCert *cert;

+ (instancetype)_sharedInstance;
+ (SecKeyRef)ecPrivKey;
+ (SecKeyRef)rsaPrivKey;

@end

//OSStatus SecItemCopyMatching(CFDictionaryRef query, CFTypeRef  _Nullable *result);
static OSStatus (*orig_SecItemCopyMatching)(CFDictionaryRef, CFTypeRef*);

OSStatus my_SecItemCopyMatching(CFDictionaryRef query, CFTypeRef  _Nullable *result){
    NSDictionary *qdict = (__bridge NSDictionary *)query;
    //NSLog(@"my_SecItemCopyMatching dict %@", qdict);
    NSString *cls = [qdict objectForKey:@"class"];
    if ([@"keys" isEqualToString:cls]){
        NSData *refKeyData = [qdict objectForKey:@"v_PersistentRef"];
        NSString *refKey = [[NSString alloc] initWithData:refKeyData encoding:NSUTF8StringEncoding];
        if ([refKey isEqualToString:REF_EC_PRIV_KEY]){
            SecKeyRef ecKey = [NBLegacySealer ecPrivKey];
            if (ecKey != NULL){
                *result = ecKey;
                return 0;
            }
            
        }else if ([refKey isEqualToString:REF_RSA_PRIV_KEY]){
            SecKeyRef rsaKey = [NBLegacySealer rsaPrivKey];
            if (rsaKey != NULL){
                *result = rsaKey;
                return 0;
            }
        }
        return -4444;
    }
    
    
    return orig_SecItemCopyMatching(query, result);
}



@implementation NBLegacySealer

+ (void)initialize {
    rebind_symbols((struct rebinding[1]){{"SecItemCopyMatching", my_SecItemCopyMatching, (void *)&orig_SecItemCopyMatching}}, 1);
    
    load_binary_ids();
}


+ (NSData *)sealMessage:(NSData *)msgData withPublicIdentity:(NSData *)pubMPData andBinaryCert:(BinaryCert *)bc {
    NSError *err = nil;
    
    IDSMPPublicLegacyIdentity *pubIdent = [objc_getClass("IDSMPPublicLegacyIdentity") identityWithData:pubMPData error:&err];
    //NSLog(@"pubIdent %@", pubIdent);
    if (pubIdent == nil){
        NSLog(@"ERROR: IDSMPPublicLegacyIdentity -identityWithData:error:");
        NSLog(@"err %@", err);
        return nil;
    }
    
    [NBLegacySealer _sharedInstance].cert = bc;
    
    IDSMPFullLegacyIdentity *fullIdent = nil;
    // create from data
    NSData *fullMPData = [NBLegacySealer _generateFullMPDataFromBinaryCert:bc];
    //NSLog(@"fullMPData %@", fullMPData);
    if (fullMPData == nil){
        NSLog(@"ERROR: _generateFullMPDataFromBlob return nil");
        return nil;
    }
    
    fullIdent = [objc_getClass("IDSMPFullLegacyIdentity") identityWithData:fullMPData error:&err];
    //NSLog(@"fullIdent %@", fullIdent);
    if (fullIdent == nil){
        NSLog(@"ERROR: IDSMPFullLegacyIdentity -identityWithData:error:");
        NSLog(@"err %@", err);
        return nil;
    }

    NSData *encData = [pubIdent signAndProtectData:msgData withSigner:fullIdent error:&err];
    return encData;
}


+ (NSData *)_generateFullMPDataFromBinaryCert:(BinaryCert *)cert {
    // v=2
    // len,ec-priv-key-persistant
    // len,ec-pub
    // len,rsa-priv-key-persistant
    // len,rsa-pub
    NSMutableData *fmpData = [NSMutableData data];
    UInt8 ver = 2;
    [fmpData appendBytes:&ver length:1];
    
    // ec-priv
    NSData *ecRefData = [REF_EC_PRIV_KEY dataUsingEncoding:NSUTF8StringEncoding];
    UInt16 ecRefLen = CFSwapInt16HostToBig([ecRefData length]);
    [fmpData appendBytes:&ecRefLen length:sizeof(UInt16)];
    [fmpData appendData:ecRefData];
    
    // ec-pub
    UInt16 ecPubLen = CFSwapInt16HostToBig([cert.ecPubKeyData length]);
    [fmpData appendBytes:&ecPubLen length:sizeof(UInt16)];
    [fmpData appendData:cert.ecPubKeyData];
    
    
    // rsa-priv
    NSData *rsaRefData = [REF_RSA_PRIV_KEY dataUsingEncoding:NSUTF8StringEncoding];
    UInt16 rsaRefLen = CFSwapInt16HostToBig([rsaRefData length]);
    [fmpData appendBytes:&rsaRefLen length:sizeof(UInt16)];
    [fmpData appendData:rsaRefData];
    
    // rsa-pub
    UInt16 rsaPubLen = CFSwapInt16HostToBig([cert.rsaPubKeyData length]);
    [fmpData appendBytes:&rsaPubLen length:sizeof(UInt16)];
    [fmpData appendData:cert.rsaPubKeyData];
    
    //NSLog(@"full mp data (%ld bytes) %@", (long)[fmpData length], fmpData);
    return fmpData;
}

+ (SecKeyRef)ecPrivKey {
    NSData *keyData = [NBLegacySealer _sharedInstance].cert.ecPrivKeyData;
    //NSLog(@"ecPrivKey %@", keyData);
    if (keyData == nil){
        return NULL;
    }
    
    CFErrorRef cfErr;
    NSDictionary *ecPrivConf = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom,
                                  (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate };
    SecKeyRef ecPrivKey = SecKeyCreateWithData((__bridge CFDataRef)keyData, (__bridge CFDictionaryRef)ecPrivConf, &cfErr);
    if (ecPrivKey == NULL){
        return NULL;
    }
    //NSLog(@"ecPrivKey %@", ecPrivKey);
    return ecPrivKey;
}

+ (SecKeyRef)rsaPrivKey {
    NSData *keyData = [NBLegacySealer _sharedInstance].cert.rsaPrivKeyData;
    //NSLog(@"rsaPrivKey %@", keyData);
    if (keyData == nil){
        return NULL;
    }
    
    CFErrorRef cfErr;
    NSDictionary *rsaPrivConf = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                                   (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                                   (id)kSecAttrKeySizeInBits: @(1280),
                                   };
    SecKeyRef rsaPrivKey = SecKeyCreateWithData((__bridge CFDataRef)keyData, (__bridge CFDictionaryRef)rsaPrivConf, &cfErr);
    if (rsaPrivKey == NULL){
        return NULL;
    }
    //NSLog(@"rsaPrivKey %@", rsaPrivKey);
    return rsaPrivKey;
}

+ (instancetype)_sharedInstance {
    static NBLegacySealer *sealer_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sealer_ = [NBLegacySealer new];
    });
    return sealer_;
}


@end
