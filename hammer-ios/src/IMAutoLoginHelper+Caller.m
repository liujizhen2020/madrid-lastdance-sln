#import "IMAutoLoginHelper+Caller.h"

extern bool SBSOpenSensitiveURLAndUnlock(CFURLRef url, char flags);

@implementation IMAutoLoginHelper(Caller)

+ (BOOL)prefsIMLogin {
    BOOL ok = [[IMAutoLoginHelper sharedInstance] checkReady];
    if (!ok){
        return NO;
    }

    NSURL *theURL = [NSURL URLWithString:@"prefs:root=MESSAGES"];
    bool ret = SBSOpenSensitiveURLAndUnlock((__bridge CFURLRef)theURL, 1);
    if(!ret) {
        NSLog(@"Couldn't open prefs app, ret = %d", ret);
        return NO;
    }

    return YES;
}

@end
