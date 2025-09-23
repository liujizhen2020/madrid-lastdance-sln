//
//  NKURLSession.h
//  NightKing
//
//  Created by tt on 2018/9/13.
//  Copyright © 2018 NightKing Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NKSessionManager : NSObject<NSURLSessionDelegate>

+ (instancetype)shared;

- (NSURLSession *)defaultSession;

- (NSURLSession *)ephemeralSession;

@end
