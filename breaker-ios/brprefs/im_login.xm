#import <Foundation/Foundation.h>

#import "../src/IMAutoLoginHelper.h"


@interface PSAppleIDSplashViewController : NSObject
- (id)_specifierForLoginPasswordForm;
- (id)_specifierForLoginUserForm;
- (void)_setPassword:(id)arg1 withSpecifier:(id)arg2;
- (void)_setUsername:(id)arg1 withSpecifier:(id)arg2;
- (void)_signInWithUsername:(id)arg1 password:(id)arg2;
- (void)showBusyUI;
- (void)hideBusyUI;
- (void)reloadSpecifiers;

- (id)title;
- (void)setTitle:(id)arg1;

@end

%hook PSAppleIDSplashViewController

- (void)viewDidLoad {
    NSLog(@" 🔫 %@", NSStringFromSelector(_cmd));
    %orig;

    if (![[IMAutoLoginHelper sharedInstance] checkReady]){
        NSLog(@" 🔫 -------------- do nothing ---------------");
    }else{
        if ([[IMAutoLoginHelper sharedInstance] hasTriggered]){
            NSLog(@" 🔫 ===== have hasTriggered, do nothing now ========");
            return;
        }

        // trigger once
        [[IMAutoLoginHelper sharedInstance] markTriggered];
        
        NSLog(@" 🔫 ===== 输入框模式，开始登录IM ========");

        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC); 
        dispatch_after(time,dispatch_get_main_queue(),^{ 

            NSString *user = [[IMAutoLoginHelper sharedInstance] username];
            NSString *pwd = [[IMAutoLoginHelper sharedInstance] password];

            [self _setUsername:user withSpecifier:[self _specifierForLoginUserForm]];
            // [self _setPassword:pwd withSpecifier:[self _specifierForLoginPasswordForm]];
            [self reloadSpecifiers];

            [self _signInWithUsername:user password:pwd];

        });
    }
}

%end // hook PSAppleIDSplashViewController


%hook NSBundle
- (NSString *)localizedStringForKey:(NSString *)key  value:(NSString *)value  table:(NSString *)tableName {
    
    if ([@"VERIFYING_TITLE" isEqualToString:key]){
        return @" 🚗 拼命登录中...";
    }

    return %orig;                      
}

%end // hook NSBundle