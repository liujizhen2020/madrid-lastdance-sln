//
//  x_SecKeyCreatePair.m
//  APSDumpHelper
//
//  Created by yt on 31/08/23.
//

#import "x_SecKeyCreatePair.h"
#import "APSDumpHelper.h"
#import "fishhook.h"
#import "Security/Security.h"

static OSStatus (*orig_SecKeyCreatePair)(SecKeychainRef, CSSM_ALGORITHMS,uint32,CSSM_CC_HANDLE,CSSM_KEYUSE,uint32,CSSM_KEYUSE,uint32,SecAccessRef,SecKeyRef*,SecKeyRef*);


OSStatus x_SecKeyCreatePair(SecKeychainRef keychainRef,
       CSSM_ALGORITHMS algorithm,
       uint32 keySizeInBits,
       CSSM_CC_HANDLE contextHandle,
       CSSM_KEYUSE publicKeyUsage,
       uint32 publicKeyAttr,
       CSSM_KEYUSE privateKeyUsage,
       uint32 privateKeyAttr,
       SecAccessRef initialAccess,
       SecKeyRef  _Nullable *publicKey,
       SecKeyRef  _Nullable *privateKey);


OSStatus x_SecKeyCreatePair(SecKeychainRef keychainRef,
       CSSM_ALGORITHMS algorithm,
       uint32 keySizeInBits,
       CSSM_CC_HANDLE contextHandle,
       CSSM_KEYUSE publicKeyUsage,
       uint32 publicKeyAttr,
       CSSM_KEYUSE privateKeyUsage,
       uint32 privateKeyAttr,
       SecAccessRef initialAccess,
       SecKeyRef  _Nullable *publicKey,
       SecKeyRef  _Nullable *privateKey) {
    
    NSLog(@" 🍎 my_SecKeyCreatePair");
    uint32 my_PrivateKeyAttr = CSSM_KEYATTR_RETURN_REF | CSSM_KEYATTR_PERMANENT | CSSM_KEYATTR_EXTRACTABLE;
    hack_log(@"old privateKeyAttr 0x%x",privateKeyAttr);
    hack_log(@"my privateKeyAttr 0x%x",my_PrivateKeyAttr);
    
    OSStatus ret = orig_SecKeyCreatePair(keychainRef,algorithm, keySizeInBits,contextHandle,publicKeyUsage,publicKeyAttr,privateKeyUsage,
                                         my_PrivateKeyAttr,
                        initialAccess,publicKey,privateKey);
    hack_log(@"orig_SecKeyCreatePair ret = %d, %@", ret, SecCopyErrorMessageString(ret,NULL));
    if (ret == errSecSuccess){
        CFErrorRef cfErr;
        CFDataRef cfPushKey = SecKeyCopyExternalRepresentation(*privateKey, &cfErr);
        hack_log(@"push key data %@", (__bridge NSData *)cfPushKey);
        
        if (cfPushKey == nil){
            // dump push key fail, let `apsd` re-generate key pair.
            NSLog(@"Fail to dump push private key....");
            return errSecUserCanceled;
        }
        
        helper_save_data(APS_PUSH_KEY, (__bridge NSData *)cfPushKey);
        CFRelease(cfPushKey);
    }
    
    return ret;
}


static __attribute__((constructor)) void init_x_SecKeyCreatePair()
{
    hack_log(@"init_x_SecKeyCreatePair");
    rebind_symbols((struct rebinding[1]){
        {"SecKeyCreatePair", x_SecKeyCreatePair, (void *)&orig_SecKeyCreatePair},
    }, 1);
}
