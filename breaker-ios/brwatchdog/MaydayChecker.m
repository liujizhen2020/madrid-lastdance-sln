#import "MaydayChecker.h"
#import "../common/defines.h"
#import "../src/nk_run_cmd.h"

@implementation MaydayChecker

- (void)check {
    [self _doCheck];
}

- (void)_doCheck {
    NSLog(@"~~~~~~~~~ do check ~~~~~~~~~");
    if (![[NSFileManager defaultManager] fileExistsAtPath:LAST_RESET_PATH]){
        NSLog(@"LAST_RESET_PATH >>>> File is nil ");
        return;
    }
    NSDictionary *lastResetDict = [NSDictionary dictionaryWithContentsOfFile:LAST_RESET_PATH];
    NSLog(@"LAST_RESET_DATA >>>> %@",lastResetDict);
    if(lastResetDict[@"T"] == nil){
        NSLog(@"LAST_RESET_DATA >>>> T is nil ");
        return;
    }
    NSDate *lastResetTime = lastResetDict[@"T"];
    long nowTs = (long)[[NSDate date] timeIntervalSince1970];
    long resetTs = (long)[lastResetTime timeIntervalSince1970];
    if(nowTs - resetTs >= (60*10) ){  //10 minus
        [self _tryRecover];
    } 
}

- (void)_tryRecover {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));   
    // jb fix
    // nk_run_cmd("killall -9 substrated");
    // nk_run_cmd("rm -fr /tmp/SubstrateProxyer-*");

    // restart daemon
    nk_run_cmd("killall -9 MDDaemon");
    nk_run_cmd("launchctl unload /Library/LaunchDaemons/madrid.plist");
    nk_run_cmd("launchctl load /Library/LaunchDaemons/madrid.plist");
    
    // re-spring
    nk_run_cmd("killall -9 SpringBoard");
}


@end
