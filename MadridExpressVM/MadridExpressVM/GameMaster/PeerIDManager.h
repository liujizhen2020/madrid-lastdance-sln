//
//  PeerIDManager.h
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QueryResultItem.h"

extern NSString *kQueryErrorNetwork;
extern NSString *kQueryErrorBadCode;

@class BinaryCert;

typedef void(^PeerQueryHandler)(NSArray *results, NSError *err);

@interface PeerIDManager : NSObject

+ (void)queryTargets:(NSArray *)targets withBinaryCert:(BinaryCert *)bc completeHandler:(PeerQueryHandler)handler;

+ (NSString *)formatTarget:(NSString *)target;
+ (NSString *)originTarget:(NSString *)target;

@end

