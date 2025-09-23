//
//  NSData+FTServices.h
//  GodDelivery
//
//  Created by tt on 2018/7/23.
//  Copyright © 2018 Apple Hacking Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(IMFoundation)

// Image: /System/Library/PrivateFrameworks/IMFoundation.framework/IMFoundation

//+ (id)__imDataWithHexString:(id)arg1;
//+ (id)__imDataWithRandomBytes:(unsigned int)arg1;

- (id)SHA1Data;
- (id)SHA1HexString;
//- (id)__imHexString;
//- (id)__imHexStringOfBytes:(char *)arg1 withLength:(unsigned int)arg2;

@end
