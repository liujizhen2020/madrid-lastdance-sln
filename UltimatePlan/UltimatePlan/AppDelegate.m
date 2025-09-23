//
//  AppDelegate.m
//  UltimatePlan
//
//  Created by yt on 18/08/23.
//

#import "AppDelegate.h"
#import "CoreTrojan.h"
#import "Register/Madrid.h"
#import "ServerAPI/ServerAPI.h"
#import "../MessagesDumpHelper/APSDumpHelper.h"
#import "../MessagesDumpHelper/MessagesDumpHelper.h"
#import "../MessagesDumpHelper/BinaryCert.h"
#import "Reachability.h"
#import "Register/util.h"

#define MAX_LOGIN_TRY       30
#define MAX_APSD_CHECK      24


@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSString *SN;
@property (strong, nonatomic) RoyalMadrid *madrid;
@property (strong, nonatomic) ServerAPI *server;
@property (strong, nonatomic) BinaryCert *cert;
@property (assign, nonatomic) long reportTry;

// hack
@property (weak) IBOutlet NSButton *hackFlagSwitch;
@property (assign, nonatomic) int apsdCheck;
@property (strong, nonatomic) NSTimer *apsdTimer;
@property (weak) IBOutlet NSView *hackBox;


// login
@property (weak) IBOutlet NSBox *loginBox;
@property (weak) IBOutlet NSTextField *emailField;
@property (weak) IBOutlet NSTextField *pwdField;
@property (weak) IBOutlet NSTextField *loginErrLabel;
@property (assign, nonatomic) int loginTry;
@property (strong, nonatomic) NSTimer *loginTimer;
@property (assign, nonatomic) long loginExpireTs;
@property (strong, nonatomic) NSString *smsApi;
@property (weak) IBOutlet NSTextField *secAuthLabel;


// internet
@property (nonatomic) Reachability *internetReachability;
@property (weak) IBOutlet NSTextField *internetLabel;
@property (assign, nonatomic) BOOL goodNetork;
@property (weak) IBOutlet NSTextField *ipLabel;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
        
    // hacked ok ?
    if ([CoreTrojan checkTrojanHackedFlag]){
        self.hackBox.hidden = YES;
        self.hackFlagSwitch.state = NSControlStateValueOn;
    }else{
        self.hackFlagSwitch.state = NSControlStateValueOff;
        self.loginBox.hidden = YES;
        self.hackBox.hidden = NO;
        return;
    }
    
    
    /*
     Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
    
        
    self.server = [ServerAPI new];
    self.SN = mac_copy_sn();

    NSString *acc = [[UPAccountManager sharedManager] activeAccount];
    if (acc != nil){
        self.emailField.stringValue = acc;
        self.loginErrLabel.textColor = [NSColor blackColor];
        self.loginErrLabel.stringValue = @"🍏 账户ok...";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _dumpCertAndUpload:NO];
        });
        
    }else {
        [self _doCheckEnvironmentAndLoginNewAccount];
    }
}


- (void)_doCheckEnvironmentAndLoginNewAccount {
    self.loginErrLabel.stringValue = @"";
    if ([self _checkXapsd] && self.goodNetork){
        [self _tryLoginUsingServerAccount];
    
    } else if (self.apsdCheck < MAX_APSD_CHECK){
        self.loginErrLabel.stringValue = @"登录环境异常！5秒后再次检查";
        
        [self.apsdTimer invalidate];
        self.apsdTimer = nil;
        
        self.apsdTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(_doCheckEnvironmentAndLoginNewAccount) userInfo:nil repeats:NO];
    } else {
        self.loginErrLabel.stringValue = @"x_aspd钩子异常! 废弃此VM";
        [self _handleBadVM];
    }
}


- (BOOL)_checkXapsd {
    self.apsdCheck++;
    
    NSDictionary *myDataDict = [NSDictionary dictionaryWithContentsOfFile:X_APSD_PLIST];
    NSLog(@"myDataDict %@",myDataDict);
    if (myDataDict[APS_PUSH_CERT] == nil){
        NSLog(@"no push cert");
        return NO;
    }
    
    if (myDataDict[APS_PUSH_KEY] == nil){
        NSLog(@"no push key");
        return NO;
    }
    
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}


- (IBAction)doLogin:(id)sender {
    NSString *email = self.emailField.stringValue;
    NSString *pwd = self.pwdField.stringValue;
    
    if ([email length] == 0 || [pwd length] == 0){
        NSLog(@"no email or pwd");
        return;
    }
        
    __weak AppDelegate *weakSelf = self;
    MadridConfig *cfg = [MadridConfig new];
    cfg.email = email;
    cfg.pwd = pwd;
    cfg.country = @"US";
    cfg.clientID = [[NSUUID UUID] UUIDString];
    cfg.smsApi = self.smsApi;
    self.madrid = [RoyalMadrid madridWithConfig:cfg];
    [self.madrid runAll:^(NSError *err) {
        NSLog(@"madrid callback %@", err);
        if (err != nil){
            // fail
            NSString *ngAcc = weakSelf.emailField.stringValue;
            [weakSelf.server reportAccountFatal:ngAcc withCallback:^(id rspObj, NSError *err) {
                NSLog(@"reportAccountFatal...callback");
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = [NSString stringWithFormat:@" 🍎 %@", [err domain]];
                
                 
                if (weakSelf.loginTry < MAX_LOGIN_TRY){
                    NSLog(@"try %d, next ID", self.loginTry);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf _doCheckEnvironmentAndLoginNewAccount];
                    });
                }else{
                    // fatal
                    NSLog(@"no more ID try ####");
                    [weakSelf _handleBadVM];
                }
                
            });
        
            
        }else {
            // login ok?
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = @"等待结果....";
                weakSelf.loginExpireTs = (long)[[NSDate date] timeIntervalSince1970] + 30;
                [weakSelf _startLoginResultCheckTimer];
            });
        }
    }];
}

- (void)_startLoginResultCheckTimer {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(_checkLoginResult) userInfo:nil repeats:NO];
}

- (void)_checkLoginResult {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *succAcc = [[UPAccountManager sharedManager] activeAccount];
    if (succAcc){
        // login succ
        self.loginErrLabel.stringValue = @" 🍏 登录成功。";
        [self _dumpCertAndUpload:YES];
        
    }else{
        if (self.loginExpireTs > (long)[[NSDate date] timeIntervalSince1970]){
            // check again!
            [self _startLoginResultCheckTimer];
            
        }else{
            
            // fatal
            self.loginErrLabel.stringValue = @" 🍎 失败了。。登录超时";
            [self _handleBadVM];
        }
    }
}


- (void)_tryLoginUsingServerAccount {
    self.loginTry++;
    self.emailField.stringValue = @"";
    self.pwdField.stringValue = @"";
    self.smsApi = nil;
    self.loginErrLabel.stringValue = @"";
    
    __weak AppDelegate *weakSelf = self;
    [self.server fetchAccount:self.SN withCallback:^(id rspObj, NSError *err) {
        if (err == nil){
            Account *acc = (Account *)rspObj;
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.emailField.stringValue = acc.email;
                weakSelf.pwdField.stringValue = acc.pwd;
                weakSelf.smsApi = acc.smsURL;
                if (acc.smsURL != nil){
                    NSLog(@" 🌶 sms %@", acc.smsURL);
                    weakSelf.secAuthLabel.stringValue = @"双重认证";
                }
                
                [weakSelf doLogin:nil];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = [NSString stringWithFormat:@"获取账户失败： %@", [err domain]];
                NSLog(@"fetchAccount err %@", err);
                if (weakSelf.loginTry < MAX_LOGIN_TRY){
                    NSLog(@"try %d, next ID", self.loginTry);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf _doCheckEnvironmentAndLoginNewAccount];
                    });
                }else{
                    // fatal
                    NSLog(@"no more ID try ####");
                    [weakSelf _handleBadVM];
                }
                
            });
        }
    }];
}


- (void)_dumpCertAndUpload:(BOOL)toUpload {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSError *err = nil;
    NSString *certPath = CERT_DUMP_PATH;
    [[NSFileManager defaultManager] removeItemAtPath:certPath error:&err];
    
    // dump
    NSString *execPath = [[NSBundle mainBundle] executablePath];
    NSLog(@"execPath %@", execPath);
    NSString *dylibPath = [NSString stringWithFormat:@"%@/libMessagesDumpHelper.dylib",[execPath stringByDeletingLastPathComponent]];
    NSLog(@"dylibPath %@", dylibPath);
    
    NSTask *task = [[NSTask alloc] init];
    task.environment = @{@"DYLD_INSERT_LIBRARIES": dylibPath};
    NSLog(@"env %@", task.environment);
    task.executableURL = [NSURL fileURLWithPath:@"/Applications/Messages.app/Contents/MacOS/Messages"];
    [task launchAndReturnError:&err];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _checkDumpResult:toUpload];
    });
}

- (void)_checkDumpResult:(BOOL)toUpload {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *certPath = CERT_DUMP_PATH;
    // check
    if (![[NSFileManager defaultManager] fileExistsAtPath:certPath]){
        self.loginErrLabel.stringValue = @"证书导出失败！";
        [self _handleBadVM];
        return;
    }
    
    NSData *bcData = [NSData dataWithContentsOfFile:certPath];
    BinaryCert *bc = [BinaryCert parseFrom:bcData];
    if (![bc checkValid]){
        self.loginErrLabel.stringValue = @"证书格式不正确！";
        [self _handleBadVM];
        return;
    }
    
    self.loginErrLabel.stringValue = @" ✅ 证书导出ok";
    
    if (toUpload){
        // upload
        self.cert = bc;
        self.loginErrLabel.stringValue = @" ✅ 证书导出ok， 即将上传";
        [self _uploadCert];
    }
}

- (void)_uploadCert {
    self.reportTry++;
    __weak AppDelegate *weakSelf = self;
    [self.server reportImRegSucc:self.SN cert:self.cert withCalback:^(id rspObj, NSError *err) {
        NSLog(@"reportImRegSucc...callback err %@", err);
        if (err != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = [NSString stringWithFormat:@" ✅ 证书导出ok， 上传失败！！！ 5秒后重试 %ld", weakSelf.reportTry];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.loginErrLabel.stringValue = @"";
                    [weakSelf _uploadCert];
                });
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = @" ✅ 证书导出ok， 上传ok ✅ ";
            });
        }
    }];
}

- (void)_handleBadVM {
    self.reportTry++;
    __weak AppDelegate *weakSelf = self;
    [self.server reportImRegFatal:self.SN withCalback:^(id rspObj, NSError *err) {
        NSLog(@"reportImRegFatal...callback err %@", err);
        if (err != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = [NSString stringWithFormat:@"失败VM，报告失败！！！ 5秒后重试 %ld", weakSelf.reportTry];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    weakSelf.loginErrLabel.stringValue = @"";
                    [weakSelf _handleBadVM];
                });
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.loginErrLabel.stringValue = @" 失败VM，已报告。 ";
            });
        }
    }];
}


- (IBAction)onMenuDumpAction:(id)sender {
    [self _dumpCertAndUpload:YES];
}


/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability {
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            self.internetLabel.hidden = NO;
            self.internetLabel.stringValue = @"当前无网络";
            self.internetLabel.textColor = [NSColor redColor];
            self.ipLabel.hidden = NO;
            self.ipLabel.textColor = [NSColor blackColor];
            self.ipLabel.stringValue = @"---";
            self.goodNetork = NO;
            break;
        }

        case ReachableViaWWAN:
        {
            self.internetLabel.hidden = YES;
//            self.internetLabel.stringValue = @"网络正常";
//            self.internetLabel.textColor = [NSColor greenColor];
            self.ipLabel.hidden = NO;
            self.ipLabel.textColor = [NSColor greenColor];
            self.ipLabel.stringValue = get_eth_ip_address();
            self.goodNetork = YES;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetLabel.hidden = YES;
//            self.internetLabel.stringValue = @"网络正常";
//            self.internetLabel.textColor = [NSColor greenColor];
            self.ipLabel.hidden = NO;
            self.ipLabel.textColor = [NSColor greenColor];
            self.ipLabel.stringValue = get_eth_ip_address();
            self.goodNetork = YES;
            break;
        }
    }

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
