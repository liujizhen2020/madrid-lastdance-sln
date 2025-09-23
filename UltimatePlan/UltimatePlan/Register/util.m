//
//  util.m
//  UltimatePlan
//
//  Created by yt on 18/08/23.
//

#import "util.h"
#import <IOKit/IOKitLib.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

static NSData* trimData(NSData *data) {
    NSMutableData *msgData = data.mutableCopy;
    if (msgData.length >= 1) {
        BOOL index = YES;
        while (index) {
            NSData *trimData = [msgData subdataWithRange:NSMakeRange(msgData.length-1, 1)];
            Byte lastByte[1];
            [trimData getBytes:lastByte range:NSMakeRange(0, 1)];
            if (lastByte[0] == 0x00) {
                [msgData replaceBytesInRange:NSMakeRange(msgData.length-1, 1) withBytes:NULL length:0];
                index = YES;
            } else {
                index = NO;
            }
        }
    }
    return msgData;
}

NSString* mac_copy_sn(void){
    io_registry_entry_t reg = IORegistryEntryFromPath(kIOMasterPortDefault,"IODeviceTree:/");
    if (reg != 0){
        CFTypeRef prop = IORegistryEntryCreateCFProperty(reg, CFSTR("IOPlatformSerialNumber"),kCFAllocatorDefault,0);
        if (CFGetTypeID(prop) == CFStringGetTypeID()){
            CFStringRef sn = (CFStringRef)prop;
            return (__bridge NSString *)sn;
        }
    }
    return @"BadSN";
}

NSString* mac_copy_model(void){
    io_registry_entry_t reg = IORegistryEntryFromPath(kIOMasterPortDefault,"IODeviceTree:/");
    if (reg != 0){
        CFTypeRef prop = IORegistryEntryCreateCFProperty(reg, CFSTR("model"),kCFAllocatorDefault,0);
        if (CFGetTypeID(prop) == CFDataGetTypeID()){
            CFDataRef ptRef = (CFDataRef)prop;
            NSData *ptData = (__bridge NSData *)ptRef;
            ptData = trimData(ptData);
            NSString *pt = [[NSString alloc] initWithData:ptData encoding:NSUTF8StringEncoding];
            return pt;
        }
    }
    return @"BadPT";
}



NSString*
get_eth_ip_address(void) {
    NSString *ip = @"---";
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

