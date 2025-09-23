#import "../common/defines.h"
#import "../common/log.h"
#import <notify.h>

%group x_buddy

// x-headers
@interface BuddyUpdateFinishedController : NSObject
- (void)done;
- (void)_buttonPressed:(id)arg1;
- (id)buttonAtIndex:(unsigned long long)arg1;
@end

@interface BuddyFinishedController : NSObject
- (void)done;
@end

@interface BuddyPhoneNumberPermissionController : NSObject
- (void)controllerDone;
@end

@interface SetupController : NSObject
+ (id)sharedSetupController;
@end

@interface BuddyAppleIDHostController : NSObject
- (void)appleIDControllerFinished:(BOOL)arg1;
@end

%hook BuddyUpdateFinishedController

- (void)loadActualView {
    %orig;
    if([self respondsToSelector:@selector(done)]){
        [self performSelector:@selector(done)];
    }
}

- (void)loadView{
    %orig;
    id button = [self buttonAtIndex:0];
    if(button != nil){
      [self _buttonPressed:button];
    }
}

- (void)viewDidAppear:(bool)arg1{
    %orig;
    id button = [self buttonAtIndex:0];
    if(button != nil){
      [self _buttonPressed:button];
    }
}

%end // hook BuddyUpdateFinishedController

%hook BuddyAppleIDHostController

- (void)controllerWasPopped{
    %orig;
    [self appleIDControllerFinished:true];
}

%end


%hook BuddyMesaEnrollmentController

+ (_Bool)controllerNeedsToRun{
   I(@"BuddyMesaEnrollmentController controllerNeedsToRun");
   return NO;
}

- (void)viewWillAppear:(_Bool)arg1 {
    %orig;
    SetupController *c = [%c(SetupController) sharedSetupController];
    if([c respondsToSelector:@selector(_finishBuddy)]){
        [c performSelector:@selector(_finishBuddy)];
    }
}

%end // hook BuddyMesaEnrollmentController

%hook BuddyFinishedController

- (void)loadActualView {
    %orig;
    if([self respondsToSelector:@selector(done)]){
        [self performSelector:@selector(done)];
    }
}

%end // hook BuddyFinishedController


%hook BuddyPhoneNumberPermissionController

+ (_Bool)controllerNeedsToRun{
   I(@"BuddyPhoneNumberPermissionController controllerNeedsToRun");
   return NO;
}

%end  // hook BuddyPhoneNumberPermissionController

%hook BuddyPasscodeController

+ (_Bool)controllerNeedsToRun{
   I(@"BuddyPasscodeController controllerNeedsToRun");
   return NO;
}

%end // hook BuddyPasscodeController

%hook BuddyActivationEngine

%new
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    I(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSURLProtectionSpace *ps = challenge.protectionSpace;
    I(@"challenge host: %@", ps.host);  
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:trust];
    completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
}

%end

%end // group x_buddy


%ctor {
    NSProcessInfo *pInfo = [NSProcessInfo processInfo];
    if ([@"Setup" isEqualToString:[pInfo processName]]){
        I(@"----- init IB.Mad for process %@ (pid %d) -----", [pInfo processName], [pInfo processIdentifier]);
        %init(x_buddy);
    }
}