
#import <Foundation/Foundation.h>

@interface IMResult : NSObject

@property (strong, nonatomic) NSString *serialNumber;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *taskID;

@property (strong, nonatomic, readonly) NSArray *sentPhones;
@property (strong, nonatomic, readonly) NSArray *ngPhones;
@property (strong, nonatomic) NSArray *failPhones;

- (instancetype)initWithSerialNumber:(NSString *)sn email:(NSString *)email taskID:(NSString *)taskID;
- (void)addSentPhone:(NSString *)phone;
- (void)addNgPhone:(NSString *)phone;
- (void)addFailPhones:(NSArray *)phones;

- (BOOL)isSent:(NSString *)phone;
- (BOOL)isFailed:(NSString *)phone;

@end
