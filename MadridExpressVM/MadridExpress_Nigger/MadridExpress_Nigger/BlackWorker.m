//
//  BlackWorker.m
//  MadridExpress_Nigger
//
//  Created by yt on 18/07/22.
//

#import "BlackWorker.h"
#import "GCDAsyncUdpSocket.h"
#import "NBMessenger.h"

@interface BlackWorker()<GCDAsyncUdpSocketDelegate,NBMessengerDelegate>

// udp
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (assign, nonatomic) long udpTag;

@property (strong, nonatomic) NBMessenger *messenger;

@property (strong, nonatomic) NSTimer *sendTimer;

@end

@implementation BlackWorker

- (void)start {
    NSLog(@"emu %@ BlackWorker -start ", self.emuID);
    //NSLog(@"*** master port = %d", self.masterPort);
    dispatch_queue_t udpQueue = dispatch_queue_create("udp_queue", NULL);
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:udpQueue];
    [self.udpSocket setIPv6Enabled:NO];
    
    [self _notifyMasterWithClientReady];
    
    self.messenger = [NBMessenger messengerWithBinaryCert:self.cert delegate:self];
    self.messenger.emuID = self.emuID;
    [self.messenger openTunnel];
    
    // send with interval
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:self.spConfig.sendInterval target:self selector:@selector(_sendMessage) userInfo:nil repeats:YES];
}

- (void)_sendMessage {
    if (![self.messenger canSend]){
        NSLog(@"... wait tunnel ready ...");
        return;
    }
    QueryResultItem *qr = [self.qrets firstObject];
    if (qr != nil){
        [self.qrets removeObjectAtIndex:0];
        [self.messenger sendTextMessage:self.text withQueryResult:qr];
    }else{
        [self _finishSending];
        
        if (self.sendTimer != nil){
            [self.sendTimer invalidate];
            self.sendTimer = nil;
        }
    }
}

- (void)_finishSending {
    NSLog(@"emu %@ _finishSending... will exit in %d secs", self.emuID, self.spConfig.finishWait);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.spConfig.finishWait * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"emu %@ goodbye", self.emuID);
        exit(0);
    });
}

- (void)_notifyMasterWithClientReady {
    NSMutableData *pkg = [NSMutableData data];
    UInt8 ready = WORKER_STAGE_READY;
    [pkg appendBytes:&ready length:1];
    [pkg appendData:[self.cert.email dataUsingEncoding:NSUTF8StringEncoding]];
    [self.udpSocket sendData:pkg toHost:@"127.0.0.1" port:self.masterPort withTimeout:-1 tag:(++self.udpTag)];
}

- (void)_notifyMasterWithSendResult:(NSString *)sourePeer {
    uint8_t stage = WORKER_STAGE_SENT;
    NSMutableData *pkg = [NSMutableData data];
    [pkg appendBytes:&stage length:1];
    [pkg appendData:[sourePeer dataUsingEncoding:NSUTF8StringEncoding]];
    [self.udpSocket sendData:pkg toHost:@"127.0.0.1" port:self.masterPort withTimeout:-1 tag:(++self.udpTag)];
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    //NSLog(@"udpSocket:didSendDataWithTag: tag %ld", tag);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    //NSLog(@"udpSocket:didReceiveData:fromAddress:withFilterContext: data %@", data);
}


#pragma mark - NBMessengerDelegate

- (void)messenger:(NBMessenger *)msger didFinishQuery:(NSMutableArray *)qrets {
    self.qrets = qrets;
}

- (void)messenger:(NBMessenger *)msger didSendMessage:(NSString *)target {
    if (target){
        [self _notifyMasterWithSendResult:target];
    }
}

@end
