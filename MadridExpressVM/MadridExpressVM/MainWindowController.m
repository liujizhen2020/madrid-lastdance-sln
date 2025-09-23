//
//  MainWindowController.m
//  AppleEmulator
//
//  Created by boss on 08/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "MainWindowController.h"
#import "UIDefs.h"
#import "StateView.h"
#import "GameMaster/GameMaster.h"
#import "../Sources/BinaryCert.h"

#define UI_INFO_BOX_MIN_WIDTH       700
#define UI_INFO_BOX_MIN_HEIGHT      100
#define UI_ITEM_LAYOUT_GAP          5

@interface MainWindowController ()<NSWindowDelegate, GameMasterUIDelegate>
// ui
@property (weak) IBOutlet NSTextField *succCountLabel;
@property (weak) IBOutlet NSComboBox *emuCountSelect;
@property (weak) IBOutlet NSButton *pauseBtn;
@property (weak) IBOutlet NSView *retContainer;
@property (strong, nonatomic) NSArray<NSView *> *retLabels;
@property (assign, nonatomic) NSUInteger retCount;
@property (strong, nonatomic) NSDateFormatter *df;

// logic
@property (strong, nonatomic) NSDate *startDate;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDict objectForKey:@"APP_NAME"];
    self.window.title = appName;
    self.window.delegate = self;
    
    // check server root url ok?
    NSString *serverRoot = [infoDict objectForKey:@"APP_SERVER_ROOT"];
    NSError *err = [[GameMaster sharedInstance] useServerRootURL:serverRoot];
    if (err != nil){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _showAlert:@"APP_SERVER_ROOT 配置不正确！"];
            exit(1);
        });
    }
    
    // reset emulators count
    if ([UIDefs emuCount] == 0){
        [UIDefs setEmuCount:100];
    }
    self.emuCountSelect.stringValue = [NSString stringWithFormat:@"%d", [UIDefs emuCount]];
    
    self.retLabels = [self.retContainer subviews];
    for (NSTextField *tf in self.retLabels){
        tf.stringValue = @"";
    }
    self.retCount = [self.retLabels count];
    self.df = [[NSDateFormatter alloc] init];
    [self.df setDateFormat:@"HH:mm:ss "];
    
    [GameMaster sharedInstance].uiDelegate = self;
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(_forverLoop) userInfo:nil repeats:YES];
}

- (void)_appendJobResult:(NSString *)retDesc {
    if (self.retCount == 0){
        NSLog(@"_appendJobResult Error... no ret labels");
        return;
    }
    for (NSUInteger i=self.retCount-1; i>0; i--){
        NSTextField *high = (NSTextField *)[self.retLabels objectAtIndex:i-1];
        NSTextField *low = (NSTextField *)[self.retLabels objectAtIndex:i];
        if (high.stringValue == nil || [high.stringValue length] == 0){
            continue;
        }
        low.stringValue = high.stringValue;
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@", [self.df stringFromDate:[NSDate date]], retDesc];
    NSTextField *tf = (NSTextField *)[self.retLabels objectAtIndex:0];
    tf.stringValue = msg;
}


#pragma mark - Events

- (IBAction)_doSelectNewEmuCount:(id)sender {
    NSString *val = self.emuCountSelect.objectValueOfSelectedItem;
    if (val == nil){
        //NSLog(@"ui: SKIP auto select when ui init");
        return;
    }
    NSLog(@"ui: user select new emu count %@", val);
    int ec = [val intValue];
    [[GameMaster sharedInstance] limitEmuCount:ec];
    [UIDefs setEmuCount:ec];
}

- (IBAction)_doTogglePauseState:(id)sender {
    if ([GameMaster sharedInstance].isPaused){
        // go on
        [[GameMaster sharedInstance] limitEmuCount:[UIDefs emuCount]];
        [[GameMaster sharedInstance] startBattle];
        self.pauseBtn.title = @"= 暂停 =";
        self.startDate = [NSDate date];
    }else{
        // hand on
        [[GameMaster sharedInstance] makePeace];
        self.pauseBtn.title = @"#启动发送#";
    }
}

#pragma mark - Loop

- (void)_forverLoop {
    if ([GameMaster sharedInstance].isPaused){
        return;
    }
    
    // ui update
    self.succCountLabel.stringValue = [NSString stringWithFormat:@"%ld", [GameMaster sharedInstance].sentCount];
}

- (void)_displayTotalSentCount {
    self.succCountLabel.stringValue = [NSString stringWithFormat:@"%ld", [GameMaster sharedInstance].sentCount];
}



- (void)_showAlert:(NSString *)msg {
    NSAlert *a = [NSAlert new];
    a.messageText = msg;
    [a runModal];
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(NSWindow *)sender {
    NSAlert *exitAlert = [[NSAlert alloc] init];
    exitAlert.alertStyle = NSAlertStyleWarning;
    exitAlert.messageText = @"老板，不玩了？";
    [exitAlert addButtonWithTitle:@"取消"];
    [exitAlert addButtonWithTitle:@"确定"];
    NSModalResponse ret = [exitAlert runModal];
    if (ret == NSAlertFirstButtonReturn){
        return NO;
    }
    [[NSApplication sharedApplication] terminate:self];
    return YES;
}

#pragma mark - GameMasterUIDelegate

- (void)gameMasterDidUpdateEmulator:(Emulator *)emu {
    // update total count
    [self _displayTotalSentCount];
    
    NSString *msg = nil;
    switch (emu.progress){
        case EMU_PROGRESS_QUERYING:
            msg = [NSString stringWithFormat:@"%@ %@ 扫描号码...", emu.identifier, emu.cert.email];
            break;
            
        case EMU_PROGRESS_CONNECTING:
            msg = [NSString stringWithFormat:@"%@ %@ 扫描号码...可发 %d 个号码", emu.identifier, emu.cert.email, emu.queryCount];
            break;
            
        case EMU_PROGRESS_WILL_RESET:
            msg = [NSString stringWithFormat:@"%@ %@ 发送完成...已发送 %d 条 ✅ ", emu.identifier, emu.cert.email, emu.sendCount];
            break;
            
        case EMU_PROGRESS_QUERY_FAIL:
            msg = [NSString stringWithFormat:@"%@ %@ 扫描号码...扫描失败 😭 ", emu.identifier, emu.cert.email];
            break;
    }
    
    if (msg != nil){
        [self _appendJobResult:msg];
    }
}

@end
