#import  <notify.h>
#import "../common/defines.h"
#import "../common/log.h"
#import "../src/Device.h"
#import <Security/Security.h>
#import <Foundation/Foundation.h>

%hook MobileActivationDaemon

- (void)getActivationStateWithCompletionBlock:(void (^)(NSDictionary *, NSError *))origCallback {
    I(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));  
    // void (^myCallBack)(NSDictionary *, NSError *) = ^(NSDictionary *dict, NSError *err){
    //     NSLog(@" ##### my getActivationStateWithCompletionBlock callback #######");
    //     NSLog(@" dict %@", dict);
    //     NSLog(@" err %@", err);
    //     origCallback(dict, err);
    // };
    // %orig(myCallBack);
    if (![[Device shared] isReady]){
        NSLog(@" ##### device in orig state");
        %orig;
    }else {
        NSDictionary *fakeState = @{ @"ActivationState" : @"Activated" };
        origCallback(fakeState, nil);
        NSLog(@" ##### hack to Activated state, %@", fakeState);
    }
}

%end // hook MobileActivationDaemon



%ctor {
    NSProcessInfo *pInfo = [NSProcessInfo processInfo];
    I(@"----- init EH.Mad for process %@ (pid %d) -----", [pInfo processName], [pInfo processIdentifier]);

    MSImageRef image;
    image = MSGetImageByName("/System/Library/Frameworks/Security.framework/Security");
    NSLog(@"sec image %p", image);

    void *ptr_SecIdentityCreate =  MSFindSymbol(image, "_SecIdentityCreate"); 
    if (ptr_SecIdentityCreate != NULL){
        NSLog(@"found _SecIdentityCreate");
        hackSecIdentityCreate = (SecIdentityRef *(*)(CFAllocatorRef, SecCertificateRef, SecKeyRef))ptr_SecIdentityCreate;
    }
}