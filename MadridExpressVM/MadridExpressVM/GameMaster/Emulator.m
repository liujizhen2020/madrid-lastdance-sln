//
//  Emulator.m
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "Emulator.h"
#import "PeerIDManager.h"
#import "../ServerAPI/SendResult.h"
#import "../../Sources/BinaryCert.h"
#import "../../worker_defs.h"
#import "../../Vendor/NSData+FastHex.h"

#define MAX_QUERY_RETRY     2

@interface Emulator()

@property (weak, nonatomic) id<EmulatorDelegate> deledate;
@property (assign, nonatomic) int progress;
@property (assign, nonatomic) int queryCount;
@property (assign, nonatomic) int sendCount;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *msgID;
@property (strong, nonatomic) NSString *msgText;
@property (strong, nonatomic) SendResult *sendResult;
@property (assign, nonatomic) int masterPort;

// query
@property (strong, nonatomic) NSMutableArray *mQueryResults;
@property (strong, nonatomic) NSMutableSet<NSString *> *mConfirmedSet;
@property (assign, nonatomic) int queryRetry;

// send
@property (strong, nonatomic) NSData *bindAddress;
@property (strong, nonatomic) NSTask *launchTask;

// server-driven contron info
@property (assign, nonatomic) int sendInterval;
@property (assign, nonatomic) int waitAfterLastSend;

@end


@implementation Emulator


+ (instancetype)emulatorWithIdentifier:(NSString *)identifier delegate:(id<EmulatorDelegate>)dlg {
    Emulator *m = [Emulator new];
    m.identifier = identifier;
    m.deledate = dlg;
    m.progress = EMU_PROGRESS_SLEEPING;
    m.mQueryResults = [NSMutableArray array];
    m.mConfirmedSet = [NSMutableSet set];
    return m;
}

+ (NSString *)emuIDForIndex:(int)idx {
    NSString *emuID = nil;
    if (idx < 10){
        emuID = [NSString stringWithFormat:@"#0%d", idx];
    }else{
        emuID = [NSString stringWithFormat:@"#%d", idx];
    }
    return emuID;
}

- (NSString *)identifier {
    return _identifier;
}

- (int)progress {
    return _progress;
}

- (NSString *)serialNumber {
    return self.cert.SN;
}

- (int)queryCount {
    return _queryCount;
}

- (int)sendCount {
    return _sendCount;
}

- (NSData *)bindAddress {
    return _bindAddress;
}

- (SendResult *)finalSendResult {
    return _sendResult;
}

- (void)reset {
    if (self.cert == nil){
        // has already reset
        return;
    }
    
    [self.mQueryResults removeAllObjects];
    [self.mConfirmedSet removeAllObjects];
    
    self.queryCount = 0;
    self.sendCount = 0;
    self.cert = nil;
    self.taskDict = nil;
    if (self.launchTask != nil){
        [self.launchTask terminate];
        self.launchTask = nil;
    }
    self.progress = EMU_PROGRESS_CONFIRMING;
    self.queryRetry = 0;
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.deledate respondsToSelector:@selector(emulatorWillReset:)]){
            [self.deledate emulatorWillReset:self];
        }
        self.sendResult = nil;
        self.bindAddress = nil;
        
        [self _updateAndNoitfyProgress:EMU_PROGRESS_SLEEPING];
    });
}


- (BOOL)isFree {
    return (self.progress == EMU_PROGRESS_SLEEPING);
}

- (void)startQueryPeerID {
    if (self.cert != nil && [self.cert checkValid]){
        NSLog(@"emu %@ got cert %@", self.identifier, self.cert);
        NSString *xMsgID = self.taskDict[@"MsgInfo"][@"Identifier"];
        if (xMsgID == nil){
            xMsgID = @"Bad-Identifier";
        }
        self.sendResult = [[SendResult alloc] initWithSerialNumber:self.cert.SN taskID:xMsgID];
        [self _startQueryPeerID];
    }else{
        NSLog(@"emu %@ got BAD box, raw dict %@", self.identifier, self.taskDict);
        [self reset];        
    }
}

- (void)_startQueryPeerID {
    //NSLog(@"emu %@ _startQueryPeerID...", self.identifier);
    self.progress = EMU_PROGRESS_QUERYING;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deledate emulatorDidUpdateProgress:self];
    });
    
    NSArray *phones = self.taskDict[@"PhoneNoList"];
    if ([phones count] == 0){
        // bad targets
        [self reset];
        return;
    }
    
    __weak Emulator *weakSelf = self;
    [PeerIDManager queryTargets:phones withBinaryCert:self.cert completeHandler:^(NSArray *results, NSError *err) {
        NSLog(@"emu %@ _startQueryPeerID... got %ld %@, err %@", weakSelf.identifier, (long)[results count], ([results count]>0?@"🔑":@""), err);
        if (err != nil){
            if ([[err domain] isEqualToString:kQueryErrorNetwork] && self.queryRetry < MAX_QUERY_RETRY){
                int wait = 3 + arc4random_uniform(5);
                NSLog(@"emu %@ will retry query after %d secs ... no.%d", self.identifier, wait, self.queryRetry);
                self.queryRetry++;
        
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(wait * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf _startQueryPeerID];
                });
                
            }else{
                
                [weakSelf _updateAndNoitfyProgress:EMU_PROGRESS_QUERY_FAIL];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf reset];
                });
            }
            return;
        }
        
        if ([results count] == 0){
            
            [weakSelf _updateAndNoitfyProgress:EMU_PROGRESS_QUERY_FAIL];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf reset];
            });
            
            return;
        }
        
        weakSelf.queryCount = (int)[results count];
        [weakSelf.mQueryResults addObjectsFromArray:results];
        
        // launch worker
        [weakSelf _launchBlackWorker];
    }];
    
}


- (void)_launchBlackWorker {
    // message
    NSDictionary *msgInfo = self.taskDict[@"MsgInfo"];
    self.msgID = msgInfo[@"Identifier"];
    if (self.msgID == nil){
        NSLog(@"emu %@ msg id is nil", self.identifier);
        [self reset];
        return;
    }
    
    self.msgText = msgInfo[@"Text"];
    if (self.msgText == nil){
        NSLog(@"emu %@ msg text is nil", self.identifier);
        [self reset];
        return;
    }
    
    // server control info
    NSDictionary *ctrlInfo = self.taskDict[@"CtlInfo"];
    self.sendInterval = [ctrlInfo[@"SendInterval"] intValue];
    if (self.sendInterval == 0){
        self.sendInterval = 3;
    }
    self.waitAfterLastSend = [ctrlInfo[@"WaitAfterSend"] intValue];
    if (self.waitAfterLastSend == 0){
        self.waitAfterLastSend = 120;
    }
    
    NSLog(@"emu %@ will launch worker", self.identifier);
    [self _updateAndNoitfyProgress:EMU_PROGRESS_CONNECTING];
    
    // launch
    if (self.launchTask != nil){
        [self.launchTask terminate];
        self.launchTask = nil;
    }
    
    NSMutableArray *mQrets = [NSMutableArray array];
    for (QueryResultItem *qr in self.mQueryResults){
        NSDictionary *qDict = [qr toDictionary];
        if (qDict){
            [mQrets addObject:qDict];
        }
    }
    
    NSMutableArray *mTargets = [NSMutableArray array];
    NSArray *phones = self.taskDict[@"PhoneNoList"];
    for (NSString *p in phones){
        [mTargets addObject:p];
    }
    
    NSDictionary *args = @{
        MASTER_PORT_ARG_KEY: @(self.masterPort),
        CERT_BOX_DATA_ARG_KEY: [self.cert packedData],
        QUERY_RESULTS_ARG_KEY: mQrets,
        TARGETS_ARG_KEY: mTargets,
        TEXT_MESSAGE_ARG_KEY: self.msgText,
        EMU_ID_ARG_KEY: self.identifier,
        SEND_INTERVAL_ARG_KEY: @(self.sendInterval),
        FINISH_WAIT_ARG_KEY: @(self.waitAfterLastSend),
    };
    NSString *argsPath = [NSString stringWithFormat:@"%@%@.plist",NSTemporaryDirectory(), [[NSUUID UUID] UUIDString]];
    [args writeToFile:argsPath atomically:NO];
    
    NSString *path = [[NSBundle mainBundle] executablePath];
    path = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"MadridExpress_Nigger"];
    NSURL *trainURL = [NSURL fileURLWithPath:path];
    NSArray *argVals = @[ argsPath  ];
    NSError *err = nil;
    __weak Emulator *weakSelf = self;
    self.launchTask = [NSTask launchedTaskWithExecutableURL:trainURL arguments:argVals error:&err terminationHandler:^(NSTask *t) {
        NSLog(@"emu %@ worker pid %d terminated... status %d", weakSelf.identifier, t.processIdentifier, t.terminationStatus);
        
        [weakSelf _updateAndNoitfyProgress:EMU_PROGRESS_WILL_RESET];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf reset];
        });
       
    }];
    NSLog(@"emu %@ launch worker ok, pid = %d", self.identifier, self.launchTask.processIdentifier);
}


- (void)trainIsReadyToFly {
    NSLog(@"emu %@ trainIsReadyToFly...", self.identifier);
    self.progress = EMU_PROGRESS_SENDING;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deledate emulatorDidUpdateProgress:self];
    });
    

}


- (BOOL)confirmMessageSent:(NSString *)target {
    if ([self.mConfirmedSet containsObject:target]){
        NSLog(@"emu %@ has confirmed %@ before??? ⁉️ ", self.identifier, target);
        return NO;
    }
    NSLog(@"emu %@ 🍺 %@ 🍺 ", self.identifier, target);
    self.sendCount++;
    [self.mConfirmedSet addObject:target];
    [self.sendResult addSentPhone:[PeerIDManager originTarget:target]];
    return YES;
}

- (BOOL)confirmMessageBlock:(NSString *)target {
    return YES;
}

- (void)_updateAndNoitfyProgress:(int)prog {
    self.progress = prog;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deledate emulatorDidUpdateProgress:self];
    });
}

- (void)noteBindedTrainDidExit {
    NSLog(@"emu %@ noteBindedTrainDidExit...", self.identifier);
//    [self _retrySendingIfNeeded];
}

@end
