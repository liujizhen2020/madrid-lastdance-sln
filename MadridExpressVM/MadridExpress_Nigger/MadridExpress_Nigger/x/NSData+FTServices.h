//
//  NSData+FTServices.h
//  GodDelivery
//
//  Created by tt on 2018/7/23.
//  Copyright © 2018 Apple Hacking Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(FTServices)

// Image: /System/Library/PrivateFrameworks/FTServices.framework/FTServices

- (id)_FTCopyGzippedData;
- (id)_FTDecompressData;
- (id)_FTOptionallyDecompressData;
- (id)_FTStringFromBaseData;

@end
