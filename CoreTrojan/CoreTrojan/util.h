//
//  util.h
//  CoreTrojan
//
//  Created by yt on 17/08/23.
//

#import <Foundation/Foundation.h>
#import "MacCode.h"

FOUNDATION_EXPORT BOOL check_hack_flag(void);
FOUNDATION_EXPORT BOOL write_hack_flag(void);

FOUNDATION_EXPORT NSString * get_eth_ip_address(void);
FOUNDATION_EXPORT NSString * get_eth_mac_address(void);

FOUNDATION_EXPORT int write_opencore_config_file(NSString *sample, MacCode *mc);


FOUNDATION_EXPORT BOOL set_reboot_flag(void);
FOUNDATION_EXPORT BOOL remove_reboot_flag(void);


FOUNDATION_EXPORT BOOL clear_apsd_keychain(void);
FOUNDATION_EXPORT BOOL clear_user_keychain(void);


FOUNDATION_EXPORT void do_reboot(void);
FOUNDATION_EXPORT void setProxy(NSString *ip, NSInteger port);
