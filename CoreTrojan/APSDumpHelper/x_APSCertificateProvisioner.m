//
//  x_APSCertificateProvisioner.m
//  APSDumpHelper
//
//  Created by yt on 31/08/23.
//

#import "x_APSCertificateProvisioner.h"
#import "APSDumpHelper.h"
#import <objc/runtime.h>

typedef NSData* (*OriginalImpType)(id self, SEL selector, NSString *cn, SecCertificateRef cert);
static OriginalImpType originalImp;


@implementation x_APSCertificateProvisioner

/* @class APSCertificateProvisioner */
//-(void)renameCertKeys:(void *)arg2 certificate:(struct __SecCertificate *)arg3

-(void)x_renameCertKeys:(NSString *)commonName certificate:(SecCertificateRef)cert {
    NSLog(@" 🍎 my_renameCertKeys:certificate:");
    helper_save_data(APS_PUSH_CERT, (__bridge NSData *)SecCertificateCopyData(cert));
    originalImp(self, @selector(renameCertKeys:certificate:), commonName, cert);
}

@end


static __attribute__((constructor)) void init_x_APSCertificateProvisioner()
{
    hack_log(@"init_x_APSCertificateProvisioner <<<<<<<<<<<<<<<<<<");
    Class akCls = objc_getClass("APSCertificateProvisioner");
    hack_log(@"APSCertificateProvisioner class %p", akCls);
    Method origMth = class_getInstanceMethod(akCls, @selector(renameCertKeys:certificate:));
    hack_log(@"renameCertKeys:certificate: origMth %p", origMth);
    originalImp = (OriginalImpType)method_getImplementation(origMth);
    
    Method myMth = class_getInstanceMethod([x_APSCertificateProvisioner class], @selector(x_renameCertKeys:certificate:));
    hack_log(@"renameCertKeys:certificate: myMth %p", myMth);
    method_exchangeImplementations(origMth, myMth);
    hack_log(@"renameCertKeys:certificate: method exchange ok");
}
