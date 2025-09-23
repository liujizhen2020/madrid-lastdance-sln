//
//  APSDumpHelper.m
//  APSDumpHelper
//
//  Created by yt on 31/08/23.
//

#import "APSDumpHelper.h"

static NSFileHandle *myFileHandle = nil;
static NSMutableDictionary *mDataDict = nil;



static __attribute__((constructor)) void InitHackApsd()
{
    NSLog(@"<<<<<<<<<<<<<<<<<< APSDumpHelper <<<<<<<<<<<<<<<<<<");
    mDataDict = [NSMutableDictionary dictionary];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:X_APSD_PLIST]){
        BOOL ok = [fm createFileAtPath:X_APSD_PLIST contents:nil attributes:nil];
        hack_log(@" 🍉 my apsd data file created? %@", ok?@"Y":@"N");
    }
    myFileHandle = [NSFileHandle fileHandleForWritingAtPath:X_APSD_PLIST];
    hack_log(@" 🍉 my apsd data file handle %@", myFileHandle);
}

void helper_save_data(NSString *key, NSData *data) {
    NSLog(@" 🍎 helper_save_data %@ -> %@", key, data);
    if (key == nil || data == nil){
        return;
    }
    mDataDict[key] = data;
    NSLog(@" 🍎 current data dict %@", mDataDict);
    
    
    NSError *err;
    [myFileHandle seekToFileOffset:0];
    NSData *plData = [NSPropertyListSerialization dataWithPropertyList:mDataDict format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
    [myFileHandle writeData:plData];
    NSLog(@" 🍎 write file handle err %@, %@", err, plData);
}
