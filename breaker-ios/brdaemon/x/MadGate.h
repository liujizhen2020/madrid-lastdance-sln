#import <Foundation/Foundation.h>

@interface MadGate : NSObject

- (NSDictionary *)createActivationInfo:(NSError **)pErr;
- (void)handleActivationInfo:(NSDictionary *)actInfo withError:(NSError **)pErr;

@end