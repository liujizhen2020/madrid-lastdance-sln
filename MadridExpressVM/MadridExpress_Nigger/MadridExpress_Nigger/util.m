//
//  util.m
//  BlackTrain
//
//  Created by boss on 24/07/2019.
//  Copyright © 2019 Fenda Casarinwa. All rights reserved.
//

#import "util.h"
#import <dlfcn.h>

int load_binary_apsd(){
    dlopen("/System/Library/PrivateFrameworks/ApplePushService.framework/apsd", RTLD_NOW);
    return 0;
}

int load_binary_query(){
    dlopen("/System/Library/PrivateFrameworks/FTServices.framework/FTServices", RTLD_NOW);
    dlopen("/System/Library/PrivateFrameworks/IMFoundation.framework/IMFoundation", RTLD_NOW);
    return 0;
}

int load_binary_ids(){
    dlopen("/System/Library/PrivateFrameworks/IDSFoundation.framework/IDSFoundation", RTLD_NOW);
    return 0;
}


void loop_forever(){
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    BOOL ok = YES;
    while (ok){
        ok = [rl runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


NSData*
uuid_data(NSUUID *srcUUID)
{
    if (srcUUID == nil){
        srcUUID = [NSUUID UUID];
    }
    UInt8 qrUuidBytes[16];
    [srcUUID getUUIDBytes:qrUuidBytes];
    return [NSData dataWithBytes:qrUuidBytes length:16];
}

long
random_identifier()
{
    long identifier = 0;
    for (int i=0;i<4;i++){
        UInt8 add = arc4random() % 255;
        identifier += (add << 7*(3-i));
    }
    return identifier;
}
