#import "IMAutoLoginHelper.h"
#import "Account.h"
#import "../common/defines.h"

@interface IMAutoLoginHelper()

@property (strong, nonatomic) Account *acc;

@property (assign, nonatomic) long triggerAt;

@end

@implementation IMAutoLoginHelper

// tweak
+ (instancetype)sharedInstance {
    static IMAutoLoginHelper *alh_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        alh_ = [IMAutoLoginHelper new];
        Account *account = [[Account alloc] init];
		[account loadFromFile:ACCOUNT_INFO_PATH];
        alh_.acc = account;
        alh_.triggerAt = 0;
        [alh_ checkReady];
    });
    return alh_;
}

- (BOOL)checkReady {
    return [self.acc checkValid];
}

- (BOOL)hasTriggered {
    return (self.triggerAt > 0);
}

- (void)markTriggered {
    self.triggerAt = (long)[[NSDate date] timeIntervalSince1970];
}

- (NSString *)username {
    return self.acc.email;
}

- (NSString *)password {
    return self.acc.pwd;
}

@end
