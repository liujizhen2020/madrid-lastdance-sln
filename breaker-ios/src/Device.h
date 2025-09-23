#import <Foundation/Foundation.h>

@interface Device : NSObject

@property (retain, nonatomic) NSString *SN;
@property (retain, nonatomic) NSString *IMEI;
@property (retain, nonatomic) NSString *BT;
@property (retain, nonatomic) NSString *WIFI;
@property (retain, nonatomic) NSString *ECID;
@property (retain, nonatomic) NSString *UDID;
@property (retain, nonatomic) NSString *PT;
@property (retain, nonatomic) NSString *MEID;
@property (retain, nonatomic) NSString *MLBSN;

@property (assign, nonatomic, getter=isDisabled) BOOL disabled;
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;

+ (instancetype)shared;
- (BOOL)isReady;
- (BOOL)write;
- (BOOL)checkValid;
- (NSData *)ECIDData;
@end