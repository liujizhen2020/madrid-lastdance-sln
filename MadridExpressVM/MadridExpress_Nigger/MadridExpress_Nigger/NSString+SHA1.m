//
//  NSString_SHA1.m
//  MadridExpress_Nigger
//
//  Created by yt on 15/09/22.
//

#import "NSString+SHA1.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString(SHA1)


+ (NSString *)sha1:(NSString *)input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (NSData *)sha1Data:(NSString *)input {
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSData *hashData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    NSLog(@"sha1: %@ --> %@", input, hashData);
    return hashData;
}

@end
