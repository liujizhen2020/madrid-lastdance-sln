#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Security/Security.h>

FOUNDATION_EXPORT int kc_get_data(CFStringRef cls, CFStringRef svs, CFStringRef acc, CFStringRef grp, CFDataRef *out);
FOUNDATION_EXPORT int kc_set_data(CFStringRef cls, CFStringRef svs, CFStringRef acc, CFStringRef grp, CFDataRef in);
FOUNDATION_EXPORT int kc_remove_data(CFStringRef cls, CFStringRef svs, CFStringRef acc, CFStringRef grp);
