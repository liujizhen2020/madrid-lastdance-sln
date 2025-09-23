//
//  mp.m
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "mp.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import "../../Sources/BinaryCert.h"
#import "./x/NSData+FTServices.h"
#import "./x/NSData+IMFoundation.h"
#import "./x/SecKeyPriv.h"
#import "./x/SecRSAKey.h"

// helper
static NSData* _formatECPrivKeyData(NSData *ecKeyData) __attribute__ ((always_inline));
static int _createTargetPublicKeysFromData(NSData *pubData, SecKeyRef *rsaPubKey) __attribute__ ((always_inline));
static NSData* _calcSourcePubKeyHash(NSData *ecPubKeyData, NSData *rsaPubKeyData) __attribute__ ((always_inline));
static NSData* _calcTargetPubKeyHash(NSData *targetIdentityData) __attribute__ ((always_inline));
static NSData* _generateAESKey(NSData *rawMsgData, NSData *pubBase) __attribute__ ((always_inline));
static int _aesEncryptCTR(NSData *inData, NSData *keyData, NSData **outData) __attribute__ ((always_inline));
static NSData* _rsaEncryptAESKey(CFDataRef rsaIn, SecKeyRef rsaPubKey) __attribute__ ((always_inline));
static NSData* _ecSignMessageBody(NSData *bodyData, SecKeyRef ecPrivKey) __attribute__ ((always_inline));


/*
 * for id-query
 * eg: 17 bytes
 *   <01000001 64f45275 102f77ce a484f76e 1e>
 *
 * ----
 * for apsd
 *   <00000001 64f45275 102f77ce a484f76e 1e>
 */

NSData*
_genNonce(BOOL s)
{
    NSMutableData *nonceOut = [NSMutableData dataWithCapacity:0x11];
    uint8_t ver = (s ? 1 : 0);
    [nonceOut appendBytes:&ver length:0x1];
    
    uint64_t ts = (uint64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    ts = CFSwapInt64HostToBig(ts);
    [nonceOut appendBytes:&ts length:0x8];
    
    uint8_t ranBytes[0x8];
    if (SecRandomCopyBytes(kSecRandomDefault, 0x8, ranBytes) != 0 ){
        NSLog(@"failed to copy random bytes... it rare happen..");
    }
    [nonceOut appendBytes:ranBytes length:0x8];
    return nonceOut;
}

/*
 * eg: 258 bytes
 * <01018cb8 96c61a00 ce11108a c935c070 64d4601e f85276f7 517c5597 80097a3f f1635323 163ba4fb 6bdc15e3 e35f9eb9 0ef34b8d 42ebadaf 40e922b9 d02c59c7 0d272c66 f205803c b77682e6 707a31ce 23676098 08839a70 eb221532 ce07d64f c56f2edd 18eb4513 5b95e955 70667c4b d93bc20d 416f4e18 89699e90 1c7144d9 17e38455 5d817c14 ff675035 4789e663 ce62d8db ff92831f 32bebf64 f341c25c 35f87540 a92102c8 8dcc6340 938c84c8 998e2c5e 9ebd489d 9d20001e df03b6b1 73890e59 93d540ed bf6a697f 165724a3 bcaebd87 0ef7cc8c 3bc68440 043cd9ec 1da92991 14eab88a d4ff657e ebe459d3 fbbdad07 f9d88529 d78f22de 46a586e8 f760>
 */

NSData*
_calcSig(SecKeyRef privKey, NSData *sha1)
{
    CFErrorRef err;
    size_t keyBlockSize = SecKeyGetBlockSize(privKey);
    
    SecTransformRef tf = SecSignTransformCreate(privKey, &err);
    if (err != NULL){ NSLog(@"[id-query] _calcSig err 1/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecDigestTypeAttribute, kSecDigestSHA1, &err);
    if (err != NULL){ NSLog(@"[id-query] _calcSig err 2/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecTransformInputAttributeName, (__bridge CFDataRef)sha1, &err);
    if (err != NULL){ NSLog(@"[id-query] _calcSig err 3/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecKeyAttributeName, privKey, &err);
    if (err != NULL){ NSLog(@"[id-query] _calcSig err 4/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecInputIsAttributeName, kSecInputIsDigest, &err);
    if (err != NULL){ NSLog(@"[id-query] _calcSig err 5/6"); CFRelease(tf); return nil; }
    CFDataRef sig = SecTransformExecute(tf, &err);
    if (err != NULL){ NSLog(@"[id-query] _calcSig err 6/6"); CFRelease(sig); CFRelease(tf); return nil; }
    CFRelease(tf);
    
    if (sig != NULL && err == NULL && CFDataGetLength(sig) == keyBlockSize){
        uint16_t sigPrefix = 0x101;
        NSMutableData *sigData = [NSMutableData dataWithBytes:&sigPrefix length:0x2];
        [sigData appendBytes:CFDataGetBytePtr(sig) length:CFDataGetLength(sig)];
        CFRelease(sig);
        return sigData;
    }
    CFRelease(sig);
    return nil;
}

NSData*
_calcSHA1(NSData *raw)
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(raw.bytes, (unsigned int)raw.length, digest);
    return [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}


NSData*
_protectMessage(NSData *rawData, NSData *pubMPData, BinaryCert *bc)
{
    CFErrorRef err;
    SecKeyRef s_ecPrivKey = NULL;
    
    NSData *s_ecPrivData = _formatECPrivKeyData(bc.ecPrivKeyData);
    if (!s_ecPrivData){
        NSLog(@"[enc sid] failed to format ec priv key data");
        return nil;
    }
    NSDictionary *s_ecPrivOpts = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom,
                                    (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate };
    s_ecPrivKey = SecKeyCreateFromData((__bridge CFDictionaryRef)s_ecPrivOpts,
                                       (__bridge CFDataRef)s_ecPrivData,
                                       &err);
    if (s_ecPrivKey == NULL){
        NSLog(@"[enc sid] ec priv key FAILED...");
        return nil;
    }
    
    // target public keys
    SecKeyRef t_rsaPubKey = NULL;
    if (_createTargetPublicKeysFromData(pubMPData, &t_rsaPubKey) != 0){
        NSLog(@"[enc] ERROR! failed to create public keys for target!");
        return nil;
    }
    //NSLog(@"[enc tid] rsa pub key %p", t_rsaPubKey);
    
    NSMutableData *pubBase = [NSMutableData dataWithCapacity:65];
    NSData *sidHash = _calcSourcePubKeyHash(bc.ecPubKeyData, bc.rsaPubKeyData);
    //NSLog(@"[enc] sid hash %@", sidHash);
    NSData *tidHash = _calcTargetPubKeyHash(pubMPData);
    //NSLog(@"[enc] tid hash %@", tidHash);
    uint8 v = 2;
    [pubBase appendBytes:&v length:1];
    [pubBase appendData:sidHash];
    [pubBase appendData:tidHash];
    
    // encrypt message using AES
    NSData *aesKeyData = _generateAESKey(rawData, pubBase);
    //NSLog(@"[enc] aes key (%ld bytes) %@", (long)[aesKeyData length], aesKeyData);
    NSData *aesEncMsg;
    if (_aesEncryptCTR(rawData, aesKeyData, &aesEncMsg) != 0){
        NSLog(@"[enc] failed to crypt message in ctr mode.");
        return nil;
    }
    //NSLog(@"[enc] aes enc msg (%ld bytes) \n%@", (long)[aesEncMsg length], aesEncMsg);
    
    // encrypt aes key
    NSMutableData *rsaBaseData = [NSMutableData data];
    [rsaBaseData appendData:aesKeyData];
    [rsaBaseData appendData:aesEncMsg];
    size_t rsaInAvail = 116; // rsa pub 1280 bit
    if ([aesEncMsg length] < rsaInAvail){
        rsaInAvail = [aesEncMsg length];
    }
    
    CFDataRef rsaIn = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, rsaBaseData.bytes, rsaInAvail, kCFAllocatorNull);
    NSData *encKeyData = _rsaEncryptAESKey(rsaIn, t_rsaPubKey);
    //NSLog(@"[enc] enc aes key (%ld bytes) %@", (long)[encKeyData length], encKeyData);
    CFIndex aesRawLen = [rsaBaseData length] - rsaInAvail;
    //NSLog(@"[enc] aes raw (%ld bytes)", (long)aesRawLen);
    CFDataRef aesRaw = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, rsaBaseData.bytes+rsaInAvail, aesRawLen, kCFAllocatorNull);
    
    // sign it
    NSMutableData *sigBaseData = [NSMutableData data];
    [sigBaseData appendData:encKeyData];
    [sigBaseData appendBytes:CFDataGetBytePtr(aesRaw) length:aesRawLen];
    //NSLog(@"[enc] sign base (%ld bytes)", (long)[sigBaseData length]);
    NSData *ecSignData = _ecSignMessageBody(sigBaseData, s_ecPrivKey);
    //NSLog(@"[enc] sig (%ld bytes) \n%@", (long)[ecSignData length], ecSignData);
    
    // final
    UInt8 ver = (UInt8)2;
    uint16 sz = (uint16)[sigBaseData length];
    sz = CFSwapInt16HostToBig(sz);
    NSMutableData *finMsg = [NSMutableData data];
    [finMsg appendBytes:&ver length:0x1];
    [finMsg appendBytes:&sz length:0x2];
    [finMsg appendData:sigBaseData];
    
    UInt8 sigSz = (0xff & [ecSignData length]);
    [finMsg appendBytes:&sigSz length:0x1];
    [finMsg appendData:ecSignData];
    
    // clean
    CFRelease(rsaIn);
    CFRelease(aesRaw);
    return finMsg;
}


#pragma mark - ***** helper functions *****

NSData*
_formatECPrivKeyData(NSData *ecKeyData)
{
    /*
     30 77 02 01 01 04 20
     
     cd ee 0e 11 96 5c b9 5b 14 bc 87 26 c4 e8 4c 5d d0 e4 92 c6 44 55 11 22 29 30 36 bb 57 db e1 4d ---- D
     
     a0 0a 06 08 2a 86 48 ce 3d 03 01 07 a1 44 03 42 00 04
     
     bf 0b c1 6b 3e 85 61 63 15 55 30 31 65 c1 e9 78 d5 4d 69 d5 db 97 e1 1d a2 ff 26 52 49 86 44 26 -----X
     b5 b3 00 cd 79 f8 32 1d af 50 c0 bc 3e 22 19 3c a1 0e 44 d7 09 17 e4 3a 21 95 ec 6f c0 1c 94 9b -----Y
     */
    if ([ecKeyData length] != 97){
        NSLog(@"[enc] _formatECPrivKeyData error wrong length, %ld != 97", (long)[ecKeyData length]);
        return nil;
    }
    const uint8_t *ecBytes = ecKeyData.bytes;
    // first byte is version = 4
    uint8_t version = *(ecBytes);
    //NSLog(@"[enc] version %d", version);
    if (version != 4){
        NSLog(@"[enc] _formatECPrivKeyData error wrong version.");
        return nil;
    }
    
    // ec params
    uint8_t x[32];
    uint8_t y[32];
    uint8_t d[32];
    memcpy(x, ecBytes+1,32);
    memcpy(y, ecBytes+33,32);
    memcpy(d, ecBytes+65,32);
    
    //
    uint8_t fix1[7] = {0x30, 0x77, 0x02, 0x01, 0x01, 0x04, 0x20};
    uint8_t fix2[18] = {0xa0, 0x0a, 0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0xa1, 0x44, 0x03, 0x42, 0x00, 0x04};
    NSMutableData *fmtData = [NSMutableData data];
    [fmtData appendBytes:fix1 length:7];
    [fmtData appendBytes:d length:32];
    [fmtData appendBytes:fix2 length:18];
    [fmtData appendBytes:x length:32];
    [fmtData appendBytes:y length:32];
    return fmtData;
}


// ccder
typedef unsigned long ccder_tag;
extern const uint8_t *ccder_decode_tl(ccder_tag expected_tag, size_t *lenp, const uint8_t *der, const uint8_t *der_end);
extern const uint8_t *ccder_decode_constructed_tl(ccder_tag expected_tag, const uint8_t **body_end, const uint8_t *der, const uint8_t *der_end);
extern const uint8_t *ccder_decode_sequence_tl(const uint8_t **body_end, const uint8_t *der, const uint8_t *der_end);

int
_createTargetPublicKeysFromData(NSData *pubData, SecKeyRef *rsaPubKey)
{
    CFDataRef data = (__bridge CFDataRef)pubData;
    CFIndex len = CFDataGetLength(data);
    const uint8_t * ptr = CFDataGetBytePtr(data);
    const uint8_t * end = ptr + len;
    const uint8_t * tag = ccder_decode_sequence_tl(&end, ptr, end);
    if (tag != NULL){
        size_t ecLen;
        const uint8_t * ecTag = ccder_decode_tl(0x8000000000000001, &ecLen, tag, end);
        size_t rsaLen;
        const uint8_t * rsaTag = ccder_decode_tl(0x8000000000000002, &rsaLen, ecTag+ecLen, end);
        if (rsaTag != NULL){
            if (rsaLen > 2){
                uint16_t rsaPubSize = (*(rsaTag)) + (*(rsaTag + 1) << 8);
                rsaPubSize = CFSwapInt16BigToHost(rsaPubSize);
                *rsaPubKey = SecKeyCreateRSAPublicKey(kCFAllocatorDefault, rsaTag+2, rsaPubSize, kSecKeyEncodingBytes);
            }
        }
    }
    
    if (rsaPubKey != NULL){
        return 0;
    }
    
    return -1;
}


int
_aesEncryptCTR(NSData *inData, NSData *keyData, NSData **outData)
{
    size_t dataOutMoved = 0;
    size_t dataOutMovedTotal = 0;
    CCCryptorStatus ccStatus = 0;
    CCCryptorRef cryptor = NULL;
    uint8_t iv[16];
    memset(iv, 0, 15);
    iv[15] = 1;
    ccStatus = CCCryptorCreateWithMode(kCCEncrypt, kCCModeCTR, kCCAlgorithmAES,
                                       ccNoPadding,
                                       iv, [keyData bytes], [keyData length],
                                       NULL, 0, 0, // tweak XTS mode, numRounds
                                       kCCModeOptionCTR_BE, // CCModeOptions
                                       &cryptor);
    if (cryptor == NULL || ccStatus != kCCSuccess){
        NSLog(@"[enc] CCCryptorCreate status: %d", ccStatus);
        CCCryptorRelease(cryptor);
        return -1;
    }
    
    size_t dataOutLength = CCCryptorGetOutputLength(cryptor, [inData length], true);
    NSMutableData *dataOut = [NSMutableData dataWithLength:dataOutLength];
    char *dataOutPointer = (char *)dataOut.mutableBytes;
    
    ccStatus = CCCryptorUpdate(cryptor,
                               inData.bytes, inData.length,
                               dataOutPointer, dataOutLength,
                               &dataOutMoved);
    dataOutMovedTotal += dataOutMoved;
    if (ccStatus != kCCSuccess) {
        NSLog(@"[enc] CCCryptorUpdate status: %d", ccStatus);
        CCCryptorRelease(cryptor);
        return -2;
    }
    
    ccStatus = CCCryptorFinal(cryptor,
                              dataOutPointer + dataOutMoved, dataOutLength - dataOutMoved,
                              &dataOutMoved);
    if (ccStatus != kCCSuccess) {
        NSLog(@"[enc] CCCryptorFinal status: %d", ccStatus);
        CCCryptorRelease(cryptor);
        return -3;
    }
    
    CCCryptorRelease(cryptor);
    
    dataOutMovedTotal += dataOutMoved;
    dataOut.length = dataOutMovedTotal;
    *outData = dataOut;
    return 0;
}


NSData*
_calcSourcePubKeyHash(NSData *ecPubKeyData, NSData *rsaPubKeyData)
{
    NSMutableData *baseOut = [NSMutableData dataWithCapacity:(2+ecPubKeyData.length+2+rsaPubKeyData.length)];
    uint16_t ecLen = ecPubKeyData.length;
    ecLen = CFSwapInt16BigToHost(ecLen);
    [baseOut appendBytes:&ecLen length:2];
    [baseOut appendData:ecPubKeyData];
    uint16_t rsaLen = rsaPubKeyData.length;
    rsaLen = CFSwapInt16BigToHost(rsaLen);
    [baseOut appendBytes:&rsaLen length:2];
    [baseOut appendData:rsaPubKeyData];
    unsigned char sid_hash[32];
    CC_SHA256(baseOut.bytes, (CC_LONG)baseOut.length, sid_hash);
    return [NSData dataWithBytes:sid_hash length:32];
}

NSData*
_calcTargetPubKeyHash(NSData *targetIdentityData)
{
    if ([targetIdentityData length] <= 7){
        NSLog(@"[enc] tid data is too short...");
        return nil;
    }
    uint16_t ecLen = *(uint16_t *)(targetIdentityData.bytes + 5);
    ecLen = CFSwapInt16BigToHost(ecLen);
    if ([targetIdentityData length] <= 7+ecLen+5){
        NSLog(@"[enc] tid data is too short...");
        return nil;
    }
    uint16_t rsaLen = *(uint16_t *)(targetIdentityData.bytes + 7+ecLen+3);
    rsaLen = CFSwapInt16BigToHost(rsaLen);
    if ([targetIdentityData length] < 7+ecLen+5+rsaLen){
        NSLog(@"[enc] tid data is too short...");
        return nil;
    }
    NSMutableData *baseOut = [NSMutableData data];
    [baseOut appendBytes:(targetIdentityData.bytes+5) length:(2+ecLen)];
    [baseOut appendBytes:(targetIdentityData.bytes+7+ecLen+3) length:(2+rsaLen)];
    unsigned char tid_hash[32];
    CC_SHA256(baseOut.bytes, (CC_LONG)baseOut.length, tid_hash);
    return [NSData dataWithBytes:tid_hash length:32];
}

NSData*
_generateAESKey(NSData *rawMsgData, NSData *pubBase)
{
    uint8_t aesKeyBytes[16]; // 128-bit
    if (SecRandomCopyBytes(kSecRandomDefault, 16, aesKeyBytes) != 0){
        NSLog(@"failed to generate aes key bytes.");
        return nil;
    }
    //NSLog(@"[enc] aes key rand %@", [NSData dataWithBytes:aesKeyBytes length:16]);
    
    
    // append 5 bytes hash to aes key!
    uint8_t sha2[32];
    CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA256, aesKeyBytes, 11);
    CCHmacUpdate(&ctx, rawMsgData.bytes, [rawMsgData length]);
    CCHmacUpdate(&ctx, pubBase.bytes, [pubBase length]);
    CCHmacFinal(&ctx, sha2);
    //NSLog(@"[enc] sha2                                 %@", [NSData dataWithBytes:sha2 length:5]);
    
    memcpy(aesKeyBytes+11, sha2, 5);
    return [NSData dataWithBytes:aesKeyBytes length:16];
}

NSData*
_rsaEncryptAESKey(CFDataRef rsaIn, SecKeyRef rsaPubKey)
{
    NSData *encKeyData = nil;
    CFErrorRef err;
    
    SecTransformRef tf = SecEncryptTransformCreate(rsaPubKey, &err);
    if (err != NULL) { NSLog(@"_rsaEncryptAESKey err at 1/4 "); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecTransformInputAttributeName, rsaIn, &err);
    if (err != NULL) { NSLog(@"_rsaEncryptAESKey err at 2/4 "); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecPaddingKey, kSecPaddingOAEPKey, &err);
    if (err != NULL) { NSLog(@"_rsaEncryptAESKey err at 3/4 "); CFRelease(tf); return nil; }
    CFDataRef encKey = SecTransformExecute(tf, &err);
    if (err != NULL) { NSLog(@"_rsaEncryptAESKey err at 4/4 "); CFRelease(encKey); CFRelease(tf); return nil; }
    CFRelease(tf);
    encKeyData = [NSData dataWithBytes:CFDataGetBytePtr(encKey) length:CFDataGetLength(encKey)];
    CFRelease(encKey);
    
    return encKeyData;
}

NSData*
_ecSignMessageBody(NSData *bodyData, SecKeyRef ecPrivKey)
{
    NSData *ecSignData = nil;
    CFErrorRef err;
    
    NSMutableData *bodyHash = [bodyData SHA1Data];
    SecTransformRef tf = SecSignTransformCreate(ecPrivKey, &err);
    if (err != NULL) { NSLog(@"_ecSignMessageBody err at 1/6 "); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecTransformInputAttributeName, (__bridge CFDataRef)bodyHash, &err);
    if (err != NULL) { NSLog(@"_ecSignMessageBody err at 2/6 "); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecKeyAttributeName, ecPrivKey, &err);
    if (err != NULL) { NSLog(@"_ecSignMessageBody err at 3/6 "); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecInputIsAttributeName, kSecInputIsDigest, &err);
    if (err != NULL) { NSLog(@"_ecSignMessageBody err at 4/6 "); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecDigestTypeAttribute, kSecDigestSHA1, &err);
    if (err != NULL) { NSLog(@"_ecSignMessageBody err at 5/6 "); CFRelease(tf); return nil; }
    CFDataRef ecSign = SecTransformExecute(tf, &err);
    if (err != NULL) { NSLog(@"_ecSignMessageBody err at 6/6 "); CFRelease(ecSign); CFRelease(tf);  return nil; }
    CFRelease(tf);
    ecSignData = [NSData dataWithBytes:CFDataGetBytePtr(ecSign) length:CFDataGetLength(ecSign)];
    CFRelease(ecSign);
    return ecSignData;
}
