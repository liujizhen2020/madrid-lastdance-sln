#import <Foundation/Foundation.h>

@class ServerAPI, Device, BinaryCert, Account;

@protocol ServerAPIDelegate<NSObject>

@optional

- (void)providerDidFetchDevice:(Device *)d withActivationRecord:(NSDictionary *)activationRecord withError:(NSError *)err;
- (void)providerDidFetchAppleId:(Account *)acc withError:(NSError *)err;
- (void)providerDidReportBreakResult:(NSString *)acc withSN:(NSString *)sn withError:(NSError *)err;

@end


@interface ServerAPI : NSObject

@property (retain, nonatomic) id<ServerAPIDelegate> delegate;

// connections 
- (void)fetchDevice;
- (void)fetchAppleId;
- (void)reportBadDevice:(Device *)d;
- (void)reportBadAccount:(Account *)acc;
- (void)reportBreakResult:(NSString *)acc withSN:(NSString *)sn;

@end
