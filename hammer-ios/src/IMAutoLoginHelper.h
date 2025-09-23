#import <Foundation/Foundation.h>

@interface IMAutoLoginHelper : NSObject

// tweak
+ (instancetype)sharedInstance;
- (BOOL)checkReady;
- (BOOL)hasTriggered;
- (void)markTriggered;
- (NSString *)username;
- (NSString *)password;

@end
