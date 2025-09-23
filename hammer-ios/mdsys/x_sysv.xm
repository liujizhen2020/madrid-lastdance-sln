#import <CoreFoundation/CoreFoundation.h>
#import <CydiaSubstrate.h>
#import <Foundation/Foundation.h>

static CFDictionaryRef(*orig_CFCopySystemVersionDictionary)(void);
CFDictionaryRef my_CFCopySystemVersionDictionary() {
	CFDictionaryRef cfDict = (CFDictionaryRef)orig_CFCopySystemVersionDictionary();
	CFMutableDictionaryRef ret = CFDictionaryCreateMutableCopy(CFAllocatorGetDefault(), 0, cfDict);
	CFDictionarySetValue(ret,CFSTR("ProductVersion"),CFSTR("18.4.1"));
	CFDictionarySetValue(ret,CFSTR("ProductBuildVersion"),CFSTR("22E252"));
	CFDictionarySetValue(ret,CFSTR("FullVersionString"),CFSTR("Version 18.4.1 (Build 22E252)"));
	return (CFDictionaryRef)ret;
}

%ctor {
    MSImageRef image;
    image = MSGetImageByName("/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation'");
    NSLog(@"ct image %p", image);

	void *ptr_CFCopySystemVersionDictionary =  MSFindSymbol(image, "__CFCopySystemVersionDictionary"); 
	if (ptr_CFCopySystemVersionDictionary != NULL){
        NSLog(@"found __CFCopySystemVersionDictionary");
	    MSHookFunction((void*)ptr_CFCopySystemVersionDictionary, (void*)my_CFCopySystemVersionDictionary, (void**)&orig_CFCopySystemVersionDictionary);
	}

}