//
//  main.m
//  CoreTrojan
//
//  Created by yt on 17/08/23.
//

#import <Foundation/Foundation.h>
#import "util.h"
#import "ServerAPI.h"
#import "hfs.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // check flag
        if (check_hack_flag()){
            NSLog(@"....SKIP...");
            return 0;
        }
        
        // update config.plist
        NSString *vmcIP = nil;
        int MAX_TRY = 100;
        int try = 0;
        NSString *rom = nil;
        while (rom == nil){
            try++;
            rom = get_eth_mac_address();
            NSLog(@"ROM: %@", rom);
            if (rom != nil){
                break;
            }
            
            if (try > MAX_TRY){
                NSLog(@"Fatal: fail to get ROM ... try = %d", try);
                return 44;
            }
            
            // wait some time, max 5 min
            [NSThread sleepForTimeInterval:3];
        }
        
        rom = [rom stringByReplacingOccurrencesOfString:@":" withString:@""];
        
        // retry many times
        MacCode *mc = 0;
        MAX_TRY = 20;
        try = 0;
        while (1) {

            // get ip every time
            NSString *myIP = get_eth_ip_address();
            NSLog(@"my  IP %@", myIP);
            if (myIP == nil){
                [NSThread sleepForTimeInterval:3];
                continue;
            }
            NSArray *parts = [myIP componentsSeparatedByString:@"."];
            if ([parts count] == 4){
                NSArray *xparts = @[parts[0], parts[1], parts[2], @"1"];
                vmcIP = [xparts componentsJoinedByString:@"."];
            }
            NSLog(@"vmc IP %@", vmcIP);
            [ServerAPI setVmcIP:vmcIP];
            mc = [ServerAPI sync_fetchMacCodeWithROM:rom];
            NSLog(@"mc: %@", mc);
            if (mc.port != 0) {
                NSLog(@"set proxy: %@：%ld", mc.ip, mc.port);
                setProxy(mc.ip, mc.port);
            }
            if (mc != nil){
                break;
            }
            
            if (try > MAX_TRY){
                NSLog(@"Fatal: fail to sync_fetchMacCodeWithROM... try = %d", try);
                return 44;
            }
            
            // wait some time
            [NSThread sleepForTimeInterval:3];
        }
        
        
        
        if (mc == nil){
            [ServerAPI sync_markDeadVMWithROM:rom];
            return 1;
        }
        
        int ret = 0;
        
        ret = write_opencore_config_file(@"/Library/CoreTrojan/config-sample.plist", mc);
        NSLog(@"write_opencore_config_file ret = %d", ret);
        if (ret != 0){
            [ServerAPI sync_markDeadVMWithROM:rom];
            return 2;
        }
    
        // change file system UUID
        ret = hfs_change_disk_volume_uuid("/dev/disk0s2");
        if (ret != 0){
            [ServerAPI sync_markDeadVMWithROM:rom];
            return 3;
        }
        
        // all good
        NSLog(@"ALL GOOD");
        write_hack_flag();
        
        clear_apsd_keychain();
        clear_user_keychain();
        
        [ServerAPI sync_markSuccVMWithROM:rom];
        
        NSLog(@"will reboot now...");
        do_reboot();
    }
    return 0;
}
