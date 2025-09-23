//
//  UIDefs.m
//  AppleEmulator
//
//  Created by boss on 08/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "UIDefs.h"

@implementation UIDefs

+ (int)emuCount {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSNumber *x = [defs objectForKey:@"emu_count"];
    return [x intValue];
}

+ (void)setEmuCount:(int)pc {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:@(pc) forKey:@"emu_count"];
    [defs synchronize];
}


@end
