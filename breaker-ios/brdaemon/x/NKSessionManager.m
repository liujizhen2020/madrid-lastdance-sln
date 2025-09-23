//
//  NKURLSession.m
//  NightKing
//
//  Created by tt on 2018/9/13.
//  Copyright © 2018 NightKing Team. All rights reserved.
//

#import "NKSessionManager.h"

@interface NKSessionManager()

@property (retain, nonatomic) NSURLSession *session;

@end

@implementation NKSessionManager {
    NSOperationQueue *q;
}

+ (instancetype)shared {
    static NKSessionManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NKSessionManager alloc] init];
        _instance->q = [[NSOperationQueue alloc] init];
    });
    return _instance;
}

- (NSURLSession *)defaultSession {
    if (self.session == nil){
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.timeoutIntervalForRequest = 30;
        self.session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:q];
    }
    return self.session;
}

- (NSURLSession *)ephemeralSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.timeoutIntervalForRequest = 30;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:q];
    return session;
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:trust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}



@end
