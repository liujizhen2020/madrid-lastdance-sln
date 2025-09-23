//
//  RoyalMadrid.h
//  ThinAir
//
//  Created by yt on 07/09/22.
//

#import <Foundation/Foundation.h>
#import "MadridConfig.h"

extern NSInteger GSA_BAD_ACCOUNT;

typedef void(^MadridCallback)(NSError *err);

@interface RoyalMadrid : NSObject

+ (instancetype)madridWithConfig:(MadridConfig *)cfg;

- (void)runAll:(MadridCallback)cb;


//  steps
- (void)doGsaLogin:(MadridCallback)cb;

- (void)doLoginDelegate:(MadridCallback)cb;

- (void)registerAccount:(MadridCallback)cb;


@end

