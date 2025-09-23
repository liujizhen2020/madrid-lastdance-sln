//
//  StateView.h
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "emu_defs.h"

@interface StateView : NSView

+ (CGFloat)fixedWidth;
+ (CGFloat)fixedHeight;

- (void)setTitle:(NSString *)title;

- (void)setProgress:(int)progress;

- (void)setQueryResult:(int)qr;

- (void)setSendResult:(int)sr;

@end
