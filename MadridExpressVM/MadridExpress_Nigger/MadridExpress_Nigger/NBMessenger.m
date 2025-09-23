//
//  Messenger.m
//  LastHope
//
//  Created by yt on 23/9/2021.
//

#import "NBMessenger.h"
#import "NBSecureTunnel.h"
#import "NBLegacySealer.h"
#import "NBTextMessage.h"
#import "NBPeerBuddy.h"
#import "util.h"
#import "../../Sources/BinaryCert.h"
#import "x/NSData+FTServices.h"

#define QUERY_TIMEOUT   40

@interface NBMessenger()<SecureTunnelDelegate>

@property (strong, nonatomic) BinaryCert *cert;
@property (weak, nonatomic) id<NBMessengerDelegate> delegate;

@property (strong, nonatomic) NBPeerBuddy *buddy;

@property (strong, nonatomic) NBSecureTunnel *tunnel;
@property (assign, nonatomic) BOOL canSend;

@property (strong, nonatomic) NSArray *targets;
@property (strong, nonatomic) NSTimer *queryTimer;
@property (strong, nonatomic) NSArray *qrets;

@end

@implementation NBMessenger

+ (instancetype)messengerWithBinaryCert:(BinaryCert *)bc delegate:(id<NBMessengerDelegate>)dlg {
    NBMessenger *m = [NBMessenger new];
    m.cert = bc;
    m.delegate = dlg;
    return m;
}

- (void)openTunnel {
    if (self.tunnel == nil){
        self.tunnel = [[NBSecureTunnel alloc] initWithBinaryCert:self.cert];
        self.tunnel.delegate = self;
        [self.tunnel open];
    }
}

- (void)sendTextMessage:(NSString *)msg withQueryResult:(QueryResultItem *)qr {
    //NSLog(@"sendTextMessage:withQueryResult:");
    //NSLog(@" ---> %@", qr.target);
    [self _sendMessage:msg withQueryResult:qr];
}

- (void)_sendMessage:(NSString *)msg withQueryResult:(QueryResultItem *)qret {
    if (qret == nil){
        NSLog(@"Fatal: CAN NOT SEND, query error");
        return ;
    }
    NBTextMessage *tm = [NBTextMessage new];
    tm.text = msg;
    tm.tpID = [NBPeerBuddy formatTarget:qret.target];
    tm.spID = [NBPeerBuddy formatTarget:self.cert.email];
    
    NSData *msgData = [tm messageBody];
    NSData *encData = [NBLegacySealer sealMessage:msgData withPublicIdentity:qret.publicMPData andBinaryCert:self.cert];
    if (encData == nil){
        NSLog(@"Error, share encData is nil");
        return;
    }

    NSDictionary *dtl = @{
        @"D": @( YES ),
        @"P": encData,
        @"sT": qret.sessionTokenData,
        @"t": qret.pushTokenData,
        @"tP": qret.target,
    };

    long msgID = random_identifier();
    NSDictionary *finalMsgBody = @{
        @"D": @(YES),
        @"E": @"pair",
        @"U": uuid_data(nil),
        @"c": @( 100 ),
        @"ck": @(1),
        @"dtl": @[ dtl ],
        @"rc": @(1),
        @"fcn": @(1),
        @"flc": @(1),
        @"i": @( msgID ),
        @"sP": [NBPeerBuddy formatTarget:self.cert.email],
        @"ua": @"[Mac OS X,10.14,18A391,MacBookPro11,4]",
        @"v": @(3),
    };
    
    [self.tunnel sendPayload:finalMsgBody withTopic:TOPIC_MADRID];
}

- (void)closeTunnel {
    self.canSend = NO;
    [self.tunnel close];
}


#pragma mark - SecureTunnelDelegate

- (void)tunnelIsReadyForFirstPayload:(NBSecureTunnel *)tun {
    NSLog(@" 🎁 tunnelIsReadyForFirstPayload");
    self.canSend = YES;
}

- (void)tunnelIsReadyForNextPayload:(NBSecureTunnel *)tun {
    NSLog(@"tunnelIsReadyForNextPayload");
}

- (void)tunnel:(NBSecureTunnel *)tun didReceiveIncomingMessage:(NSDictionary *)msgDict {
    //NSLog(@"%@ msg %@", NSStringFromSelector(_cmd), msgDict);
    int cmd = [msgDict[@"c"] intValue];
    if (cmd == 255){
        NSLog(@"emu %@ got 255 ... ⛽️ ", self.emuID);
    }else if (cmd == 100){
        NSLog(@"emu %@ got 100 ... 🐥 ", self.emuID);
    }else if (cmd == 101){
        NSString *target = msgDict[@"sP"];
        NSLog(@"emu %@ got 101 ... ✅ %@", self.emuID, target);
        
        // send ok
        if ([self.delegate respondsToSelector:@selector(messenger:didSendMessage:)]){
            [self.delegate messenger:self didSendMessage:target];
        }
        
    }else if (cmd== 102){
        NSString *target = msgDict[@"sP"];
        NSLog(@"emu %@ got 102 ... 👀 %@", self.emuID, target);
    }else if (cmd == 120){
        NSString *target = msgDict[@"sP"];
        NSLog(@"emu %@ got 120 ... 🏓 %@", self.emuID, target);
    }else{
        NSLog(@"emu %@ got im-cmd %d", self.emuID, cmd);
    }
}

- (void)tunnelIsClosedByServer:(NBSecureTunnel *)tun {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    exit(4);
}

@end
