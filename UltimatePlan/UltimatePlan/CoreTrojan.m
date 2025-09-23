//
//  CoreTrojan.m
//  UltimatePlan
//
//  Created by yt on 18/08/23.
//

#import "CoreTrojan.h"

#define TROJAN_HACK_FLAG @"/Library/CoreTrojan/hacked_by_CoreTrojan"

@implementation CoreTrojan

+ (BOOL)checkTrojanHackedFlag {
    return [[NSFileManager defaultManager] fileExistsAtPath:TROJAN_HACK_FLAG];
}

@end
