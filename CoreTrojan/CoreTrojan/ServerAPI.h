//
//  ServerAPI.h
//  CoreTrojan
//
//  Created by yt on 17/08/23.
//

#import <Foundation/Foundation.h>
#import "MacCode.h"

@interface ServerAPI : NSObject

+ (void)setVmcIP:(NSString *)vmc;
+ (MacCode *)sync_fetchMacCodeWithROM:(NSString *)rom;
+ (void)sync_markDeadVMWithROM:(NSString *)rom;
+ (void)sync_markSuccVMWithROM:(NSString *)rom;

@end
