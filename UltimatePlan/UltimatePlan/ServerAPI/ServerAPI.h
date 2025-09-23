//
//  ServerAPI.h
//  ThinAir
//
//  Created by yt on 06/09/22.
//

#import <Foundation/Foundation.h>
#import "IMResult.h"
#import "Account.h"

@class BinaryCert;

typedef void(^ServerAPIResponseHandler)(id rspObj, NSError *err);

@interface ServerAPI : NSObject

- (void)fetchAccount:(NSString *)sn withCallback:(ServerAPIResponseHandler)cb;

- (void)reportImRegFatal:(NSString *)sn withCalback:(ServerAPIResponseHandler)cb;

- (void)reportImRegSucc:(NSString *)sn cert:(BinaryCert *)bc withCalback:(ServerAPIResponseHandler)cb;

- (void)fetchIMTask:(NSString *)sn withCallback:(ServerAPIResponseHandler)cb;

- (void)reportIMTaskResult:(IMResult *)r withCallback:(ServerAPIResponseHandler)cb;

- (void)reportAccountFatal:(NSString *)email withCallback:(ServerAPIResponseHandler)cb;

- (void)reportIMFatal:(NSString *)sn withCallback:(ServerAPIResponseHandler)cb;

@end

