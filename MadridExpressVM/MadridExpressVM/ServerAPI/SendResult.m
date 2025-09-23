
#import "SendResult.h"

@interface SendResult()

@property (strong, nonatomic) NSMutableSet *mSentPhonesSet;
@property (strong, nonatomic) NSMutableSet *mNgPhonesSet;

@end

@implementation SendResult

- (instancetype)initWithSerialNumber:(NSString *)sn taskID:(NSString *)taskID {
    self = [super init];
    if (self){
        self.serialNumber = sn;
        self.taskID = taskID;
        self.mSentPhonesSet = [NSMutableSet set];
        self.mNgPhonesSet = [NSMutableSet set];
    }
    return self;
}
- (void)addSentPhone:(NSString *)phone {
    if (phone){
        [self.mSentPhonesSet addObject:phone];
    }
}

- (NSArray *)sentPhones {
    return [self.mSentPhonesSet allObjects];
}

- (void)addNgPhone:(NSString *)phone {
    if (phone){
        [self.mNgPhonesSet addObject:phone];
    }
}

- (NSArray *)ngPhones {
    return [self.mNgPhonesSet allObjects];
}

- (void)addFailPhones:(NSArray *)phones {
    self.failPhones = phones;
}

- (BOOL)isSent:(NSString *)phone {
    if (phone == nil){
        return NO;
    }
    return [self.mSentPhonesSet containsObject:phone];
}

- (BOOL)isFailed:(NSString *)phone {
    if (phone == nil){
        return NO;
    }
    return (NSNotFound != [self.failPhones indexOfObject:phone]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<SendResult %p, sn: %@, taskID: %@, sent: %ld ng: %ld >", self, self.serialNumber, self.taskID, (long)self.mSentPhonesSet.count, (long)self.mNgPhonesSet.count];
}

@end
