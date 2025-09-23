//
//  SecureTunnel.m
//  FireFighter
//
//  Created by zebra on 2021/7/29.
//

#import "NBSecureTunnel.h"
#import "util.h"
#import "NSString+SHA1.h"
#import "../../Sources/BinaryCert.h"
#import <objc/runtime.h>
#import "x/APSEnvironment.h"
#import "x/APSKeepAliveMetadata.h"
#import "x/APSTCPStream.h"
#import "x/APSProtocolParser.h"
#import "x/APNSPackEncoder.h"
#import "x/NSData+IMFoundation.h"
#import "../../Vendor/NSData+FastHex.h"

@interface NBSecureTunnel()<APSTCPStreamDelegate>

@property (assign, nonatomic, getter=isConnected, readwrite) BOOL connected;

@property (strong, nonatomic) BinaryCert *cert;
@property (assign, nonatomic) BOOL firstHeartbeat;
@property (strong, nonatomic) NSTimer *hbTimer;

// aps
@property (strong, nonatomic) APSTCPStream *stream;
@property (strong, nonatomic) APSProtocolParser *parser;
@property (assign, nonatomic) int dnsMs;
@property (assign, nonatomic) int tlsMs;
@property (strong, nonatomic) APSKeepAliveMetadata *meta;

// user connect
@property (assign, nonatomic) BOOL hasSendUserConnect;

@end

@implementation NBSecureTunnel

+ (void)initialize {
    load_binary_apsd();
}

- (instancetype)initWithBinaryCert:(BinaryCert *)bc {
    self = [super init];
    if (self){
        self.cert = bc;
    }
    return self;
}

- (void)open {
    if (self.stream == nil){
        APSEnvironment *env = [objc_getClass("APSEnvironment") environmentForName:@"production"];
        self.stream = [[objc_getClass("APSTCPStream") alloc] initWithEnvironment:env];
        [self.stream setDelegate:self];
        [self.stream setForceWWANInterface:YES];
    }
    [self.stream open];
}

- (void)close {
    self.connected = NO;
    [self.stream close];
}

- (void)sendPayload:(NSDictionary *)payload withTopic:(NSString *)topic {
    //NSLog(@" 🟣 >>> send >>> topic %@, payload %@", topic, payload);
    NSData *hash = [NSString sha1Data:topic];
    long i = [payload[@"i"] longValue];
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:payload format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    NSData *pkg = [self.parser copyMessageWithTopicHash:hash identifier:i payload:data token:self.cert.pushTokenData isPlistFormat:YES lastRTT:@(39)];
    [self sendData:pkg];
}

- (void)sendData:(NSData *)data {
    //NSLog(@" 🟠 >>> send %@", data);
    [self.stream writeDataInBackground:data];
}

#pragma mark - Raw APSD Package

- (void)_sendConnectMessage {
    // ios form
    [self _sendConnectMessage:self.cert.pushTokenData rootUser:YES];
}

- (void)_sendConnectMessage:(NSData *)tokenData rootUser:(BOOL)isRootUser {
    NSLog(@"_sendConnectMessage");
    APNSPackEncoder *encoder = [[objc_getClass("APNSPackEncoder") alloc] initWithMaxTableSize:51200];
    //NSLog(@"* encoder %@", encoder);
    [encoder setCommand:0x7];
    // token
    [encoder addDataWithAttributeId:0x1 data:tokenData isIndexable:YES];
    // state
    [encoder addInt8WithAttributeId:0x2 number:0x1 isIndexable:NO];
    
    // presence flag
    if (isRootUser){
        [encoder addInt32WithAttributeId:0x5 number:0x5 isIndexable:NO];
    }else{
        [encoder addInt32WithAttributeId:0x5 number:0x1 isIndexable:NO];
    }
    
    if (isRootUser){
        NSData *cert = self.cert.pushCertData;
        NSData *nonce = [self _apsdNonceData];
        NSData *sig = [self _apsdSigatureWithNonce:nonce];

        [encoder addDataWithAttributeId:0xc data:cert isIndexable:NO];
        [encoder addDataWithAttributeId:0xd data:nonce isIndexable:NO];
        [encoder addDataWithAttributeId:0xe data:sig isIndexable:NO];
    }
    
    [encoder addInt16WithAttributeId:0x10 number:8 isIndexable:NO];
    [encoder addInt16WithAttributeId:0x11 number:0 isIndexable:NO];
    [encoder addInt16WithAttributeId:0x1a number:0 isIndexable:NO];
    
    NSData *connData = [encoder copyMessage];
    //NSLog(@"conn data %@", connData);
    //[connData writeToFile:@"/tmp/my_conn.bin" atomically:NO];
    if (connData == nil){
        [NSException raise:@"CONN DATA IS NIL" format:@"BAD TUNNEL"];
    }
    [self sendData:connData];
}

- (void)_sendTopicsMessage {
    NSLog(@"_sendTopicsMessage");
    NSArray *enHashes = @[
        [NSString sha1Data:@"com.apple.madrid"],
        [NSString sha1Data:@"com.apple.private.ids"],
        [NSString sha1Data:@"com.apple.private.alloy.quickrelay"],
        [NSString sha1Data:@"com.apple.icloud-container.com.apple.imagent"],
        [NSString sha1Data:@"com.apple.private.alloy.sms"],
        [NSString sha1Data:@"com.apple.maps.icloud"],
        [NSString sha1Data:@"com.apple.private.alloy.biz"],
    ];
    NSArray *igHashes = @[  ];
    NSArray *opHashes = @[  ];
    NSArray *puHashes = @[  ];
    NSData *topicPushToken = self.cert.pushTokenData;
    NSData *topicData = nil;
    
    if ([self.parser respondsToSelector:@selector(copyFilterMessageWithEnabledHashes:ignoredHashes:opportunisticHashes:pausedHashes:token:)]){
        // macos 10.13
        topicData = [self.parser copyFilterMessageWithEnabledHashes:enHashes ignoredHashes:igHashes opportunisticHashes:opHashes pausedHashes:puHashes token:topicPushToken];
    }else if ([self.parser respondsToSelector:@selector(copyFilterMessageWithEnabledHashes:ignoredHashes:opportunisticHashes:nonWakingHashes:pausedHashes:token:)]){
        // macos 11.3
        topicData = [self.parser copyFilterMessageWithEnabledHashes:enHashes ignoredHashes:igHashes opportunisticHashes:opHashes nonWakingHashes:nil pausedHashes:puHashes token:topicPushToken];
    }
    //NSLog(@" 🟣 parser topic data %@", topicData);
        
    if (topicData == nil){
        [NSException raise:@"TOPIC DATA IS NIL" format:@"BAD TUNNEL"];
    }
    [self sendData:topicData];
}

- (void)_sendAckMessage:(NSData *)msgID {
    NSData *ackData = [self.parser copyMessageAcknowledgeMessageWithResponse:0 messageId:msgID];
    //NSLog(@"ack data %@", ackData);
    [self sendData:ackData];
}

- (void)startHeartbeatTimer {
    if (self.hbTimer != nil){
        [self.hbTimer invalidate];
        self.hbTimer = nil;
    }
    self.hbTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(_sendKeepAliveMessage) userInfo:nil repeats:YES];
}

- (void)_sendKeepAliveMessage {
    //NSLog(@"_sendKeepaliveMessage");
    if (self.meta == nil){
        self.meta = [objc_getClass("APSKeepAliveMetadata") new];
        [self.meta setCarrier:@"Unknown"];
        [self.meta setSoftwareVersion:@"10.14"];
        [self.meta setSoftwareBuild:@"18A391"];
        [self.meta setHardwareVersion:@"MacBookPro11,4"];
//        if ([self.meta respondsToSelector:@selector(setKeepAliveInterval:)]){
//            [self.meta setKeepAliveInterval:4];
//        }
    }
    
    NSData *hbData = nil;
    hbData = [self.parser copyKeepAliveMessageWithMetadata:self.meta];
    //NSLog(@" ♥️ parser hb data %@", hbData);
    
    [self sendData:hbData];
}

- (void)_sendActiveIntervalMessage {
    NSLog(@"_sendActiveIntervalMessage");
    NSData *actData = [self.parser copySetActiveState:YES forInterval:0x7fffffff];
    //NSLog(@" 🟡 parser active data %@", actData);
    [self sendData:actData];
}

- (NSData *)_apsdNonceData {
    NSMutableData *nonceOut = [NSMutableData dataWithCapacity:0x11];
    uint8_t ver = 0 ;
    [nonceOut appendBytes:&ver length:0x1];
    
    long nowTs = (long)[[NSDate date] timeIntervalSince1970];
    uint64_t ts = (uint64_t)(nowTs * 1000);
    //NSLog(@"* ts %lld", ts);
    ts = CFSwapInt64HostToBig(ts);
    [nonceOut appendBytes:&ts length:0x8];
    
    uint8_t ranBytes[0x8];
    if (SecRandomCopyBytes(kSecRandomDefault, 0x8, ranBytes) != 0 ){
        NSLog(@"failed to copy random bytes... it rare happen..");
    }
    [nonceOut appendBytes:ranBytes length:0x8];
    return nonceOut;
}

- (NSData *)_apsdSigatureWithNonce:(NSData *)nonceData {
    NSData *hashData = [nonceData SHA1Data];
    //NSLog(@"* nonce hash data %@", hashData);
    
    CFErrorRef cfErr;
    NSDictionary *keyOpts = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                              (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPrivate,
                              (id)kSecAttrKeySizeInBits: @(1024) };
    
    SecKeyRef privKey = SecKeyCreateWithData((__bridge CFDataRef)[self.cert pushKeyData],(__bridge CFDictionaryRef)keyOpts , &cfErr);
    if (privKey == NULL){
        NSLog(@"[id-query] can not create priv key, opts %@", self.cert);
        @throw [NSException exceptionWithName:@"ERR_CREATE_QUERY_PRIV_KEY" reason:@"ERR_CREATE_QUERY_PRIV_KEY" userInfo:nil];
        return nil;
    }
    
    size_t keyBlockSize = SecKeyGetBlockSize(privKey);
    SecTransformRef tf = SecSignTransformCreate(privKey, &cfErr);
    if (cfErr != NULL){ NSLog(@"[id-query] _calcSig err 1/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecDigestTypeAttribute, kSecDigestSHA1, &cfErr);
    if (cfErr != NULL){ NSLog(@"[id-query] _calcSig err 2/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecTransformInputAttributeName, (__bridge CFDataRef)hashData, &cfErr);
    if (cfErr != NULL){ NSLog(@"[id-query] _calcSig err 3/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecKeyAttributeName, privKey, &cfErr);
    if (cfErr != NULL){ NSLog(@"[id-query] _calcSig err 4/6"); CFRelease(tf); return nil; }
    SecTransformSetAttribute(tf, kSecInputIsAttributeName, kSecInputIsDigest, &cfErr);
    if (cfErr != NULL){ NSLog(@"[id-query] _calcSig err 5/6"); CFRelease(tf); return nil; }
    CFDataRef sig = SecTransformExecute(tf, &cfErr);
    if (cfErr != NULL){ NSLog(@"[id-query] _calcSig err 6/6"); CFRelease(sig); CFRelease(tf); return nil; }
    CFRelease(tf);
    CFRelease(privKey);
    
    
    if (sig != NULL && cfErr == NULL && CFDataGetLength(sig) == keyBlockSize){
        uint16_t sigPrefix = 0x101;
        NSMutableData *sigData = [NSMutableData dataWithBytes:&sigPrefix length:0x2];
        [sigData appendBytes:CFDataGetBytePtr(sig) length:CFDataGetLength(sig)];
        CFRelease(sig);
        return sigData;
    }
    CFRelease(sig);
    return nil;
}

#pragma mark - Message Handler
- (void)_handleIncomingAPSMessage:(NSDictionary *)msgDict {
    //NSLog(@" 🟣 _handleIncomingAPSMessage %@", msgDict);
    int apsCmd = [msgDict[@"APSProtocolCommand"] intValue];
    switch (apsCmd) {
        case 0x08:
        {
            // connected response
            int connRspCode = [msgDict[@"APSProtocolConnectedResponse"] intValue];
            NSLog(@"conn response code = %d", connRspCode);
            if (connRspCode != 0){
                NSLog(@" 🍎 Fatal... BAD response code = %d", connRspCode);
                exit(40);
            }else{
                if (!self.hasSendUserConnect){
                    NSLog(@" 🍏 root connect response ok");
                    self.firstHeartbeat = YES;
                    [self _sendKeepAliveMessage];
                    [self startHeartbeatTimer];
                    
                    [self _sendActiveIntervalMessage];
                    return;
                }
                
                NSLog(@" 🍏 user connect response ok");
                [self _sendTopicsMessage];

                if ([self.delegate respondsToSelector:@selector(tunnelIsReadyForFirstPayload:)]){
                    [self.delegate tunnelIsReadyForFirstPayload:self];
                }
            }            
                
        }
            break;
            
        case 0x0a:
        {
            NSData *msgID = msgDict[@"APSProtocolMessageID"];
            [self _sendAckMessage:msgID];
            NSData *payloadData = msgDict[@"APSProtocolPayload"];
            NSError *err;
            NSDictionary *payload = [NSPropertyListSerialization propertyListWithData:payloadData options:NSPropertyListImmutable format:NULL error:&err];
            if (payload == nil){
                // try json
                payload = [NSJSONSerialization JSONObjectWithData:payloadData options:NSJSONReadingAllowFragments error:&err];
            }
            //NSLog(@"got payload %@", payload);
            
            if ([self.delegate respondsToSelector:@selector(tunnel:didReceiveIncomingMessage:)]){
                [self.delegate tunnel:self didReceiveIncomingMessage:payload];
            }
        }
            break;
            
        case 0x0b:
        {
            int deliCode = [msgDict[@"APSProtocolDeliveryStatus"] intValue];
            if (deliCode != 0){
                NSLog(@" 🍎 Fatal.... APSProtocolDeliveryStatus = %d", deliCode);
                exit(50);
            }
            // sent
            if ([self.delegate respondsToSelector:@selector(tunnelIsReadyForNextPayload:)]){
                [self.delegate tunnelIsReadyForNextPayload:self];
            }
        }
            break;
            
        case 0x0d:
        {
            if (self.firstHeartbeat){
                self.firstHeartbeat = NO;
                
                
                if (!self.hasSendUserConnect){
                    [self _sendConnectMessage:self.cert.pushTokenData rootUser:NO];
                    self.hasSendUserConnect = YES;
                }
                
            }
        }
            break;
            
            
            
        default:
            NSLog(@"#default# _handleIncomingAPSMessage %@", msgDict);
            break;
    }
}

#pragma mark - APSTCPStreamDelegate
- (void)tcpStreamDidFailToFindKeepAliveProxyInterface:(id <APSTCPStream>)s {
//    NSLog(@"tcpStreamDidFailToFindKeepAliveProxyInterface");
}

- (void)tcpStreamDidFailToObtainKeepAliveProxy:(id <APSTCPStream>)s willRetry:(BOOL)retry {
//    NSLog(@"tcpStreamDidFailToObtainKeepAliveProxy:willRetry: %@", (retry?@"Y":@"N"));
}

- (void)tcpStreamDidFailToForceKeepAliveProxyInterface:(id <APSTCPStream>)s {
//    NSLog(@"tcpStreamDidFailToForceKeepAliveProxyInterface");
}

- (void)tcpStreamDidFailDueToUntrustedPeer:(id <APSTCPStream>)s {
//    NSLog(@"tcpStreamDidFailDueToUntrustedPeer");
}

- (double)currentKeepAliveInterval {
//    NSLog(@"currentKeepAliveInterval return 900.0");
    return 900.0f;
}

- (void)tcpStream:(id <APSTCPStream>)s errorOccured:(NSError *)err {
    NSLog(@"tcpStream errorOccured %@", err);
    self.connected = NO;
    if ([self.delegate respondsToSelector:@selector(tunnelIsClosedByServer:)]){
        [self.delegate tunnelIsClosedByServer:self];
    }
}

- (void)tcpStreamEndEncountered:(id <APSTCPStream>)s {
    NSLog(@"tcpStreamEndEncountered %@", s);
    self.connected = NO;
    if ([self.delegate respondsToSelector:@selector(tunnelIsClosedByServer:)]){
        [self.delegate tunnelIsClosedByServer:self];
    }
}

-(void)tcpStreamEndEncountered:(id <APSTCPStream>)s withReason:(unsigned int)arg3 {
    // macOS 12.4, 12.5 maybe higher
    [self tcpStreamEndEncountered:s];
}

- (unsigned long long)tcpStream:(id <APSTCPStream>)s dataReceived:(NSData *)data {
    //NSLog(@" 🔵 <<< dataReceived %@", data);
    
    NSDictionary *param;
    BOOL invalid;
    unsigned long long lenParsed;
    [self.parser parseMessage:data parameters:&param isInvalid:&invalid lengthParsed:&lenParsed];
    if (invalid){
        NSLog(@"invalid!");
        return [data length];
    }

    [self _handleIncomingAPSMessage:param];
    return lenParsed;
}

- (unsigned long long)tcpStream:(id <APSTCPStream>)s dataReceived:(NSData *)data isWakingMessage:(BOOL)arg3{
    return [self tcpStream:s dataReceived:data];
}

- (void)tcpStreamHasConnected:(id <APSTCPStream>)s context:(NSDictionary *)ctx enabledPackedFormat:(BOOL)pack maxEncoderTableSize:(unsigned long long)encSize maxDecoderTableSize:(unsigned long long)decSize secureHandshakeEnabled:(BOOL)sec;
{
    self.dnsMs = [ctx[@"dns"] intValue];
    self.tlsMs = [ctx[@"tls"] intValue];
    self.parser = [[objc_getClass("APSProtocolParser") alloc] init];
    [self.parser setIsPackedFormat:pack maxEncoderTableSize:encSize maxDecoderTableSize:decSize];
    
    NSLog(@"🚕 tunnel connected (%d ms + %d ms)", self.dnsMs, self.tlsMs);
    
    // cert from macOS
    NSLog(@"------ cert email %@", self.cert.email);
    NSLog(@"------ master push token %@", self.cert.masterPushToken);
    NSLog(@"------        push token %@", self.cert.pushTokenData);
    [self _sendConnectMessage:self.cert.masterPushToken rootUser:YES];

    self.connected = YES;
}

- (BOOL)tcpStreamHasSpaceAvailable:(id <APSTCPStream>)s {
    //NSLog(@"tcpStreamHasSpaceAvailable %@", s);
    return YES;
}

- (void)tcpStream:(id <APSTCPStream>)s hasDeterminedServerHostname:(NSString *)host {
    //NSLog(@"tcpStream:hasDeterminedServerHostname: %@", host);
}

- (void)tcpStream:(id <APSTCPStream>)s receivedServerBag:(APSConfiguration *)bag {
    //NSLog(@"tcpStream:receivedServerBag: %@", bag);
}


@end
