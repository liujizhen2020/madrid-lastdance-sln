#ifndef _madrid_common_defines_h
#define _madrid_common_defines_h

#import <Foundation/Foundation.h>

// path
#define DEVICE_INFO_PATH                @"/tmp/md_device.plist"
#define ACCOUNT_INFO_PATH               @"/tmp/md_account.plist"
#define MY_UCRT_PATH                    @"/tmp/CE_UCRT.pem"
#define LAST_RESET_PATH                 @"/tmp/last_reset.plist"

#define NOTIFY_APPLE_ID_FATAL           "com.yourcompany.md.err.apple_id_fatal"
#define NOTIFY_APPLE_ID_LOCKED          "com.yourcompany.md.err.apple_id_locked"

// biz
static NSString *BIZ_NAME    = @"MD";
static NSString *BIZ_VERSION = @"2507241547";


static const NSString *kBizInfoPath   = @"/Library/nk_biz.plist";
static const NSString *kBizNameKey    = @"BizName"; 
static const NSString *kBizVersionKey = @"BizVersion";

// err
#define ERROR_NETWORK                   -1
#define ERROR_SERVER_LOGIC              -2

// notify                           
#define NOTIFY_SEND_REGISTER_MESSAGE                  "NOTIFY_SEND_REGISTER_MESSAGE"
#define NOTIFY_IMESSAGE_REGISTER_RESULT               "NOTIFY_IMESSAGE_REGISTER_RESULT"
#define NOTIFY_ENV_FATAL                              "NOTIFY_ENV_FATAL"

// ims result
#define REGISTER_RESULT_MASK                (uint64_t)10000
#define REGISTER_RESULT_OK                  (uint64_t)0


#endif // _madrid_common_defines_h
