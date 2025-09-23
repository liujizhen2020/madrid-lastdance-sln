#import <Foundation/Foundation.h>
#import "SendResult.h"
#import "../../Sources/BinaryCert.h"

@protocol ServerAPIDelegate<NSObject>

- (NSString *)serverRootURL;

@optional

// phase 3
- (void)providerDidFetchBinaryCert:(BinaryCert *)bc andTaskInfo:(NSDictionary *)taskInfo withError:(NSError *)err;

@end

@interface ServerAPI : NSObject

@property (retain, nonatomic) id<ServerAPIDelegate> delegate;
@property (assign, nonatomic, readonly) int availalbeConnectionsCount;
@property (assign, nonatomic, readonly) int requestingConnectionsCount;

// phase 3
- (void)fetchCertBoxAndTaskInfo:(NSUInteger) pool;
- (void)reportSendResult:(SendResult *)sr;
- (void)reportBadCertBox:(BinaryCert *)bc;


@end
