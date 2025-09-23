#import <CoreFoundation/CoreFoundation.h>
#import <CydiaSubstrate.h>
#import <sys/utsname.h>
#import <dlfcn.h>
#import "../src/Device.h"
#import "../src/NSData+FastHex.h"

// static CFPropertyListRef (*orig_MGCopyAnswer)(CFStringRef prop);
// CFPropertyListRef my_MGCopyAnswer(CFStringRef prop) {
// 	CFPropertyListRef ret = orig_MGCopyAnswer(prop);
static CFPropertyListRef (*orig_MGCopyAnswer_internal)(CFStringRef prop, uint32_t* outTypeCode);
CFPropertyListRef my_MGCopyAnswer_internal(CFStringRef prop, uint32_t* outTypeCode) {
    NSLog(@"mg <%@>", (NSString *)prop);
    CFPropertyListRef ret = orig_MGCopyAnswer_internal(prop, outTypeCode);
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... orig_MGCopyAnswer");
        return ret;
    }		
	NSLog(@"mg *%@*", (NSString *)prop);

	// prop: SerialNumber
	if (CFEqual(prop, CFSTR("SerialNumber"))){
		NSString *v = [[Device shared] SN];
        if (v){
	    	NSLog(@"MGCopyAnswer ~~~ SN %@", v);
		    return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }

	}

    if (CFEqual(prop,CFSTR("VasUgeSzVyHdB27g2XpN0g"))) {
        NSString *v = [[Device shared] SN];
        if (v) {
            NSLog(@"MGCopyAnswer ~~~ VasUgeSzVyHdB27g2XpN0g %@",v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }
	
	// prop: UniqueDeviceID
	if (CFEqual(prop, CFSTR("UniqueDeviceID"))){
		NSString *v = [[Device shared] UDID];
        if (v){
		    NSLog(@"MGCopyAnswer ~~~ UDID %@", v);
		    return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
	}

	// prop: UniqueDeviceIDData
	if (CFEqual(prop, CFSTR("UniqueDeviceIDData"))){
		NSString *v = [[Device shared] UDID];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ UDID data %@", v);
            NSData *data = [NSData dataWithHexString:v];
            return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)data);
        }
	}

	// prop: UniqueChipID
	if (CFEqual(prop, CFSTR("UniqueChipID"))){
		NSData *ecidData = [[Device shared] ECIDData];
        if (ecidData){
            uint64_t decVal = *((uint64_t *)[ecidData bytes]);
            NSLog(@"MGCopyAnswer ~~~ ECID %llu", decVal);
            return (CFNumberRef)[NSNumber numberWithUnsignedLongLong:decVal];
        }
	}	

    if (CFEqual(prop, CFSTR("WifiAddress"))){
        NSString *v = [Device shared].WIFI;
        if (v){
            NSLog(@"MGCopyAnswer ~~~ WIFI %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("gI6iODv8MZuiP0IA+efJCw"))){
        NSString *v = [Device shared].WIFI;
        if (v){
            NSLog(@"MGCopyAnswer ~~~ gI6iODv8MZuiP0IA+efJCw %@",v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("eZS2J+wspyGxqNYZeZ/sbA"))){
        NSString *v = [Device shared].WIFI;
        if (v){
            NSString *d = [[v stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
            NSData *hexd = [NSData dataWithHexString:d];
            NSLog(@"MGCopyAnswer ~~~~ eZS2J+wspyGxqNYZeZ/sbA %@",hexd);
            return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexd);
        }
    }

    // prop: BluetoothAddress
    if (CFEqual(prop, CFSTR("BluetoothAddress"))){
        NSString *v = [Device shared].BT;
        if (v){
            NSLog(@"MGCopyAnswer ~~~ BT %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    } 

    if (CFEqual(prop,CFSTR("k5lVWbXuiZHLA17KGiVUAA"))){
        NSString *v = [Device shared].BT;
        if (v){
            NSLog(@"MGCopyAnswer ~~~ k5lVWbXuiZHLA17KGiVUAA %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        } 
    }
     
    if (CFEqual(prop,CFSTR("jSDzacs4RYWnWxn142UBLQ"))) {
        NSString *v = [Device shared].BT;
        if (v){
            NSString *d = [[v stringByReplacingOccurrencesOfString:@":" withString:@""] uppercaseString];
            NSData *hexd = [NSData dataWithHexString:d];
            NSLog(@"MGCopyAnswer ~~~ k5lVWbXuiZHLA17KGiVUAA %@",hexd);
            return CFDataCreateCopy(kCFAllocatorDefault, (CFDataRef)hexd); 
        } 
    }

    // prop: ProductType
    if (CFEqual(prop, CFSTR("ProductType"))){
        NSString *v = [[Device shared] PT];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ ProductType %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("ProductName"))) {
        NSString *v = [[Device shared] PT];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ ProductName %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("h9jDsbgj7xIVeIQ8S3/X3Q"))) {
        NSString *v = [[Device shared] PT];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ h9jDsbgj7xIVeIQ8S3/X3Q %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    // prop: MobileEquipmentIdentifier
    if (CFEqual(prop, CFSTR("MobileEquipmentIdentifier"))){
        NSString *v = [[Device shared] MEID];
        if(v){
            NSLog(@"MGCopyAnswer ~~~ MEID %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("xOEH0P1H/1jmYe2t54+5cQ"))) {
        NSString *v = [[Device shared] MEID];
        if(v){
            NSLog(@"MGCopyAnswer ~~~ xOEH0P1H/1jmYe2t54+5cQ %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    // prop: InternationalMobileEquipmentIdentity
    if (CFEqual(prop, CFSTR("InternationalMobileEquipmentIdentity"))){
        NSString *v = [[Device shared] IMEI];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ IMEI %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("QZgogo2DypSAZfkRW4dP/A"))) {
        NSString *v = [[Device shared] IMEI];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ IMEI %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("MLBSerialNumber"))) {
        NSString *v = [[Device shared] MLBSN];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ MLBSN %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop,CFSTR("Q1Ty5w8gxMWHx3p4lQ1fhA"))) {
        NSString *v = [[Device shared] MLBSN];
        if (v){
            NSLog(@"MGCopyAnswer ~~~ Q1Ty5w8gxMWHx3p4lQ1fhA %@", v);
            return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)v);
        }
    }

    if (CFEqual(prop, CFSTR("ProductVersion"))){
        NSString *version = @"22E252";
        return CFStringCreateCopy(kCFAllocatorDefault, (CFStringRef)version);
    }

	return ret;
}


Boolean (*orig_MGGetBoolAnswer)(CFStringRef);
Boolean my_MGGetBoolAnswer(CFStringRef mgname){
    Boolean res = orig_MGGetBoolAnswer(mgname);
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... my_MGGetBoolAnswer");
        return res;
    }  
    NSString *keyStr = (__bridge NSString*) mgname;
    if ([keyStr isEqualToString:@"HasBaseband"]) {
        NSLog(@"MGGetBoolAnswer HasBaseband false");
        return FALSE;
    }
    NSLog(@"MGGetBoolAnswer %@   %d", mgname,res);
    return res;
}

static int (*orig_uname)(struct utsname *);
int my_uname(struct utsname * systemInfo){
    int nRet = orig_uname(systemInfo);
    // char str_machine_name[100] = "iPhone15,4";
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... my_uname");
        return nRet;
    }  
    char str_machine_name[100];
    const char *temp = [[[Device shared] PT] UTF8String];
    if (temp) {
        strncpy(str_machine_name, temp, sizeof(str_machine_name) - 1);
        str_machine_name[sizeof(str_machine_name) - 1] = '\0';
    }
    NSLog(@"my_uname %s  %s", systemInfo->machine, str_machine_name);
    strcpy(systemInfo->machine,str_machine_name);
    return nRet;
}


%ctor {
	MSImageRef image;
    image = MSGetImageByName("/usr/lib/libMobileGestalt.dylib");
    NSLog(@"mg image %p", image);

	// const uint8_t* MGCopyAnswer_ptr = (const uint8_t*)MSFindSymbol(image, "_MGCopyAnswer");
	// if (MGCopyAnswer_ptr != NULL){
	// 	NSLog(@"found MGCopyAnswer_ptr");
    //        MSHookFunction((void*)(MGCopyAnswer_ptr), (void*)my_MGCopyAnswer, (void**)&orig_MGCopyAnswer);
	// }

    uint8_t MGCopyAnswer_arm64_impl[8] = {0x01, 0x00, 0x80, 0xd2, 0x01, 0x00, 0x00, 0x14};
    const uint8_t* MGCopyAnswer_ptr = (const uint8_t*)MSFindSymbol(image, "_MGCopyAnswer");
    if (MGCopyAnswer_ptr != NULL){
        if (memcmp(MGCopyAnswer_ptr, MGCopyAnswer_arm64_impl, 8) == 0) {
            NSLog(@"MGCopyAnswer %d-bit", 64);
            MSHookFunction((void*)(MGCopyAnswer_ptr + 8), (void*)my_MGCopyAnswer_internal, (void**)&orig_MGCopyAnswer_internal);
        } else {
            NSLog(@"MGCopyAnswer %d-bit", 32);
            MSHookFunction((void*)(MGCopyAnswer_ptr + 6), (void*)my_MGCopyAnswer_internal, (void**)&orig_MGCopyAnswer_internal);
        }
    }

    const uint8_t *MGGetBoolAnswer_ptr = (const uint8_t*)MSFindSymbol(image, "_MGGetBoolAnswer");
    if (MGGetBoolAnswer_ptr != NULL){
        NSLog(@"found MGGetBoolAnswer_ptr");
        MSHookFunction((void*)((void*)MGGetBoolAnswer_ptr), (void*)my_MGGetBoolAnswer, (void**)&orig_MGGetBoolAnswer);
    }

    char str_libsystem_c[100] = {0};
    strcpy(str_libsystem_c, "/usr/lib/libsystem_c.dylib");

    void *h = dlopen(str_libsystem_c, RTLD_GLOBAL);
    if(h != 0){
        MSImageRef ref = MSGetImageByName(str_libsystem_c);
        void * unameFn = MSFindSymbol(ref, "_uname");
        NSLog(@"/usr/lib/libsystem_c.dylib _uname");
        MSHookFunction(unameFn, (void *)my_uname, (void **)&orig_uname);
    }
    else {
        strcpy(str_libsystem_c, "/usr/lib/system/libsystem_c.dylib");
        h = dlopen(str_libsystem_c, RTLD_GLOBAL);
        if(h != 0){
            MSImageRef ref = MSGetImageByName(str_libsystem_c);
            void * unameFn = MSFindSymbol(ref, "_uname");
            NSLog(@"/usr/lib/system/libsystem_c.dylib _uname");
            MSHookFunction(unameFn, (void *)my_uname, (void **)&orig_uname);
        }
        else {
            NSLog(@"libsystem_c %s dlopen error", str_libsystem_c);
        }
    } 
}