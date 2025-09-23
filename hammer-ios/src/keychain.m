#import "keychain.h"

int 
kc_get_data(CFStringRef cls, CFStringRef svs, CFStringRef acc, CFStringRef grp, CFDataRef *out) 
{
    // NSLog(@"kc_get_data: class %@ service %@ account %@ group %@", (__bridge NSString *)cls, (__bridge NSString *)svs, (__bridge NSString *)acc, (__bridge NSString *)grp);
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (cls){
        CFDictionaryAddValue(mQuery, kSecClass, cls);
    }
    if (svs){
        CFDictionaryAddValue(mQuery, kSecAttrService, svs);
    }
    if (acc){
        CFDictionaryAddValue(mQuery, kSecAttrAccount, acc);
    }
    if (grp){
        CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, grp);
    }
    CFDictionaryAddValue(mQuery, kSecReturnData, kCFBooleanTrue);
    CFDataRef cfVal;
    OSStatus ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&cfVal);        
    if (ret != errSecSuccess){
        NSLog(@"--> kc_get_data: Err ret %d", ret);
        CFRelease(mQuery);
        return -1;
    }
    // NSLog(@"kc_get_data: got %ld bytes, %@", CFDataGetLength(cfVal), (__bridge NSData *)cfVal);
    *out = cfVal;
    return 0;
}

int 
kc_set_data(CFStringRef cls, CFStringRef svs, CFStringRef acc, CFStringRef grp, CFDataRef in)
{
    // NSLog(@"kc_set_data: class %@ service %@ account %@ group %@", (__bridge NSString *)cls, (__bridge NSString *)svs, (__bridge NSString *)acc, (__bridge NSString *)grp);
    // NSLog(@"kc_set_data: data %ld bytes, %@", CFDataGetLength(in), (__bridge NSData *)in);
    // NSLog(@"kc_set_data: data %ld bytes", CFDataGetLength(in));
    // reg data
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (cls){
        CFDictionaryAddValue(mQuery, kSecClass, cls);
    }
    if (svs){
        CFDictionaryAddValue(mQuery, kSecAttrService, svs);
    }
    if (acc){
        CFDictionaryAddValue(mQuery, kSecAttrAccount, acc);
    }
    if (grp){
        CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, grp);
    }
    if (in){
        CFDictionarySetValue(mQuery, kSecValueData, in);
    }
    OSStatus ret = SecItemAdd(mQuery, NULL);
    CFRelease(mQuery);
    if (ret == errSecSuccess){
        // ok
        //NSLog(@"kc_set_data: OK");
        return 0;
    }else {
        NSLog(@"kc_set_data: Err ret %d", ret);
        return -1;
    }
}

int 
kc_remove_data(CFStringRef cls, CFStringRef svs, CFStringRef acc, CFStringRef grp)
{
    //NSLog(@"kc_remove_data: class %@ service %@ account %@ group %@", (NSString *)cls, (NSString *)svs, (NSString *)acc, (NSString *)grp);
    // reg data
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (cls){
        CFDictionaryAddValue(mQuery, kSecClass, cls);
    }
    if (svs){
        CFDictionaryAddValue(mQuery, kSecAttrService, svs);
    }
    if (acc){
        CFDictionaryAddValue(mQuery, kSecAttrAccount, acc);
    }
    if (grp){
        CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, grp);
    }
    OSStatus ret = SecItemDelete(mQuery);
    CFRelease(mQuery);
    if (ret == errSecSuccess || ret == errSecItemNotFound){
        // ok
        //NSLog(@"kc_remove_data: OK");
        return 0;
    }else {
        NSLog(@"kc_remove_data, Err ret %d", ret);
        return -1;
    }
}