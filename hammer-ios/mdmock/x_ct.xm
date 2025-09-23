#import <CoreFoundation/CoreFoundation.h>
#import <CydiaSubstrate.h>
#import "../src/Device.h"
#import "../src/NSData+FastHex.h"
#import "../common/defines.h"

// origin dict sample:
// {
//     kCTMobileEquipmentInfoCurrentMobileId = 359306068603859;
//     kCTMobileEquipmentInfoCurrentSubscriberId = 302500012345678;
//     kCTMobileEquipmentInfoICCID = 89813000202173547520;
//     kCTMobileEquipmentInfoIMEI = 359306068603859;
//     kCTMobileEquipmentInfoIMSI = 302500012345678;
//     kCTMobileEquipmentInfoMEID = 35930606860385;
//     kCTMobileEquipmentInfoPRIVersion = "0.1.141";
// }
static int (*orig_CTServerConnectionCopyMobileEquipmentInfo)(int* conn, CFDictionaryRef *pDict);
int my_CTServerConnectionCopyMobileEquipmentInfo(int* conn, CFDictionaryRef *pDict)
{
    int ret = orig_CTServerConnectionCopyMobileEquipmentInfo(conn, pDict);
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... my_CTServerConnectionCopyMobileEquipmentInfo");
        return ret;
    }    
    NSDictionary *dict = (NSDictionary *)(*pDict);
    if (dict[@"kCTMobileEquipmentInfoIMEI"]){
        NSLog(@"my_CTServerConnectionCopyMobileEquipmentInfo go on");        
        NSMutableDictionary *myDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSLog(@"my_CTServerConnectionCopyMobileEquipmentInfo before %@", myDict);
        myDict[@"kCTMobileEquipmentInfoIMEI"] = [[Device shared] IMEI];
        myDict[@"kCTMobileEquipmentInfoMEID"] = [[Device shared] MEID];
        NSLog(@"my_CTServerConnectionCopyMobileEquipmentInfo after %@", myDict);
        *pDict = (CFDictionaryRef)[myDict retain];
    }    
    
    return ret;
}

// origin dict sample
// {
//     BasebandActivationTicketVersion = V2;
//     BasebandChipID = 8343777;
//     BasebandMasterKeyHash = 8CB15EE4C8002199070D9500BB8FB183B02713A5CA2A6B92DB5E75CE15536182;
//     BasebandSerialNumber = <15979be1>;
//     IntegratedCircuitCardIdentity = 89813000202173547520;
//     InternationalMobileEquipmentIdentity = 359306068603859;
//     InternationalMobileSubscriberIdentity = 302500012345678;
//     MobileEquipmentIdentifier = 35930606860385;
//     kCTPostponementInfoPRIVersion = "0.1.141";
//     kCTPostponementInfoPRLName = 0;
//     kCTPostponementInfoServiceProvisioningState = 1;
//     kCTPostponementInfoUniqueID = 35930606860385;
//     kCTPostponementStatus = kCTPostponementStatusActivated;
// }
// will remove by mad
// *    _kCTPostponementStatus
// *    _kCTPostponementStatusErrorReason
// *    _kCTPostponementInfoUniqueID
static int (*orig_CTServerConnectionCopyPostponementStatus)(int *conn, CFDictionaryRef *pDict);
int my_CTServerConnectionCopyPostponementStatus(int *conn, CFDictionaryRef *pDict){
    int ret = orig_CTServerConnectionCopyPostponementStatus(conn, pDict);
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... my_CTServerConnectionCopyPostponementStatus");
        return ret;
    }
    NSDictionary *dict = (NSDictionary *)(*pDict);
    if (dict[@"InternationalMobileEquipmentIdentity"]){
        NSLog(@"my_CTServerConnectionCopyPostponementStatus go on");
        NSMutableDictionary *myDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        NSLog(@"my_CTServerConnectionCopyPostponementStatus before %@", myDict);
        myDict[@"InternationalMobileEquipmentIdentity"] = [[Device shared] IMEI];
        myDict[@"MobileEquipmentIdentifier"] = [[Device shared] MEID];
        myDict[@"kCTPostponementInfoUniqueID"] = [[Device shared] MEID];
        NSLog(@"my_CTServerConnectionCopyPostponementStatus after %@", myDict);
        *pDict = (CFDictionaryRef)[myDict retain];
    }
    return ret;
}

int *(*orig_CTServerConnectionCopyMobileIdentity)(struct CTResult *res, struct CTServerConnection *connection, CFStringRef *stringBuf);
static int* my_CTServerConnectionCopyMobileIdentity(struct CTResult *res, struct CTServerConnection *connection, CFStringRef *stringBuf)  {
    int *result = orig_CTServerConnectionCopyMobileIdentity(res, connection, stringBuf);
    if (![[Device shared] isReady]){
        NSLog(@"NO DEVICE INFO ... SKIP ... my_CTServerConnectionCopyPostponementStatus");
        return result;
    }
    NSString *v = [[Device shared] IMEI];
    NSLog(@"CTServerConnectionCopyMobileIdentity ~~~ IMEI %@",v);
    *stringBuf = (__bridge CFStringRef)[[NSString alloc] initWithString:v];
    return result;
}

%ctor {
    MSImageRef image;
    image = MSGetImageByName("/System/Library/Frameworks/CoreTelephony.framework/CoreTelephony");
    NSLog(@"ct image %p", image);

	void *ptr_CTServerConnectionCopyMobileEquipmentInfo =  MSFindSymbol(image, "__CTServerConnectionCopyMobileEquipmentInfo"); 
	if (ptr_CTServerConnectionCopyMobileEquipmentInfo != NULL){
        NSLog(@"found __CTServerConnectionCopyMobileEquipmentInfo");
	    MSHookFunction((void*)ptr_CTServerConnectionCopyMobileEquipmentInfo, (void*)my_CTServerConnectionCopyMobileEquipmentInfo, (void**)&orig_CTServerConnectionCopyMobileEquipmentInfo);
	}

    void *ptr_CTServerConnectionCopyMobileIdentity = MSFindSymbol(image, "__CTServerConnectionCopyMobileIdentity");
    if (ptr_CTServerConnectionCopyMobileIdentity != NULL){
        NSLog(@"found __CTServerConnectionCopyMobileIdentity");
         MSHookFunction((void*)ptr_CTServerConnectionCopyMobileIdentity, (void*)my_CTServerConnectionCopyMobileIdentity, (void**)&orig_CTServerConnectionCopyMobileIdentity);
    }
    
    void *ptr_CTServerConnectionCopyPostponementStatus =  MSFindSymbol(image, "__CTServerConnectionCopyPostponementStatus"); 
    if (ptr_CTServerConnectionCopyPostponementStatus != NULL){
        NSLog(@"found __CTServerConnectionCopyPostponementStatus");
        MSHookFunction((void*)ptr_CTServerConnectionCopyPostponementStatus, (void*)my_CTServerConnectionCopyPostponementStatus, (void**)&orig_CTServerConnectionCopyPostponementStatus);
    }

}