//
//  Messenger.h
//  LastHope
//
//  Created by yt on 23/9/2021.
//

#import <Foundation/Foundation.h>
#import "NBPeerBuddy.h"
#import "QueryResultItem.h"

@class BinaryCert,NBMessenger;

@protocol NBMessengerDelegate <NSObject>

@optional
- (void)messenger:(NBMessenger *)msger didFinishQuery:(NSArray *)qrets;
- (void)messenger:(NBMessenger *)msger didSendMessage:(NSString *)target;

@end

@interface NBMessenger : NSObject

@property (strong, nonatomic) NSString *emuID;

+ (instancetype)messengerWithBinaryCert:(BinaryCert *)bc delegate:(id<NBMessengerDelegate>)dlg;

- (void)openTunnel;
- (BOOL)canSend;

- (void)sendTextMessage:(NSString *)msg withQueryResult:(QueryResultItem *)qr;

- (void)closeTunnel;

@end
