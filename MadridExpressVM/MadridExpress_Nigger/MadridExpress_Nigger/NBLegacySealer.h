//
//  LegacySealer.h
//  FireFighter
//
//  Created by zebra on 2021/7/29.
//

#import <Foundation/Foundation.h>

@class BinaryCert;

@interface NBLegacySealer : NSObject

+ (NSData *)sealMessage:(NSData *)msgData withPublicIdentity:(NSData *)pubMPData andBinaryCert:(BinaryCert *)bc;

@end
