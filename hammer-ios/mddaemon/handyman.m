#import "handyman.h"
#import "../src/nk_run_cmd.h"
#import <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#import <sqlite3.h>
#import <Security/Security.h>
#import "../common/defines.h"

void nk_clear_tmp_files() {
    nk_run_cmd("rm -fr /tmp/md_*");
}

NSString* 
nk_device_description(){
    NSDictionary *osVerDict = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *productVersion = osVerDict[@"ProductVersion"];
    NSString *productBuildVersion = osVerDict[@"ProductBuildVersion"];
    return [NSString stringWithFormat:@"<iPhone OS;%@;%@>", productVersion,productBuildVersion];
}

void nk_imsg_kill() {
    // nk_run_cmd("rm -fr /User/Library/FairPlay/*");
    nk_run_cmd("rm -fr /User/Library/SMS/*");
    nk_run_cmd("rm -fr /User/Library/Accounts/*");
    nk_run_cmd("rm -fr /private/var/mobile/Library/Preferences/com.apple.identityservices*");
    nk_run_cmd("find /private/var/containers/Data/System/ -type f -name adi.pb | xargs rm -fr");

    nk_run_cmd("killall -9 akd");
    nk_run_cmd("killall -9 itunesstored");
    nk_run_cmd("killall -9 AppStore");
    nk_run_cmd("killall -9 fairplayd.H2");
    nk_run_cmd("killall -9 cloudd");
    nk_run_cmd("killall -9 itunescloudd");
    nk_run_cmd("killall -9 absd");
    nk_run_cmd("killall -9 CloudKeychainProxy");
    nk_run_cmd("killall -9 bird");
    nk_run_cmd("killall -9 coreauthd");
    nk_run_cmd("killall -9 AppleIDAuthAgent");
    nk_run_cmd("killall -9 accountsd");
    nk_run_cmd("killall -9 appstored");
    nk_run_cmd("killall -9 ubd");
    nk_run_cmd("killall -9 com.apple.accounts.dom");
    nk_run_cmd("killall -9 mstreamd");
    nk_run_cmd("killall -9 nesessionmanager");
    nk_run_cmd("killall -9 adid");
    nk_run_cmd("killall -9 MobileCal");
    nk_run_cmd("killall -9 nsurlsessiond");
    nk_run_cmd("killall -9 apsd");
    nk_run_cmd("killall -9 imagent");
    nk_run_cmd("killall -9 Preferences");
    nk_run_cmd("killall -9 MobileSMS");
    nk_run_cmd("killall -9 IMDPersistenceAgent");
    nk_run_cmd("killall -9 identityservicesd");
    nk_run_cmd("killall -9 IDSRemoteURLConnectionAgent");
    nk_run_cmd("killall -9 IMRemoteURLConnectionAgent");
}



void nk_kill_process(NSString *processName) {
	NSString *cmd = [NSString stringWithFormat:@"killall -9 %@", processName];
	nk_run_cmd([cmd cStringUsingEncoding:NSUTF8StringEncoding]);
}

//eg
//NSString *recPath = @"Library/activation_records/activation_record.plist";
//NSString *recPath = @"Documents/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv";

NSString* 
nk_get_path_from_container(NSString *recPath) {
    // eg: /private/var/containers/Data/System/0D2FFE85-E382-4900-91C2-CAD5143E3CD2/Library/activation_records/activation_record.plist
    NSString *containerID = nil;
    NSError *err = nil;
    NSString *parent = @"/private/var/containers/Data/System";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *subs = [fm contentsOfDirectoryAtPath:parent error:&err];
    if (err != nil){
        NSLog(@"nk_get_path_from_container Err %@", err);
        return nil;
    }
    for (NSString *s in subs){
        NSString *testPath = [NSString stringWithFormat:@"%@/%@/%@",parent, s, recPath];
        if ([fm fileExistsAtPath:testPath isDirectory:NULL]){
            containerID = s;
            break;
        }
    }
    return [NSString stringWithFormat:@"%@/%@/%@",parent, containerID, recPath];
}

void nk_clear_activation_records() {
    nk_run_cmd("find /private/var/containers/Data/System/ -type f -name activation_record.plist | xargs rm -fr");
}

void nk_mad_kill() {
    nk_run_cmd("killall -9 fairplayd.H2 mobileactivationd Setup");
}

void kc_clear_apsd() {
    CFMutableDictionaryRef cfQuery = NULL;
    OSStatus x;

    // push cert
    cfQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(cfQuery, kSecAttrAccessGroup, @"com.apple.apsd");
    CFDictionaryAddValue(cfQuery, kSecAttrLabel, @"APSClientIdentity");
    CFDictionaryAddValue(cfQuery, kSecClass, kSecClassCertificate);
    x = SecItemDelete(cfQuery);    
    // NSLog(@"remove push cert %d, query %@", x, (__bridge NSDictionary *)cfQuery);

    // push key
    CFDictionarySetValue(cfQuery, kSecClass, kSecClassKey);
    x = SecItemDelete(cfQuery);
    // NSLog(@"remove push key %d, query %@", x, (__bridge NSDictionary *)cfQuery);

    // push identity
    CFDictionarySetValue(cfQuery, kSecClass, kSecClassIdentity);
    CFDictionaryRemoveValue(cfQuery, kSecAttrLabel);
    x = SecItemDelete(cfQuery);
    // NSLog(@"remove push identity %d, query %@", x, (__bridge NSDictionary *)cfQuery);
    
    // push token
    CFDictionarySetValue(cfQuery, kSecClass, kSecClassGenericPassword);
    x = SecItemDelete(cfQuery);
    NSLog(@"remove push token %d, query %@", x, (__bridge NSDictionary *)cfQuery);

    // clean up
    CFRelease(cfQuery);
}

int kc_clear_imsg(void) {
 
    NSDictionary *query = nil;

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"ProtectedCloudStorage"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"ProtectedCloudStorage"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.idms.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.idms.continuation-key"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.idms.heartbeat-token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.IdentityServices.password"
    };
    SecItemDelete((CFDictionaryRef)query);
    
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.idms.hb.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.asa.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.icloud.escrow.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.icloud.cloudkit.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.schoolwork.orion.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.schoolwork.axm.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.idms.hb.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.idms.pet.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.global.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.news.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.appleid.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.appleid.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.supportapp.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.idms.ln.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.beta.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.pb.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.icloud.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    // AppleIDClientIdentifier
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.AppleAccount.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.AppleAccount.maps-token"
    };
    SecItemDelete((CFDictionaryRef)query);    

    // about account, token ...
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.IdentityServices.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.ProtectedCloudStorage"
    };
    SecItemDelete((CFDictionaryRef)query);
    
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.cloudd.deviceIdentifier.Production"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.ind.registration"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.DeviceLocator.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.FindMyFriends.find-my-friends-app-token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.FindMyFriends.find-my-friends-token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.AppleAccount.find-my-iphone-token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.GameCenter.rpassword"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.GameCenter.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.CloudKit.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.dip.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);
    
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.icloud.family.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.itunes.mu.invite.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);
    
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.cloudd.deviceIdentifier.Production"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.cloudd.deviceIdentifier.Production"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.AppleAccount.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    // IDS
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.AppleAccount.password"
    };
    SecItemDelete((CFDictionaryRef)query);

    // ids
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.gs.authagent.auth.com.apple.account.AppleIDAuthentication.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    // local ids
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.account.AppleAccount.rpassword"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecAttrAccessGroup:@"com.apple.sharing.appleidauthentication",
        (id)kSecClass: (id)kSecClassKey
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecAttrAccessGroup:@"com.apple.sharing.appleidauthentication",
        (id)kSecClass: (id)kSecClassCertificate
    };
    SecItemDelete((CFDictionaryRef)query);
    
    query = @{
        (id)kSecAttrAccessGroup:@"ichat",
        (id)kSecClass: (id)kSecClassKey
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"IDS"
    };
    SecItemDelete((CFDictionaryRef)query);

    // ids
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"ids"
    };
   SecItemDelete((CFDictionaryRef)query);

    // local ids
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.ids"
    };
    SecItemDelete((CFDictionaryRef)query);

    // ichat
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrAccessGroup: @"ichat",
    };
    SecItemDelete((CFDictionaryRef)query);

    // facetime
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.facetime",
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.appleaccount.fmf.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.appleaccount.cloudkit.token"
    };
    SecItemDelete((CFDictionaryRef)query);

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"com.apple.appleaccount.fmf.apptoken"
    };
    SecItemDelete((CFDictionaryRef)query);
    
    kc_clear_apsd();
    return 0;
}


NSString* kc_auth_uuid() {
    NSDictionary *query = nil;    
    OSStatus ret;

    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"AppleIDClientIdentifier"
    };
    ret = SecItemDelete((CFDictionaryRef)query); 
    // NSLog(@"kc_auth_uuid SecItemDelete %d", ret);

    NSString *ranUUID = [[NSUUID UUID] UUIDString];
    query = @{
        (id)kSecClass: (id)kSecClassGenericPassword,
        (id)kSecAttrService: @"AppleIDClientIdentifier",
        (id)kSecAttrAccessGroup: @"apple",
        (id)kSecValueData: [ranUUID dataUsingEncoding:NSUTF8StringEncoding]
    };
    ret = SecItemAdd((CFDictionaryRef)query, NULL);
    // NSLog(@"kc_auth_uuid SecItemAdd %d", ret);
    if (ret == errSecSuccess){
        // NSLog(@"kc_auth_uuid %@", ranUUID);
       return ranUUID;
    }
    return nil;
}

NSData* 
decode_pem_data(NSData *data, NSString *typeName){
    //NSLog(@"decode_pem_data ----- %@ -----", typeName);
    NSRange fullRange = NSMakeRange(0, data.length);
    NSData *prefixData = [[NSString stringWithFormat:@"-----BEGIN %@-----\n",typeName] dataUsingEncoding:NSUTF8StringEncoding]; 
    NSRange preRange = [data rangeOfData:prefixData options:NSDataSearchAnchored range:fullRange];
    if (preRange.location == NSNotFound){
        NSLog(@"prefix not found!");
        //NSLog(@"dump:   data %@", data);
        //NSLog(@"dump: prefix %@", prefixData);
        return nil;
    }
    NSData *subfixData = [[NSString stringWithFormat:@"\n-----END %@-----",typeName] dataUsingEncoding:NSUTF8StringEncoding]; 
    NSRange subRange = [data rangeOfData:subfixData options:NSDataSearchBackwards range:fullRange];
    if (subRange.location == NSNotFound){
        NSLog(@"subfix not found!");
        //NSLog(@"dump:   data %@", data);
        //NSLog(@"dump: subfix %@", subfixData);
        return nil;
    }
    
    //NSLog(@"*   full data range... (0, %ld)", data.length);
    //NSLog(@"* prefix data range... (%ld, %ld)", preRange.location, preRange.length);
    //NSLog(@"* subfix data range... (%ld, %ld)", subRange.location, subRange.length);
    //NSLog(@"* base64 data range... (%ld, %ld)", prefixData.length, (subRange.location-prefixData.length));

    NSUInteger loc = prefixData.length;
    NSUInteger len = subRange.location-prefixData.length;
    if (loc + len >= fullRange.length){
        NSLog(@"base64 data range is INVALID! range (%lu, %lu) VS data len %lu", loc, len, fullRange.length);
        return nil;
    }

    NSData *b64Data = [data subdataWithRange:NSMakeRange(loc,len)];
    NSData *rawData = [[NSData alloc] initWithBase64EncodedData:b64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return rawData;
}
