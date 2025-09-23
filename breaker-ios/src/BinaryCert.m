//
//  BinaryCert.m
//  BinaryCertTest
//
//  Created by yt on 08/08/22.
//

#import "BinaryCert.h"
#import <CoreFoundation/CoreFoundation.h>

#define MAGIC_IM    0x696D696D
#define MAGIC_XC    0x78637863
#define MAGIC_HM    0x686D686D
#define MAGIC_DW    0x64776477

#define VERSION_ONE     1

// Known tags:
#define TAG_SN              0x10
#define TAG_EMAIL           0x11

#define TAG_PUSH_TOKEN      0x21
#define TAG_PUSH_CERT       0x22
#define TAG_PUSH_KEY        0x23

#define TAG_ID_CERT         0x31
#define TAG_ID_PRIV_KEY     0x32

// message protection v1
#define TAG_EC_PUB_KEY      0x41
#define TAG_EC_PRIV_KEY     0x42
#define TAG_RSA_PUB_KEY     0x43
#define TAG_RSA_PRIV_KEY    0x44

// message protection v2
#define TAG_LEGACY_FULL_IDENTIDY_KEY    0x45

// for macOS user 0
#define TAG_MASTER_PUSH_TOKEN   0x20


@interface BinaryCert()

@property (assign, nonatomic) uint32_t magic;


@end

@implementation BinaryCert

+ (instancetype)parseFrom:(NSData *)data {
    if (data == nil || [data length] < 8){
        NSLog(@"bindata is too short!");
        return nil;
    }
    
    BinaryCert *bc = [BinaryCert new];
    if ([bc _parseV1Data:data]){
        return bc;
    }else if ([bc _migrateV0Data:data]){
        return bc;
    }
    return nil;
}

- (NSData *)packedData {
    // package field with binary format v1
    if (self.magic == 0 || self.version == 0){
        NSLog(@"bcf: invalid BinaryCert object");
        return nil;
    }
    
    if (![self checkValid]){
        NSLog(@"bcf: miss required field values");
        return nil;
    }

    NSMutableData *pack = [NSMutableData data];
    uint32_t magic = CFSwapInt32HostToBig(self.magic);
    [pack appendBytes:&magic length:sizeof(uint32_t)];
    uint32_t version = CFSwapInt32HostToBig(self.version);
    [pack appendBytes:&version length:sizeof(uint32_t)];
    
    NSData *snData = [self.SN dataUsingEncoding:NSUTF8StringEncoding];
    [self _writeData:snData withTag:TAG_SN intoPack:pack];
    NSData *midData = [self.email dataUsingEncoding:NSUTF8StringEncoding];
    [self _writeData:midData withTag:TAG_EMAIL intoPack:pack];
    [self _writeData:self.pushTokenData withTag:TAG_PUSH_TOKEN intoPack:pack];
    [self _writeData:self.pushCertData withTag:TAG_PUSH_CERT intoPack:pack];
    [self _writeData:self.pushKeyData withTag:TAG_PUSH_KEY intoPack:pack];
    [self _writeData:self.ecPubKeyData withTag:TAG_EC_PUB_KEY intoPack:pack];
    [self _writeData:self.ecPrivKeyData withTag:TAG_EC_PRIV_KEY intoPack:pack];
    [self _writeData:self.rsaPubKeyData withTag:TAG_RSA_PUB_KEY intoPack:pack];
    [self _writeData:self.rsaPrivKeyData withTag:TAG_RSA_PRIV_KEY intoPack:pack];
    [self _writeData:self.idCertData withTag:TAG_ID_CERT intoPack:pack];
    [self _writeData:self.idPrivKeyData withTag:TAG_ID_PRIV_KEY intoPack:pack];
    [self _writeData:self.masterPushToken withTag:TAG_MASTER_PUSH_TOKEN intoPack:pack];
    [self _writeData:self.legacyFullIdentityData withTag:TAG_LEGACY_FULL_IDENTIDY_KEY intoPack:pack];
    return pack;
}

- (void)_writeData:(NSData *)data withTag:(uint32_t)tag intoPack:(NSMutableData *)pack {
    if (data != nil){
        tag = CFSwapInt32HostToBig(tag);
        [pack appendBytes:&tag length:sizeof(uint32_t)];
        uint32_t len = (uint32_t)[data length];
        len = CFSwapInt32HostToBig(len);
        [pack appendBytes:&len length:sizeof(uint32_t)];
        [pack appendData:data];
    }
}

- (BOOL)checkValid {
    if (self.SN == nil || [self.SN length] == 0){
        NSLog(@"SN nil ");
        return NO;
    }
    if (self.email == nil || [self.email length] == 0){
        NSLog(@"email nil ");
        return NO;
    }
    if ([self.pushTokenData length] == 0){
        NSLog(@"pushTokenData nil ");
        return NO;
    }
    if ([self.pushCertData length] == 0){
        NSLog(@"pushCertData nil ");
        return NO;
    }
    if ([self.pushKeyData length] == 0){
        NSLog(@"pushKeyData nil ");
        return NO;
    }
    
    if ([self.idCertData length] == 0){
        NSLog(@"idCertData nil ");
        return NO;
    }
    if ([self.idPrivKeyData length] == 0){
        NSLog(@"idPrivKeyData nil ");
        return NO;
    }

    BOOL useLegacyFullIdentity = ([self.legacyFullIdentityData length] != 0);
    BOOL useMpPrivateKeys = NO;
    if ([self.ecPrivKeyData length] != 0 && [self.rsaPrivKeyData length] != 0){
        useMpPrivateKeys = YES;
    }
    
    if (!useLegacyFullIdentity && !useMpPrivateKeys){
        NSLog(@"Missing mp staff");
        return NO;
    }
    
    return YES;
}

+ (instancetype)IMCert {
    BinaryCert *bc = [BinaryCert new];
    bc.magic = MAGIC_IM;
    bc.version = VERSION_ONE;
    return bc;
}

+ (instancetype)XCCert {
    BinaryCert *bc = [BinaryCert new];
    bc.magic = MAGIC_XC;
    bc.version = VERSION_ONE;
    return bc;
}

+ (instancetype)HMCert {
    BinaryCert *bc = [BinaryCert new];
    bc.magic = MAGIC_HM;
    bc.version = VERSION_ONE;
    return bc;
}

+ (instancetype)DWCert {
    BinaryCert *bc = [BinaryCert new];
    bc.magic = MAGIC_DW;
    bc.version = VERSION_ONE;
    return bc;
}

- (BOOL)isIMCert {
    return (self.magic == MAGIC_IM);
}

- (BOOL)isXCCert {
    return (self.magic == MAGIC_XC);
}

- (BOOL)isHMCert {
    return (self.magic == MAGIC_HM);
}

- (BOOL)isDWCert {
    return (self.magic == MAGIC_DW);
}


- (BOOL)_migrateV0Data:(NSData *)bindata {
    NSLog(@"bcf: try parsing data with old V0...");
    
    self.magic = MAGIC_IM;
    self.version = VERSION_ONE;
    
    const UInt8 *dataPtr = CFDataGetBytePtr((CFDataRef)bindata);
    uint32_t flag = *(uint32_t *)(dataPtr);
    flag = CFSwapInt32BigToHost(flag);
    if ((flag & 0xffffff00) != 0x10000c00){
        NSLog(@"bcf: data is not v0 format");
        return NO;
    }
    
    return [self _parseFields:dataPtr totalLength:[bindata length] tagSize:1 lenSize:2];
}

- (BOOL)_parseV1Data:(NSData *)bindata {
    NSLog(@"bcf: try parsing data with V1...");
    const UInt8 *dataPtr = CFDataGetBytePtr((CFDataRef)bindata);
    // magic
    uint32_t magic = *(uint32_t *)(dataPtr);
    magic = CFSwapInt32BigToHost(magic);
    if (magic == MAGIC_IM || magic == MAGIC_XC || magic == MAGIC_HM || magic == MAGIC_DW){
        self.magic = magic;
    }else{
        NSLog(@"bcf: magic 0x%0x is unknown!", magic);
        return NO;
    }
    
    // version
    uint32_t version = *(uint32_t *)(dataPtr+4);
    version = CFSwapInt32BigToHost(version);
    NSLog(@"bcf: version %d", version);
    self.version = version;
    
 
    // fields
    NSUInteger length = [bindata length] - 8;
    BOOL fieldsOK = [self _parseFields:(dataPtr+8) totalLength:length  tagSize:4 lenSize:4];
    if (!fieldsOK){
        NSLog(@"bcf: fail to parse fields!");
        return NO;
    }
    
    return YES;
}

- (BOOL)_parseFields:(const UInt8 *)dataPtr
         totalLength:(NSUInteger)dataLen
             tagSize:(int)tsz
             lenSize:(int)lsz {
    
    uint32_t tag = 0;
    uint32_t len = 0;
    NSUInteger offset = 0;
    NSUInteger total = dataLen;
    while (offset < total){
        tag = *(uint32_t *)(dataPtr + offset);
        tag = CFSwapInt32BigToHost(tag);
        if (tsz == 1){
            // old format
            tag = (tag>>24);
        }
        offset += tsz;

        len = *(uint32_t *)(dataPtr + offset);
        len = CFSwapInt32BigToHost(len);
        if (lsz == 2){
            // old format
            len = (len>>16);
        }
        offset += lsz;
        
        NSLog(@"tag: 0x%0x len: %d", tag, len);
        //NSLog(@"range (%lu, %d), total %lu", offset , len ,total);
        
        if (offset + len > total) {
            NSLog(@"Err: not enough data");
            return NO;
        }
        
        NSData *sub = [NSData dataWithBytes:(dataPtr+offset) length:len];
        switch (tag) {
            case TAG_SN:
                self.SN = [[NSString alloc] initWithData:sub encoding:NSUTF8StringEncoding];
                break;

            case TAG_EMAIL:
                self.email = [[NSString alloc] initWithData:sub encoding:NSUTF8StringEncoding];
                break;

            case TAG_PUSH_TOKEN:
                self.pushTokenData = sub;
                break;
            
            case TAG_PUSH_CERT:
                self.pushCertData = sub;
                break;
             
            case TAG_PUSH_KEY:
                self.pushKeyData = sub;
                break;
             
            case TAG_EC_PUB_KEY:
                self.ecPubKeyData = sub;
                break;
             
            case TAG_EC_PRIV_KEY:
                self.ecPrivKeyData = sub;
                break;

            case TAG_RSA_PUB_KEY:
                self.rsaPubKeyData = sub;
                break;
             
            case TAG_RSA_PRIV_KEY:
                self.rsaPrivKeyData = sub;
                break;
             
             case TAG_ID_CERT:
                self.idCertData = sub;
                break;

            case TAG_ID_PRIV_KEY:
                self.idPrivKeyData = sub;
                break;
                
            case TAG_MASTER_PUSH_TOKEN:
                self.masterPushToken = sub;
                break;
                
            case TAG_LEGACY_FULL_IDENTIDY_KEY:
                self.legacyFullIdentityData = sub;
                break;

                default:
                    NSLog(@"bcf: unknown tag 0x%x", tag);
                break;
        }
        
        
        offset += len;
    }
    
    
    return YES;
}

@end
