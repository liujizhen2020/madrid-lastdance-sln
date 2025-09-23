//
//  MacDumper.m
//  ThinAir
//
//  Created by yt on 30/08/22.
//

#import "mac_dumper.h"
#import <Security/Security.h>
#import "APSDumpHelper.h"
#import <IOKit/IOKitLib.h>

 #define dump_log(fmt, ...)   NSLog((@"[>>>DUMP] " fmt), ##__VA_ARGS__)
//#define dump_log(fmt, ...)

const int kDumpOK = 0;

static int dump_ids_registration(BinaryCert *bc);
static int dump_message_protection_keys(BinaryCert *bc);
static int dump_push_cert_and_key(BinaryCert *bc);


int
mac_dump_cert(BinaryCert *bc)
{
    bc.version = 2;
    OSStatus ret;
    
    ret = dump_message_protection_keys(bc);
    if (ret != kDumpOK){
        return ret;
    }
    
    ret = dump_push_cert_and_key(bc);
    if (ret != kDumpOK){
        return ret;
    }
    
    ret = dump_ids_registration(bc);
    if (ret != kDumpOK){
        return ret;
    }
    


    return kDumpOK;
}

int dump_ids_registration(BinaryCert *bc) {
    NSLog(@"----------------------------- dump_ids_registration -----------------------------");
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(mQuery, kSecAttrService, @"com.apple.facetime");
    CFDictionaryAddValue(mQuery, kSecAttrAccount, @"registrationV1");
    CFDictionaryAddValue(mQuery, kSecReturnData, kCFBooleanTrue);
    dump_log(@"query %@", (__bridge NSDictionary *)mQuery);
    
    CFDataRef cfData;
    OSStatus ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&cfData);
    CFRelease(mQuery);
    if (ret != errSecSuccess){
        NSLog(@"--> ret %d", ret);
        return -1;
    }

    // plist data
    // {
    //     push-token,
    //     id-cert,
    //     auth-cert
    // }
    dump_log(@"got data \n %@", (__bridge NSData *)cfData);
    //bc.registrationData = (__bridge NSData *)cfData;
    NSDictionary *regDict = [NSPropertyListSerialization propertyListWithData:(__bridge NSData *)cfData options:NSPropertyListImmutable format:nil error:nil];
    if (regDict == nil){
        return -2;
    }

    dump_log(@"reg dict %@", regDict);
    NSArray *registrations = regDict[@"data"];
    if (![registrations isKindOfClass:[NSArray class]]){
        NSLog(@"reg-data is not array");
        return -3;
    }
    dump_log(@"got %ld registrations",(long)[registrations count]);
    BOOL regOK = NO;
    for (NSDictionary *r in registrations){
        NSString *service = r[@"service"];
        NSString *mainId = r[@"main-id"];
        dump_log(@"*** service %@ via ID %@", service, mainId);
        if ([@"iMessage" isEqualToString:service]){
            NSData *pushToken  = r[@"push-token"];
            NSData *idCert = r[@"ids-registration-cert"];
            if (mainId != nil && pushToken != nil && idCert != nil){
                bc.email = mainId;
                bc.pushTokenData = pushToken;
                dump_log(@"*** push token %@", pushToken);
                bc.idCertData = idCert;
                regOK = YES;
                dump_log(@"check OK for mainId %@", mainId);
            }
            break;
        }
    }

    if (regOK){
        dump_log(@"dump id key now");
        // dump id priv key
        mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(mQuery, kSecClass, kSecClassGenericPassword);
        CFDictionaryAddValue(mQuery, kSecAttrService, @"ids");
        CFDictionaryAddValue(mQuery, kSecAttrAccount, @"identity-rsa-private-key");
        CFDictionaryAddValue(mQuery, kSecReturnData, kCFBooleanTrue);
        CFDataRef idPriv;
        ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&idPriv);
        if (ret != errSecSuccess){
            NSLog(@"--> dump: id priv, ret %d", ret);
            CFRelease(mQuery);
            return -11;
        }
        dump_log(@"got id priv %@", (__bridge NSData *)idPriv);
        bc.idPrivKeyData = (__bridge NSData *)idPriv;

        CFRelease(mQuery);
        dump_log("DUMP OK");
        NSLog(@"----------------------------- dump_ids_registration ok -----------------------------");
        return kDumpOK;
    }
    return -1;
}

int dump_message_protection_keys(BinaryCert *bc) {
    NSLog(@"----------------------------- dump_message_protection_keys -----------------------------");
    CFDataRef cfData;
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(mQuery, kSecAttrService, @"ids");
    CFDictionaryAddValue(mQuery, kSecAttrAccount, @"message-protection-key");
    CFDictionaryAddValue(mQuery, kSecReturnData, kCFBooleanTrue);
    OSStatus ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&cfData);
    CFRelease(mQuery);
    if (ret != errSecSuccess){
        NSLog(@"--> ret %d", ret);
        return -1;
    }

    dump_log(@"got mp keys data \n %@", (__bridge NSData *)cfData);
    if (CFDataGetLength(cfData) == 0){
        CFRelease(cfData);
        return -2;
    }

    
    // ver
    UInt8 ver = *(UInt8 *)CFDataGetBytePtr(cfData);
    dump_log(@"mp ver %d", ver);
    if (ver != 2){
        NSLog(@"Error: we don't supprt V%d yet.", ver);
        return -4;
    }

    // v=2
    // len,ec-priv-key-persistant
    // len,ec-pub
    // len,rsa-priv-key-persistant
    // len,rsa-pub
    CFDataRef ecRef;
    CFDataRef ecPub;
    CFDataRef rsaRef;
    CFDataRef rsaPub;
    // ec
    const UInt8 *ecPtr = CFDataGetBytePtr(cfData)+1;
    UInt16 ecRefLen = *(UInt16 *)(ecPtr);
    ecRefLen = CFSwapInt16BigToHost(ecRefLen);
    dump_log(@"ec ref len %d", ecRefLen);
    if (CFDataGetLength(cfData) < 1+2+ecRefLen+2){
        CFRelease(cfData);
        return -2;
    }
    ecRef = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,ecPtr+2,ecRefLen,kCFAllocatorNull);
    dump_log(@"ec ref %@", (__bridge NSData *)ecRef);
    UInt16 ecPubLen = *(UInt16 *)(ecPtr+2+ecRefLen);
    ecPubLen = CFSwapInt16BigToHost(ecPubLen);
    dump_log(@"ec pub len %d", ecPubLen);
    if (CFDataGetLength(cfData) < 1+2+ecRefLen+2+ecPubLen){
        CFRelease(cfData);
        return -2;
    }
    ecPub = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,ecPtr+2+ecRefLen+2,ecPubLen,kCFAllocatorNull);
    dump_log(@"ec pub %@", (__bridge NSData *)ecPub);

    // rsa
    const UInt8 *rsaPtr = CFDataGetBytePtr(cfData)+1+2+ecRefLen+2+ecPubLen;
    if (CFDataGetLength(cfData) < 1+2+ecRefLen+2+ecPubLen+2){
        CFRelease(cfData);
        return -2;
    }
    UInt16 rsaRefLen = *(UInt16 *)(rsaPtr);
    rsaRefLen = CFSwapInt16BigToHost(rsaRefLen);
    dump_log(@"rsa ref len %d", rsaRefLen);
    if (CFDataGetLength(cfData) < 1+2+ecRefLen+2+ecPubLen+2+rsaRefLen){
        CFRelease(cfData);
        return -2;
    }
    rsaRef = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,rsaPtr+2,rsaRefLen,kCFAllocatorNull);
    dump_log(@"rsa ref %@", (__bridge NSData *)rsaRef);
    if (CFDataGetLength(cfData) < 1+2+ecRefLen+2+ecPubLen+2+rsaRefLen+2){
        CFRelease(cfData);
        return -2;
    }
    UInt16 rsaPubLen = *(UInt16 *)(rsaPtr+2+rsaRefLen);
    rsaPubLen = CFSwapInt16BigToHost(rsaPubLen);
    dump_log(@"rsa pub len %d", rsaPubLen);
    if (CFDataGetLength(cfData) < 1+2+ecRefLen+2+ecPubLen+2+rsaRefLen+2+rsaPubLen){
        CFRelease(cfData);
        return -2;
    }
    rsaPub = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,rsaPtr+2+rsaRefLen+2,rsaPubLen,kCFAllocatorNull);
    dump_log(@"rsa pub %@", (__bridge NSData *)rsaPub);
    
    // priv
    if (ecRef == NULL || rsaRef == NULL) {
        CFRelease(cfData);
        return -3;
    }

    CFErrorRef err;
    SecKeyRef ecPrivKey;
    CFDataRef ecPriv = NULL;
    mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecValuePersistentRef, ecRef);
    CFDictionaryAddValue(mQuery, kSecReturnRef, kCFBooleanTrue);
    ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&ecPrivKey);
    CFRelease(mQuery);
    if (ret == 0){
        ecPriv = SecKeyCopyExternalRepresentation(ecPrivKey, &err);
        dump_log(@"ec priv %@", (__bridge NSData *)ecPriv);
        CFRelease(ecRef);
        CFRelease(ecPrivKey);
    }
    

    SecKeyRef rsaPrivKey;
    CFDataRef rsaPriv = NULL;
    mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecValuePersistentRef, rsaRef);
    CFDictionaryAddValue(mQuery, kSecReturnRef, kCFBooleanTrue);
    ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&rsaPrivKey);
    CFRelease(mQuery);
    if (ret == 0){
        rsaPriv = SecKeyCopyExternalRepresentation(rsaPrivKey, &err);
        dump_log(@"rsa priv %@", (__bridge NSData *)rsaPriv);
        CFRelease(rsaRef);
        CFRelease(rsaPrivKey);
    }
   
    if (ecPub != NULL && ecPriv != NULL && rsaPub != NULL && rsaPriv != NULL){
        bc.ecPubKeyData = (__bridge NSData *)ecPub;
        bc.ecPrivKeyData = (__bridge NSData *)ecPriv;
        bc.rsaPubKeyData = (__bridge NSData *)rsaPub;
        bc.rsaPrivKeyData = (__bridge NSData *)rsaPriv;
        dump_log("DUMP OK");
        NSLog(@"----------------------------- dump_message_protection_keys ok -----------------------------");
        return kDumpOK;
    }
    return -10;
}
        

int dump_push_cert_and_key(BinaryCert *bc) {
    NSLog(@"----------------------------- dump_push_cert_and_key -----------------------------");
    NSDictionary *myDataDict = [NSDictionary dictionaryWithContentsOfFile:X_APSD_PLIST];
    dump_log(@"myDataDict %@",myDataDict);
    if (myDataDict[APS_PUSH_CERT] == nil){
        NSLog(@"no push cert");
        return -22;
    }
        
    bc.pushCertData = myDataDict[APS_PUSH_CERT];
    dump_log(@"push cert data %@", bc.pushCertData);
    
    if (myDataDict[APS_PUSH_KEY] == nil){
        NSLog(@"no push key");
        return -23;
    }
    bc.pushKeyData = myDataDict[APS_PUSH_KEY];
    dump_log(@"push key data %@", bc.pushKeyData);
    
    // "0" or "0 darkWakeEnabled"
    NSData *rootToken = myDataDict[@"0"];
    if (rootToken == nil){
        rootToken = myDataDict[@"0 darkWakeEnabled"];
    }
    if (rootToken == nil){
        NSLog(@"no push token-0");
        return -20;
    }
    bc.masterPushToken = rootToken;
    dump_log(@"push token-0 data \n %@", bc.masterPushToken);
    
    if (bc.pushCertData == nil || bc.pushKeyData == nil || bc.masterPushToken == nil){
        NSLog(@"dump fail, push cert or key or master push token is nil");
        return -1;
    }
    
    NSLog(@"----------------------------- dump_push_cert_and_key ok -----------------------------");
    return kDumpOK;
}

