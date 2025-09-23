#import <Foundation/Foundation.h>

static NSString* SECTYPE_DIRECT =  @"direct";
static NSString* SECTYPE_APICODE = @"apicode";
static NSString* SECTYPE_FIXCODE = @"fixcode";
static NSString* SECTYPE_UNKNOW  = @"unknow";

@interface Account : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *pwd;
@property (strong, nonatomic) NSString *secType;
@property (strong, nonatomic) NSString *secAPI;
@property (strong, nonatomic) NSString *secCode;

- (NSString *)fmtSecType;
- (BOOL)secEmpty;
- (BOOL)checkValid;
- (BOOL)write:(NSString *)path;
- (BOOL)loadFromFile:(NSString *)path;

@end