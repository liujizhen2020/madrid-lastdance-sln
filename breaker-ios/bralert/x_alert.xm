#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../common/log.h"
#import "../common/defines.h"
#import "PasscodeManager.h"
#import  <notify.h>

@interface UIAlertController()
- (void)nk_clickAction:(id)act;
@end

@interface RUIChoiceViewElement:NSObject
- (void)choiceView:(id)arg1 tappedChoiceAtIndex:(unsigned long long)arg2;
@end

@interface RUIPage :NSObject
- (id)navTitle;
- (id)primaryElement;
- (void)_middleToolbarButtonPressed:(BOOL)arg1;
@end

@interface CNFRegLocaleController:NSObject
- (void)setCurrentRegionID:(id)arg1;
- (void)_rightButtonTapped;
@end

%hook UIAlertController

- (void)viewDidAppear:(BOOL)animated {
	I(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	%orig;

	NSString *alertTitle = [self title];
	I(@"MD/////////// alert title is \"%@\"", alertTitle);
	NSString *alertMessage = [self message];
	I(@"MD/////////// alert message is \"%@\"", alertMessage);
	NSArray *alertActions = [self actions];
	I(@"MD/////////// alert alertActions are \"%@\"", alertActions);
	if([alertTitle isEqualToString:@"Apple ID Verification"] || [alertTitle isEqualToString:@"验证 Apple ID"]){
		for (id act in alertActions){
			NSString *actTitle = [act title];
			if ([@"Not Now" isEqualToString: actTitle] || [@"以后" isEqualToString: actTitle]){
				[self nk_clickAction:act];
				I(@"clicked Not Now");
				break;
			}
		}
		return;
	}
	if([alertTitle isEqualToString:@"Apple ID Locked"] || [alertTitle isEqualToString:@"Apple ID 已锁定"]){ //锁定
		for (id act in alertActions){
			NSString *actTitle = [act title];
			if ([@"Cancel" isEqualToString: actTitle] || [@"取消" isEqualToString: actTitle]){
				[self nk_clickAction:act];
				I(@"clicked Not Now");
				break;
			}
		}
		notify_post(NOTIFY_APPLE_ID_LOCKED); 
		return;
	}
	if([alertTitle isEqualToString:@"Verification Failed"] || [alertTitle isEqualToString:@"验证失败"]){     //停用
		BOOL isFatal = NO;
		BOOL isLock = NO;
		if([alertMessage containsString:@"active"] || [alertMessage containsString:@"停用"]){
			isFatal = YES;
		}
		if([alertMessage containsString:@"locked"] || [alertMessage containsString:@"锁定"]){
			isLock = YES;
		}
		for (id act in alertActions){
			NSString *actTitle = [act title];
			if ([@"OK" isEqualToString: actTitle] || [@"好" isEqualToString: actTitle]){
				[self nk_clickAction:act];
				I(@"clicked Not Now");
				break;
			}
		}
		if(isLock){
			notify_post(NOTIFY_APPLE_ID_LOCKED); 
		}else if(isFatal){
			notify_post(NOTIFY_APPLE_ID_FATAL); 
		}else{
			notify_post(NOTIFY_ENV_FATAL);
		}
		
		return;
	}
	if([alertTitle isEqualToString:@"Cannot Verify Phone Number"] || [alertTitle isEqualToString:@"无法验证电话号码"]){     //抽风
		for (id act in alertActions){
			NSString *actTitle = [act title];
			if ([@"OK" isEqualToString: actTitle] || [@"好" isEqualToString: actTitle]){
				[self nk_clickAction:act];
				I(@"clicked Not Now");
				break;
			}
		}
		return;
	}
	if([alertTitle isEqualToString:@"iMessage Activation"] || [alertTitle isEqualToString:@"激活 iMessage 信息"]){     //停用
		for (id act in alertActions){
			I(@"act title:%@",[act title]);
			NSString *actTitle = [act title];
			if ([@"OK" isEqualToString: actTitle] || [@"好" isEqualToString: actTitle]){
				[self nk_clickAction:act];
				I(@"clicked Not Now");
				break;
			}
		}
		return;
	}
	if ([alertTitle isEqualToString:@"Not a Chinese citizen residing in the mainland of China?"] || [alertTitle isEqualToString:@"不是居住在中国大陆的中国公民？"]){
		for (id act in alertActions){
			I(@"act title:%@",[act title]);
			NSString *actTitle = [act title];
			if ([@"Continue Without Number" isEqualToString: actTitle] || [@"不添加号码并继续" isEqualToString: actTitle]){
				[self nk_clickAction:act];
				I(@"clicked Not Now");
				break;
			}
		}
		return;
	}
}


%new 
- (void)nk_clickAction:(id)act {
	if ([self respondsToSelector:@selector(_dismissWithAction:)]){
		[self performSelector:@selector(_dismissWithAction:) withObject:act];
		return;
	}
}

%end // hook UIAlertController

%hook RUIPage

- (void)viewDidAppear:(bool)arg1{
	I(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	%orig;
	NSString *navTitle = [self navTitle];
	I(@"RUIPage navTitle:%@",navTitle);
	if (navTitle && [@"验证码" isEqualToString:navTitle]){
		I(@"RUIPage 提示需要验证码");
		return;
	}
	if (navTitle && [@"双重认证" isEqualToString:navTitle]){
		I(@"RUIPage 提示需要双重");
		if(![[PasscodeManager shared] shouldPasscode]){
			notify_post(NOTIFY_APPLE_ID_FATAL); 
		}
		return;
	}
	if (navTitle && ([@"Apple 和你的数据隐私" isEqualToString:navTitle] || [@"云上贵州和你的数据隐私" isEqualToString:navTitle] || [@"Apple ID 更新" isEqualToString:navTitle])){
		I(@"RUIPage 提示 需要同意并继续");
		id priElem = [self primaryElement];
		if (priElem){
			NSString *clsName = NSStringFromClass([priElem class]);
			if ([@"RUIChoiceViewElement" isEqualToString:clsName]){
				RUIChoiceViewElement *elem = priElem;
				[elem choiceView:elem tappedChoiceAtIndex:0]; 
			}
		}
		return;
	}
	if (navTitle && [@"电话号码" isEqualToString:navTitle]){
		I(@"RUIPage 提示需要电话号码");
		[self _middleToolbarButtonPressed:YES];
		return;
	}

	if (navTitle && [@"验证电话号码" isEqualToString:navTitle]){
		I(@"RUIPage 验证电话号码");
	}
}

%end




%hook RUIPasscodeView

- (void)viewDidAppear:(bool)arg1{
	I(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	%orig;
	if(![[PasscodeManager shared] shouldPasscode]){
		I(@"%@ %@ sec direct",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
		return;
	}
	[PasscodeManager shared].passcodeView = self;
	[[PasscodeManager shared] startWork];
}
	

%end


%hook CNFRegLocaleController

- (void)viewWillAppear:(bool)arg1{
	I(@"CNFRegLocaleController region:r:us");
	%orig;
	[self setCurrentRegionID:@"R:US"];
	dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC); 
        dispatch_after(time,dispatch_get_main_queue(),^{ 
           [self _rightButtonTapped];
    });
}

%end
