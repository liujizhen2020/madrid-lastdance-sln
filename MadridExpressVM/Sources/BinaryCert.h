//
//  BinaryCert.h
//  BinaryCertTest
//
//  Created by yt on 08/08/22.
//

/*
 * document location:
 * https://github.com/ios-hero/binary-cert-format/blob/main/README.md
 */

#import <Foundation/Foundation.h>

@interface BinaryCert : NSObject

@property (assign, nonatomic) uint32_t version;

@property (strong, nonatomic) NSString *SN;
@property (strong, nonatomic) NSString *email;

@property (strong, nonatomic) NSData *pushTokenData;
@property (strong, nonatomic) NSData *pushCertData;
@property (strong, nonatomic) NSData *pushKeyData;

// mp v1
@property (strong, nonatomic) NSData *ecPubKeyData;
@property (strong, nonatomic) NSData *ecPrivKeyData;
@property (strong, nonatomic) NSData *rsaPubKeyData;
@property (strong, nonatomic) NSData *rsaPrivKeyData;
@property (strong, nonatomic) NSData *idCertData;
@property (strong, nonatomic) NSData *idPrivKeyData;

// mp v2
@property (strong, nonatomic) NSData *legacyFullIdentityData;

// macOS
@property (strong, nonatomic) NSData *masterPushToken;

+ (instancetype)parseFrom:(NSData *)data;

- (NSData *)packedData;

- (BOOL)checkValid;


// init a empty business cert 
+ (instancetype)IMCert;
+ (instancetype)XCCert;
+ (instancetype)HMCert;
+ (instancetype)DWCert;

- (BOOL)isIMCert;
- (BOOL)isXCCert;
- (BOOL)isHMCert;
- (BOOL)isDWCert;

@end


