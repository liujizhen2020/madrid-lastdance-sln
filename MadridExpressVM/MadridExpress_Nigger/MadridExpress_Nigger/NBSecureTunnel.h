//
//  SecureTunnel.h
//  FireFighter
//
//  Created by zebra on 2021/7/29.
//

#import <Foundation/Foundation.h>
#import "../../Sources/BinaryCert.h"

//#define TOPIC_PHOTO_STREAM   @"com.apple.private.alloy.photostream"
#define TOPIC_MADRID    @"com.apple.madrid"


@class NBSecureTunnel;

@protocol SecureTunnelDelegate<NSObject>

- (void)tunnelIsReadyForFirstPayload:(NBSecureTunnel *)tun;

- (void)tunnelIsReadyForNextPayload:(NBSecureTunnel *)tun;

- (void)tunnel:(NBSecureTunnel *)tun didReceiveIncomingMessage:(NSDictionary *)msgDict;

- (void)tunnelIsClosedByServer:(NBSecureTunnel *)tun;

@end


@interface NBSecureTunnel : NSObject

@property (weak, nonatomic) id<SecureTunnelDelegate> delegate;
@property (assign, nonatomic, getter=isConnected, readonly) BOOL connected;

- (instancetype)initWithBinaryCert:(BinaryCert *)bc;

- (void)open;
- (void)close;

- (void)sendPayload:(NSDictionary *)payload withTopic:(NSString *)topic;

- (void)sendData:(NSData *)data;

@end

