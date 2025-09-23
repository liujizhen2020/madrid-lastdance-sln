//
//  APSDumpHelper.h
//  APSDumpHelper
//
//  Created by yt on 31/08/23.
//

#import <Foundation/Foundation.h>

//#define hack_log(fmt, ...)   NSLog((@"hack 🍓 " fmt), ##__VA_ARGS__)
#define hack_log(fmt, ...)

#define X_APSD_PLIST        @"/Library/x_apsd.plist"
#define APS_PUSH_CERT       @"push_cert"
#define APS_PUSH_KEY        @"push_key"

FOUNDATION_EXPORT void helper_save_data(NSString *key, NSData *data);

