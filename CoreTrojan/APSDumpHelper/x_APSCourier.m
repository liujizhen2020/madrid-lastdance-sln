//
//  x_APSCourier.m
//  APSDumpHelper
//
//  Created by yt on 31/08/23.
//

#import "x_APSCourier.h"
#import "APSDumpHelper.h"
#import <objc/runtime.h>

typedef void (*OriginalImpType)(id self, SEL selector, NSData *token, NSString *tn);
static OriginalImpType originalImp;

@implementation x_APSCourier

/* @class APSCourier */
//-(void)setPublicToken:(NSData *)token forTokenName:(NSString *)tn;


-(void)x_setPublicToken:(NSData *)token forTokenName:(NSString *)tn {
    NSLog(@" 🍎 my_setPublicToken %@ forTokenName %@", token, tn);
    helper_save_data(tn, token);
    originalImp(self, @selector(setPublicToken:forTokenName:), token, tn);
}

@end

static __attribute__((constructor)) void init_x_APSCourier()
{
    hack_log(@"init_x_APSCourier <<<<<<<<<<<<<<<<<<");
    
    Class akCls = objc_getClass("APSCourier");
    hack_log(@"APSCourier class %p", akCls);
    Method origMth = class_getInstanceMethod(akCls, @selector(setPublicToken:forTokenName:));
    hack_log(@"setPublicToken:forTokenName: origMth %p", origMth);
    originalImp = (OriginalImpType)method_getImplementation(origMth);
    
    Method myMth = class_getInstanceMethod([x_APSCourier class], @selector(x_setPublicToken:forTokenName:));
    hack_log(@"setPublicToken:forTokenName: myMth %p", myMth);
    method_exchangeImplementations(origMth, myMth);
    hack_log(@"setPublicToken:forTokenName: method exchange ok");
}
