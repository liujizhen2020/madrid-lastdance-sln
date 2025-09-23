//
//  GameMaster.m
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "GameMaster.h"
#import "Emulator.h"
#import "../../worker_defs.h"
#import "../ServerAPI/ServerAPI.h"
#import "../../Vendor/GCDAsyncUdpSocket.h"

#define TEST_BINARY_CERT_PATH   @"/tmp/bc_data.bin"

@interface GameMaster()<ServerAPIDelegate, EmulatorDelegate, GCDAsyncUdpSocketDelegate>

@property (assign, nonatomic, readwrite) long sentCount;
@property (assign, nonatomic, readwrite) long taskCount;
@property (assign, nonatomic, readwrite) int masterPort;
@property (assign, nonatomic, readwrite, getter=isPaused) BOOL paused;
@property (assign, nonatomic) int emuLimit;
@property (assign, nonatomic) int oldEmuLimit;
@property (assign, nonatomic) NSTimeInterval loopInterval;

@property (strong, nonatomic) NSTimer *loopTimer;
@property (strong, nonatomic) ServerAPI *provider;
@property (strong, nonatomic) NSLock *rwIDLock;
@property (strong, nonatomic) NSMutableSet<NSString *> *mAllEmuIDSet;
@property (strong, nonatomic) NSMutableOrderedSet<NSString *> *mFreeEmuIDSet;
@property (strong, nonatomic) NSMutableSet<NSString *> *mBusyEmuIDSet;
@property (strong, nonatomic) NSMutableDictionary<NSString *,Emulator *> *mEmulatorsCache;
@property (strong, nonatomic) NSMutableDictionary<NSData*, Emulator *> *mAddressEmulatorCache;

@property (strong, nonatomic) NSString *rootURL;

// udp
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation GameMaster


+ (instancetype)sharedInstance {
    static GameMaster *gm_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gm_ = [GameMaster new];
        [gm_ _doInit];
    });
    return gm_;
}

- (void)makePeace {
    self.paused = YES;
    if (self.loopTimer != nil){
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
}

- (void)startBattle {
    self.paused = NO;
    
    if (self.loopTimer != nil){
        [self.loopTimer invalidate];
        self.loopTimer = nil;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:TEST_BINARY_CERT_PATH]){
        NSLog(@" ❗️ ❗️ ❗️ TEST_BINARY_CERT_PATH, go test now");
        // we only to test...
        NSData *bcData = [NSData dataWithContentsOfFile:TEST_BINARY_CERT_PATH];
        BinaryCert *bc = [BinaryCert parseFrom:bcData];
        NSDictionary *taskInfo = @{
            @"MsgInfo":@{
                @"Identifier": [[NSUUID UUID] UUIDString],
                @"Text": [NSString stringWithFormat:@"hello-%d",arc4random()],
            },
            @"PhoneNoList":@[
                @"pensionplan@proton.me",
                @"fendacasarinwa@gmail.com",
            ],
        };
        [self providerDidFetchBinaryCert:bc andTaskInfo:taskInfo withError:nil];
        return;
    }
    
    self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopInterval target:self selector:@selector(_gmlLoopJob) userInfo:nil repeats:YES];
}

- (void)_gmlLoopJob {
    NSUInteger freeEmuCount = (int)[self.mFreeEmuIDSet count];
    int availConn = [self.provider availalbeConnectionsCount];
    int requestConn = [self.provider requestingConnectionsCount];
    //NSLog(@"gm: has %lu free emu , conn avail %d ~ %d requesting", (unsigned long)freeEmuCount, availConn, requestConn);
    if (availConn > 0 && freeEmuCount > requestConn){
        [self.provider fetchCertBoxAndTaskInfo:freeEmuCount];
    }
}

- (void)_doInit {
    self.paused = YES;
    self.rwIDLock = [NSLock new];
    self.mAllEmuIDSet = [NSMutableSet setWithCapacity:100];
    self.mFreeEmuIDSet = [NSMutableOrderedSet orderedSetWithCapacity:100];
    self.mBusyEmuIDSet = [NSMutableSet setWithCapacity:100];
    self.mEmulatorsCache = [NSMutableDictionary dictionaryWithCapacity:100];
    self.mAddressEmulatorCache = [NSMutableDictionary dictionaryWithCapacity:100];
    self.provider = [ServerAPI new];
    self.provider.delegate = self;
    
    // udp
    dispatch_queue_t udpQueue = dispatch_queue_create("emu_UDP_daemon", NULL);
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:udpQueue];
    [self.udpSocket setIPv4Enabled:YES];
    [self.udpSocket setIPv6Enabled:NO];
    int port = 10000+arc4random_uniform(1024);
    NSError *err;
    while (1){
        NSLog(@"gm: try bind to port %d", port);
        BOOL ok = [self.udpSocket bindToPort:port error:&err];
        if (ok){
            self.masterPort = port;
            NSLog(@"gm: bind UDP to port %d", self.udpSocket.localPort);
            [self.udpSocket beginReceiving:&err];
            break;
        }else{
            NSLog(@"gm: bind UDP ERR %@", err);
        }
        port += arc4random_uniform(10);
    }
}

- (void)limitEmuCount:(int)newLimit {
    if (self.oldEmuLimit == newLimit){
        NSLog(@"gm: SKIP same emu limit... %d", newLimit);
        return;
    }
    self.emuLimit = newLimit;
    self.oldEmuLimit = newLimit;
    
//    // loop intervals
//    //  10 emu ~ 1.0f
//    //  30 emu ~ 0.8f
//    //  50 emu ~ 0.6f
//    // 100 emu ~ 0.1f
//    self.loopInterval = MAX(0.1f, 1.1f - newLimit/10.0f);
    self.loopInterval = 1;
    if (!self.isPaused){
        if (self.loopTimer != nil){
            [self.loopTimer invalidate];
            self.loopTimer = nil;
        }
        self.loopTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopInterval target:self selector:@selector(_gmlLoopJob) userInfo:nil repeats:YES];
    }
    
    // reset emu id set
    [self.rwIDLock lock];
    [self.mAllEmuIDSet removeAllObjects];
    for (int i=0; i<self.emuLimit; i++){
        NSString *emuID = [Emulator emuIDForIndex:(i+1)];
        [self.mAllEmuIDSet  addObject:emuID];
    }
    [self.mBusyEmuIDSet intersectSet:self.mAllEmuIDSet];
    [self.mFreeEmuIDSet unionSet:self.mAllEmuIDSet];
    [self.mFreeEmuIDSet minusSet:self.mBusyEmuIDSet];
    [self.rwIDLock unlock];
   
    NSLog(@"gm: new limit %d, %d busy emu, %d free emu,", newLimit, (int)[self.mBusyEmuIDSet count], (int)[self.mFreeEmuIDSet count]);
}

- (void)resetSentCount {
    self.sentCount = 0;
    self.taskCount = 0;
}

- (NSError *)useServerRootURL:(NSString *)root {
    NSURL *u = [NSURL URLWithString:root];
    if ([u.scheme isEqualToString:@"http"] || [u.scheme isEqualToString:@"https"]){
        self.rootURL = [u absoluteString];
        return nil;
    }
    return [NSError errorWithDomain:@"BAD_ROOT_URL" code:-1 userInfo:nil];
}


#pragma mark - ServerAPIDelegate

- (NSString *)serverRootURL {
    return self.rootURL;
}

- (void)providerDidFetchBinaryCert:(BinaryCert *)bc andTaskInfo:(NSDictionary *)taskInfo withError:(NSError *)err {
    //NSLog(@"didFetchTaskInfo.... task dict nil? %@  err %@", (taskDict == nil?@"YES":@"NO"), err);
    if (err != nil){
        NSLog(@"gm: ERR get task %@", err);
        return;
    }
    
    self.taskCount++;
    NSString *emuID = [self.mFreeEmuIDSet firstObject];
    if (emuID == nil){
        NSLog(@"gm: FATAL ... no free emu after get task... %@", self.mFreeEmuIDSet);
        return;
    }
    NSLog(@"gm: emu %@ start new job 🚀 ", emuID);
    Emulator *m = self.mEmulatorsCache[emuID];
    if (m == nil){
        m = [Emulator emulatorWithIdentifier:emuID delegate:self];
        self.mEmulatorsCache[emuID] = m;
    }
    m.cert = bc;
    m.taskDict = taskInfo;
    [m setMasterPort:self.masterPort];
    [m startQueryPeerID];
    
    [self.rwIDLock lock];
    [self.mFreeEmuIDSet removeObject:emuID];
    [self.mBusyEmuIDSet addObject:emuID];
    [self.rwIDLock unlock];
}


#pragma mark - EmulatorDelegate

- (void)emulatorDidUpdateProgress:(Emulator *)m {
    NSLog(@"gm: emu %@ ---> %d",m.identifier, m.progress);
    if ([self.uiDelegate respondsToSelector:@selector(gameMasterDidUpdateEmulator:)]){
        [self.uiDelegate gameMasterDidUpdateEmulator:m];
    }
}

- (void)emulator:(Emulator *)m didFinishQueryWithError:(NSError *)err {
    NSLog(@"gm: emu %@ didFinishQueryWithError... %@", m.identifier, err);
    if ([self.uiDelegate respondsToSelector:@selector(gameMasterDidUpdateEmulator:)]){
        [self.uiDelegate gameMasterDidUpdateEmulator:m];
    }
}

- (void)emulator:(Emulator *)m didFinishSendWithError:(NSError *)err {
    NSLog(@"gm: emu %@ didFinishSendWithError... %@", m.identifier, err);
    if ([self.uiDelegate respondsToSelector:@selector(gameMasterDidUpdateEmulator:)]){
        [self.uiDelegate gameMasterDidUpdateEmulator:m];
    }
}

- (void)emulatorWillReset:(Emulator *)m {
    NSString *emuID = m.identifier;
    if ([self.mBusyEmuIDSet containsObject:emuID]){
        NSLog(@"gm: emu %@ will reset 💤 ", m.identifier);
        [self.rwIDLock lock];
        [self.mBusyEmuIDSet removeObject:emuID];
        [self.mFreeEmuIDSet addObject:m.identifier];
        [self.rwIDLock unlock];
        
        // report send result
        SendResult *sr = [m finalSendResult];
        [self.provider reportSendResult:sr];
    }
    
    // clear if needed
    NSData *addr = [m bindAddress];
    if (addr){
        NSLog(@"gm: emu cache REMOVE emu %@ addr %@", m.identifier, addr);
        [self.mAddressEmulatorCache removeObjectForKey:addr];
    }
}


#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"udpSocket:didNotSendDataWithTag:dueToError: tag %ld err %@", tag, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    //NSLog(@"udpSocket:didSendDataWithTag: tag %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    //NSLog(@"udpSocket:didReceiveData:fromAddress:withFilterContext: data %@", data);
    //NSLog(@"remote address %@", address);
    
    uint8_t stage = *(uint8_t *)(data.bytes);
    switch (stage) {
        case WORKER_STAGE_READY:
        {
            NSString *spID = [[NSString alloc] initWithBytes:(data.bytes+1) length:(data.length-1) encoding:NSUTF8StringEncoding];
            NSLog(@"STAGE_READY  sp: %@", spID);
            
            NSArray *checkIDs = [self.mBusyEmuIDSet allObjects];
            for (NSString *emuID in checkIDs){
                Emulator *m = self.mEmulatorsCache[emuID];
                if ([m.cert.email isEqualToString:spID]){
                    NSLog(@"gm: emu %@ got a new train 🚂 ", m.identifier);
                    self.mAddressEmulatorCache[address] = m;
                    NSLog(@"gm: emu cache ADD emu %@ addr %@", m.identifier, address);
                    break;
                }
            }
            
            //
            Emulator *emu = self.mAddressEmulatorCache[address];
            if (emu){
                [emu trainIsReadyToFly];
            }
            break;
        }
            
        case WORKER_STAGE_SENT:
        {
            //NSLog(@"STAGE_SENT");
            NSString *target = [[NSString alloc] initWithBytes:(data.bytes+1) length:(data.length-1) encoding:NSUTF8StringEncoding];
            Emulator *emu = self.mAddressEmulatorCache[address];
            if (emu){
                NSLog(@"emu %@ ✅ %@ ✅ ", emu.identifier, target);
                BOOL confirmed = [emu confirmMessageSent:target];
                if (confirmed){
                    self.sentCount++;
                    // update ui
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(gameMasterDidUpdateEmulator:)]){
                            [self.uiDelegate gameMasterDidUpdateEmulator:emu];
                        }
                        if(self.uiDelegateForDebug && [self.uiDelegateForDebug respondsToSelector:@selector(gameMasterDidUpdateEmulatorForDebug:)]){
                            [self.uiDelegateForDebug gameMasterDidUpdateEmulatorForDebug:emu];
                        }
                    });
                }
            }
            
            break;
        }
            
        case WORKER_STAGE_BLOCK:
        {
            NSString *target = [[NSString alloc] initWithBytes:(data.bytes+1) length:(data.length-1) encoding:NSUTF8StringEncoding];
            Emulator *emu = self.mAddressEmulatorCache[address];
            if (emu){
                [emu confirmMessageBlock:target];
            }
            break;
        }
        case WORKER_STAGE_GAME_OVER:
        {
            NSLog(@"STAGE_GAME_OVER");
            Emulator *emu = self.mAddressEmulatorCache[address];
            if (emu){
                NSLog(@"gm: emu cache REMOVE emu %@ addr %@", emu.identifier, address);
                [emu noteBindedTrainDidExit];
                [self.mAddressEmulatorCache removeObjectForKey:address];
            }
            break;
        }
        default:
            break;
    }
}


@end
