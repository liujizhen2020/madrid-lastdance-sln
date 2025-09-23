#import "dump.h"
#import "keychain.h"
#import <Security/Security.h>

#define dump_log(fmt, ...)   NSLog((@"[>>>DUMP] " fmt), ##__VA_ARGS__)
// #define dump_log(fmt, ...) 

const int kDumpOK = 0;

static NSData* _extractCertDataFromIdentity(SecIdentityRef identity);
static NSData* _extractKeyDataFromIdentity(SecIdentityRef identity);

int 
dump_ids_registration(BinaryCert *box) 
{
    NSLog(@"----------------------------- dump_ids_registration -----------------------------");
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, @"apple");
    CFDictionaryAddValue(mQuery, kSecAttrService, @"com.apple.facetime");
    CFDictionaryAddValue(mQuery, kSecAttrAccount, @"registrationV1");
    CFDictionaryAddValue(mQuery, kSecReturnData, kCFBooleanTrue);
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
    // box.registrationData = (__bridge NSData *)cfData;
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
        dump_log(@" * service %@ ", service);
        if(![@"iMessage" isEqualToString:service]){
            dump_log(@"skip service:%@",service);
            continue;
        }
        NSString *mainId = r[@"main-id"];
        NSArray *uris = r[@"uris"];
        BOOL matched = NO;
        if ([mainId caseInsensitiveCompare:box.email] == NSOrderedSame){
            matched = YES;
        }else{
            for(NSString *uri in uris){
                NSString *uriItem = [uri stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
                if([uriItem caseInsensitiveCompare:box.email] == NSOrderedSame){
                    matched = YES;
                }
            }
        }
        if (matched){
            dump_log(@"got matched registrations");
            // NSString *profileId = r[@"profile-id"];
            NSData *pushToken  = r[@"push-token"];
            NSData *idCert = r[@"ids-registration-cert"];
            //if (mainId != nil && pushToken != nil && idCert != nil){
            if (pushToken != nil && idCert != nil){
                // box.profileId = [profileId stringByReplacingOccurrencesOfString:@"D:" withString:@""];
                // box.email = mainId;
                box.pushTokenData = pushToken;
                box.idCertData = idCert;
                regOK = YES;
                //NSLog(@"check OK for mainId %@", mainId);
            }
            break;
        }
    }
    
    if (regOK){
        dump_log(@"dump id key now");
        // dump id priv key
        mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(mQuery, kSecClass, kSecClassGenericPassword);
        CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, @"apple");
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
        box.idPrivKeyData = (__bridge NSData *)idPriv; 

        // // id pub
        // CFDataRef idPub;
        // CFDictionarySetValue(mQuery, kSecAttrAccount, @"identity-rsa-public-key");
        // ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&idPub);   
        // if (ret != errSecSuccess){
        //     NSLog(@"--> dump: id pub, ret %d", ret);
        //     CFRelease(mQuery);
        //     return -11;
        // }
        // dump_log(@"got id pub %@", (__bridge NSData *)idPub);
        // box.idPubKeyData = (__bridge NSData *)idPub; 

        // // id sig
        // CFDataRef idSig;
        // CFDictionarySetValue(mQuery, kSecAttrAccount, @"identity-rsa-key-pair-signature-v1");
        // ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&idSig);   
        // if (ret != errSecSuccess){
        //     NSLog(@"--> dump: id sig, ret %d", ret);
        //     CFRelease(mQuery);
        //     return -11;
        // }
        // dump_log(@"got id sig %@", (__bridge NSData *)idSig);
        // box.idKeySigData = (__bridge NSData *)idSig; 

        CFRelease(mQuery);
        dump_log("DUMP OK");
        NSLog(@"----------------------------- dump_ids_registration ok -----------------------------");
        return 0;
    }
    return -1;
}

int
dump_push_cert_and_key(BinaryCert *box)
{
    NSLog(@"----------------------------- dump_push_cert_and_key -----------------------------");
    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecClass, kSecClassIdentity);
    CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, @"com.apple.apsd");
    CFDictionaryAddValue(mQuery, kSecAttrLabel, @"APSClientIdentity");
    CFDictionaryAddValue(mQuery, kSecReturnRef, kCFBooleanTrue);
    SecIdentityRef cfIdentity;
    OSStatus ret = SecItemCopyMatching(mQuery, (CFTypeRef *)&cfIdentity);
    if (ret != errSecSuccess){
        NSLog(@"--> ret %d", ret);
        return -1;
    }

    NSData *certData = _extractCertDataFromIdentity(cfIdentity);
    NSData *keyData = _extractKeyDataFromIdentity(cfIdentity);                
    CFRelease(cfIdentity);
    if (certData != nil && keyData != nil){
        box.pushCertData = certData;
        box.pushKeyData = keyData;
        NSLog(@"DUMP OK");
        NSLog(@"----------------------------- dump_push_cert_and_key ok -----------------------------");
        return 0;
    }
    return -2;
}

int 
dump_message_protection_keys(BinaryCert *box) 
{
    NSLog(@"----------------------------- dump_message_protection_keys -----------------------------");
    int d;
    CFDataRef cfData;
    d = kc_get_data(kSecClassGenericPassword, CFSTR("ids"), CFSTR("message-protection-public-data-registered"), CFSTR("ichat"), &cfData);
    if (d != 0){
        NSLog(@"dump: mp pub, Err %d", d);
        return -1;
    }  
    // box.mpPubData = (__bridge NSData *)cfData;
    // dump_log(@"got mp pub data \n %@", box.mpPubData);

    CFMutableDictionaryRef mQuery = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(mQuery, kSecClass, kSecClassGenericPassword);
    CFDictionaryAddValue(mQuery, kSecAttrAccessGroup, @"ichat");
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
    if (CFDataGetLength(cfData) < 1+2){
        CFRelease(cfData);
        return -2;
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
    CFDataRef ecPriv;
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
    CFDataRef rsaPriv;
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
        box.ecPubKeyData = (__bridge NSData *)ecPub;
        box.ecPrivKeyData = (__bridge NSData *)ecPriv;
        box.rsaPubKeyData = (__bridge NSData *)rsaPub;
        box.rsaPrivKeyData = (__bridge NSData *)rsaPriv;
        dump_log("DUMP OK");
        NSLog(@"----------------------------- dump_message_protection_keys ok -----------------------------");
        return 0;
    }
    return -1;
}


NSData *
_extractCertDataFromIdentity(SecIdentityRef identity) 
{
    NSData *certData = nil;
    if (identity){
        OSStatus ret;
        SecCertificateRef cert = NULL;
        ret = SecIdentityCopyCertificate(identity, &cert);        
        if (ret != errSecSuccess){
             dump_log(@"SecIdentityCopyCertificate failed.. err %ld", (long)ret);
        }else{
            NSString *summary = (__bridge NSString *)SecCertificateCopySubjectSummary(cert);
            if(summary != nil){
                dump_log(@"summary:%@", summary);
            }else{
                dump_log(@"summary is nil");
            }
            certData = (__bridge NSData *)SecCertificateCopyData(cert);
            if (!certData){
                dump_log(@"SecCertificateCopyData failed...");
            }else{
                dump_log(@"cert data %@",certData);
            }
            CFRelease(cert);
        }
    }
    return certData;
} 

NSData*
_extractKeyDataFromIdentity(SecIdentityRef identity)
{
    NSData *keyData = nil;
    if (identity){
        OSStatus ret;
        SecKeyRef privateKey = NULL;
        ret = SecIdentityCopyPrivateKey(identity, &privateKey);
        if (ret != errSecSuccess){
            dump_log(@"SecIdentityCopyPrivateKey failed.. err %ld", (long)ret);
        }else{
            CFErrorRef err = NULL;
            keyData = (__bridge NSData *)SecKeyCopyExternalRepresentation(privateKey, &err);
            dump_log(@"key block size is %ld", (long)SecKeyGetBlockSize(privateKey));
            if (!keyData){
                dump_log(@"SecKeyCopyExternalRepresentation err %@", (__bridge NSError *)err);
            }else{
                dump_log(@"private key data %@", keyData);
            }
        }
        CFRelease(privateKey);
    }
    return keyData;
}

