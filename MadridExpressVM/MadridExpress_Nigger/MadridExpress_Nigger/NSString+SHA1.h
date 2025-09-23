//
//  NSString_SHA1.h
//  MadridExpress_Nigger
//
//  Created by yt on 15/09/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString(SHA1)

+ (NSString *)sha1:(NSString *)input;

+ (NSData *)sha1Data:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
