//
//  SecAuth.h
//  UltimatePlan
//
//  Created by yt on 29/08/23.
//

#import <Foundation/Foundation.h>
#import "MadridConfig.h"

typedef void(^SecAuthCallback)(NSError *);

@interface SecAuth : NSObject

- (instancetype)initWithConfig:(MadridConfig *)cfg;

- (void)start:(SecAuthCallback)cb;

@end

