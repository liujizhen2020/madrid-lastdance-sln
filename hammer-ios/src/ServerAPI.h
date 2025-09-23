#import <Foundation/Foundation.h>

@class ServerAPI, Device, BinaryCert, Account;

@protocol ServerAPIDelegate<NSObject>

@optional

- (void)providerDidSyncCloudBaseURL:(NSString *)baseURL;
- (void)providerDidFetchDevice:(Device *)d withActivationRecord:(NSDictionary *)activationRecord withError:(NSError *)err;
- (void)providerDidFetchAppleId:(Account *)acc withError:(NSError *)err;
- (void)providerDidFetchActivationRecord:(NSDictionary *)record withError:(NSError *)err;
- (void)providerDidReportBinaryCert:(BinaryCert *)cert withOrigSN:(NSString *)origSN withError:(NSError *)err;

@end


@interface ServerAPI : NSObject

@property (retain, nonatomic) id<ServerAPIDelegate> delegate;

// connections 
- (void)syncCloudBaseURL;
- (void)fetchDevice;
- (void)fetchAppleId;
- (void)reportBadDevice:(Device *)fd;
- (void)reportBadAccount:(Account *)acc;
- (void)reportBinaryCert:(BinaryCert *)cert withOrigSN:(NSString *)origSN;

@end
