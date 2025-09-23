//
//  SpeedConfig.m
//  MadridExpress_Nigger
//
//  Created by yt on 18/07/22.
//

#import "SpeedConfig.h"

@implementation SpeedConfig

+ (instancetype)defaultConfig {
    SpeedConfig *cfg =  [SpeedConfig new];
    cfg.sendInterval = 3;
    cfg.finishWait = 120;
    cfg.singleWaitMax = 60;
    return cfg;
}

@end
