//
//  StateView.m
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "StateView.h"

@interface StateView() {
    NSTextField *_titleField;
    NSTextField *_statusField;
    NSTextField *_queryResultField;
    NSTextField *_sendResultField;
    NSLevelIndicator *_progressIndicator;
}

@end

@implementation StateView

+ (CGFloat)fixedWidth {
    return 110.0f;
}

+ (CGFloat)fixedHeight {
    return 50.0f;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    CGFloat w = [StateView fixedWidth];
    //CGFloat h = [StateView fixedHeight];
    
    _titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 30, 40, 20)];
    _titleField.editable = NO;
    _titleField.bordered = NO;
    _titleField.alignment = NSTextAlignmentLeft;
    _titleField.font = [NSFont systemFontOfSize:10];
    _titleField.textColor = [NSColor grayColor];
    [self addSubview:_titleField];
    
    _statusField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 10, 50, 22)];
    _statusField.enabled = NO;
    _statusField.bordered = NO;
    _statusField.alignment = NSTextAlignmentLeft;
    _statusField.font = [NSFont systemFontOfSize:12];
    _statusField.textColor = [NSColor blackColor];
    [self addSubview:_statusField];
    
    _queryResultField = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 30, w-50, 20)];
    _queryResultField.enabled = NO;
    _queryResultField.bordered = NO;
    _queryResultField.alignment = NSTextAlignmentCenter;
    _queryResultField.font = [NSFont systemFontOfSize:14];
    _queryResultField.textColor = [NSColor blackColor];
    [self addSubview:_queryResultField];

    
    _sendResultField = [[NSTextField alloc] initWithFrame:NSMakeRect(50, 10, w-50, 20)];
    _sendResultField.enabled = NO;
    _sendResultField.bordered = NO;
    _sendResultField.alignment = NSTextAlignmentCenter;
    _sendResultField.font = [NSFont systemFontOfSize:14];
    _sendResultField.textColor = [NSColor redColor];
    [self addSubview:_sendResultField];


    _progressIndicator = [[NSLevelIndicator alloc] initWithFrame:NSMakeRect(0, 0, 110, 8)];
    _progressIndicator.maxValue = 100;
    _progressIndicator.minValue = 0;
    _progressIndicator.warningValue = 50;
    _progressIndicator.criticalValue = 60;
    _progressIndicator.fillColor = [NSColor greenColor];
    _progressIndicator.warningFillColor = [NSColor orangeColor];
    _progressIndicator.criticalFillColor = [NSColor purpleColor];
    [self addSubview:_progressIndicator];
    
    [self setProgress:EMU_PROGRESS_SLEEPING];
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


- (void)setTitle:(NSString *)title {
    _titleField.stringValue = title;
}

- (void)setProgress:(int)progress {
    switch (progress) {
        case EMU_PROGRESS_SLEEPING:
        {
            _progressIndicator.doubleValue = 0;
            _statusField.stringValue = @"💤待命";
            _queryResultField.hidden = YES;
            _sendResultField.hidden = YES;
        }
            break;
        case EMU_PROGRESS_QUERYING:
        {
            _progressIndicator.doubleValue = 15;
            _statusField.stringValue = @"🔎扫号";
        }
            break;
            
        case EMU_PROGRESS_CONNECTING:
        {
            _progressIndicator.doubleValue = 30;
            _statusField.stringValue = @"🔗连接";
        }
            break;
            
        case EMU_PROGRESS_SENDING:
        {
            _progressIndicator.doubleValue = 55; // warning 50
            _statusField.stringValue = @"✈️发送";
        }
            break;
            
        case EMU_PROGRESS_CONFIRMING:
        {
            _progressIndicator.doubleValue = 90; // critical 60
            _statusField.stringValue = @"⏰确认";
        }
            break;
        default:
            break;
    }
}

- (void)setQueryResult:(int)qr {
    _queryResultField.hidden = NO;
    _queryResultField.stringValue = [NSString stringWithFormat:@"🔑 %d", qr];
    
}

- (void)setSendResult:(int)sr {
    _sendResultField.hidden = NO;
    _sendResultField.stringValue = [NSString stringWithFormat:@"🎉 %d", sr];
}

@end
