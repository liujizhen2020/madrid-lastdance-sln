//
//  Emulator.h
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../emu_defs.h"


@class Emulator, SendResult, BinaryCert;

@protocol EmulatorDelegate <NSObject>

- (void)emulatorWillReset:(Emulator *)m;

- (void)emulatorDidUpdateProgress:(Emulator *)m;

- (void)emulator:(Emulator *)m didFinishQueryWithError:(NSError *)err;

- (void)emulator:(Emulator *)m didFinishSendWithError:(NSError *)err;

@end


@interface Emulator : NSObject

@property (strong, nonatomic) BinaryCert *cert;
@property (strong, nonatomic) NSDictionary *taskDict;

+ (instancetype)emulatorWithIdentifier:(NSString *)identifier delegate:(id<EmulatorDelegate>)dlg;

+ (NSString *)emuIDForIndex:(int)idx;

- (void)setMasterPort:(int)port;


- (NSString *)identifier;
- (int)progress;
- (NSString *)serialNumber;
- (int)queryCount;
- (int)sendCount;

- (void)reset;
- (BOOL)isFree;

- (void)startQueryPeerID;

// send events
- (void)trainIsReadyToFly;
- (BOOL)confirmMessageSent:(NSString *)target;
- (BOOL)confirmMessageBlock:(NSString *)target;
- (SendResult *)finalSendResult;
- (NSData *)bindAddress;

// train event
- (void)noteBindedTrainDidExit;

@end


