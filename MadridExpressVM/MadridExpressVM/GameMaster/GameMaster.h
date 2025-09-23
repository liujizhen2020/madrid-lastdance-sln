//
//  GameMaster.h
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Emulator.h"

@protocol GameMasterUIDelegate <NSObject>

- (void)gameMasterDidUpdateEmulator:(Emulator *)emu;

@end
  
@protocol GameMasterUIDelegateForDebug <NSObject>

- (void)gameMasterDidUpdateEmulatorForDebug:(Emulator *)emu;

@end

@interface GameMaster : NSObject

@property (assign, nonatomic, readonly) long sentCount;
@property (assign, nonatomic, readonly) long taskCount;
@property (assign, nonatomic, readonly, getter=isPaused) BOOL paused;
@property (assign, nonatomic, readonly) int masterPort;

@property (weak, nonatomic) id<GameMasterUIDelegate> uiDelegate;

@property (weak, nonatomic) id<GameMasterUIDelegateForDebug> uiDelegateForDebug;

+ (instancetype)sharedInstance;

- (void)startBattle;

- (void)makePeace;

- (void)limitEmuCount:(int)newLimit;

- (void)resetSentCount;

- (NSError *)useServerRootURL:(NSString *)root;

@end
