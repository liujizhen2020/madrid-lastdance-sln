//
//  util.m
//  UltimatePlan
//
//  Created by yt on 18/08/23.
//

#import "util.h"
#import <IOKit/IOKitLib.h>


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

