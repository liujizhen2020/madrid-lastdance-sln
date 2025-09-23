#import <Foundation/Foundation.h>
#import "../src/IMAutoLoginHelper.h"


/*
  界面上，没有输入框，顶部是开关，
  点下面按钮才能开始登陆
*/

@interface CKSettingsMessagesController : NSObject
- (id)specifierForID:(id)arg1;
- (void)madridSigninTappedWithSpecifier:(id)arg1;
@end

%hook CKSettingsMessagesController


- (void)viewDidLoad {
    NSLog(@" 🔫 CKSettingsMessagesController %@", NSStringFromSelector(_cmd));
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

        NSLog(@" 🔫 ===== 点击： 用Apple ID登陆IM ========");
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC); 
        dispatch_after(time,dispatch_get_main_queue(),^{ 
            id spec = [self specifierForID:@"MADRID_SIGNIN_BUTTON"];
            [self madridSigninTappedWithSpecifier:spec];
        });
    }
}

%end // hook CKSettingsMessagesController


// ======================================================

@interface AKBasicLoginAlertController : NSObject
- (void)setUsername:(id)arg1;

- (id)childViewControllers;

- (id)preferredAction;
- (void)_dismissWithAction:(id)arg1;
@end


@interface _UIAlertControllerTextFieldViewController : NSObject
- (long long)numberOfTextFields;
- (id)textFieldAtIndex:(long long)arg1;
@end

@interface _UIAlertControllerTextField : NSObject
- (void)setText:(id)arg1; /* UITextField */
@end

%hook AKBasicLoginAlertController

- (void)viewDidLoad {
    NSLog(@" 🔫 AKBasicLoginAlertController %@", NSStringFromSelector(_cmd));
    %orig;

    if (![[IMAutoLoginHelper sharedInstance] checkReady]){
        NSLog(@" 🔫 -------------- do nothing ---------------");
    }else{
        NSLog(@" 🔫 ===== 自动输入，点击登录 ========");
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC); 
        dispatch_after(time,dispatch_get_main_queue(),^{ 
            NSString *user = [[IMAutoLoginHelper sharedInstance] username];
            NSString *pwd = [[IMAutoLoginHelper sharedInstance] password];

            [self setUsername:user];

            BOOL pwdDone = NO;
            NSArray *childs = [self childViewControllers];
            if ([childs count] > 1){
                _UIAlertControllerTextFieldViewController *fc = (_UIAlertControllerTextFieldViewController *)[childs objectAtIndex:1];
                if ([fc numberOfTextFields] > 1){
                    _UIAlertControllerTextField *f = [fc textFieldAtIndex:1];
                    [f setText:pwd];
                    pwdDone = YES;
                }
            }


            // go
            if (pwdDone){
                [self _dismissWithAction:[self preferredAction]];
            }

        });
    }
}

%end // hook AKBasicLoginAlertController

