#import "../common/defines.h"
#import "Device.h"
#import "NSData+FastHex.h"

static NSData* _convertToLittleEndian(NSString *ecid) __attribute__ ((always_inline));

@implementation Device

+ (instancetype)shared {
  static Device *_instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      _instance = [[Device alloc] init];
      [_instance _loadFromCache];
  });
  return _instance;
}

- (BOOL)isReady {
    return (![self isDisabled] && [self isLoaded]);
}

- (BOOL)write {
    if ([self checkValid]){
        NSDictionary *devInfo = @{
            @"SN": self.SN,
            @"IMEI": self.IMEI,
            @"BT": self.BT,
            @"WIFI": self.WIFI,         
            @"UDID": self.UDID,
            @"ECID": self.ECID,
            @"PT": self.PT,
            @"MLBSN":self.MLBSN,
        };
        BOOL ok = [devInfo writeToFile:DEVICE_INFO_PATH atomically:NO];
        return ok;
    }    
    NSLog(@"device is invalid!");
    return NO;
}

- (BOOL)checkValid {
    if (self.SN == nil){
        return NO;
    }
    if (self.IMEI == nil){
        return NO;
    }
    if (self.BT == nil){
        return NO;
    }
    if (self.WIFI == nil){
        return NO;
    }
    if (self.UDID == nil){
        return NO;
    }
    if (self.ECID == nil){
        return NO;
    }
    if (self.PT == nil){
        return NO;
    }
    if (self.MLBSN == nil){
        return NO;
    }
    return YES;
}

- (void)_loadFromCache {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *cached = [NSDictionary dictionaryWithContentsOfFile:DEVICE_INFO_PATH];
    if (cached == nil){
        NSLog(@"FAIL TO LOAD DEVICE INFO");
        return;
    }

    NSLog(@"cached device info is %@", cached);
    if (cached[@"WIFI"]){
        self.WIFI = cached[@"WIFI"];
    }

    if (cached[@"BT"]){
        self.BT = cached[@"BT"];
    }

    if (cached[@"ECID"]){
        self.ECID = cached[@"ECID"];
    }

    if (cached[@"SN"]){
        self.SN = cached[@"SN"];
    }

    if (cached[@"UDID"]){
        self.UDID = cached[@"UDID"];
    }

    if (cached[@"IMEI"]){
        self.IMEI = cached[@"IMEI"];
        NSUInteger len = [self.IMEI length];
        if (len > 1){
            self.MEID = [self.IMEI substringToIndex:len-1];
        }       
    }
    if (cached[@"PT"]){
        self.PT = cached[@"PT"];
    }
    
    if (cached[@"MLBSN"]){
        self.MLBSN = cached[@"MLBSN"];
    }
    NSLog(@"load device info done.");
    self.loaded = YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ %@ %@ >", NSStringFromClass([self class]), self.SN, self.PT, ([self checkValid]?@"Good":@"NG")];
}

- (NSData *)ECIDData {
    if (!self.ECID){
        return nil;
    }
    return _convertToLittleEndian(self.ECID);
}

@end



NSData* _convertToLittleEndian(NSString *ecid) {
    if ([ecid hasPrefix:@"0x"]){
        ecid = [ecid stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }
    if ([ecid hasPrefix:@"0X"]){
        ecid = [ecid stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    }
    NSMutableString *hexEcid = [[NSMutableString alloc] initWithCapacity:16];
    if ([ecid length] < 16){
        for (NSUInteger i=[ecid length]; i<16; i++){
            [hexEcid appendString:@"0"];
        }
    }
    [hexEcid appendString:ecid];
    NSData *ecidData = [NSData dataWithHexString:hexEcid];
    uint64_t decVal = *((uint64_t *)[ecidData bytes]);
    decVal = CFSwapInt64BigToHost(decVal);
    NSData *hostEcidData = [[NSData alloc] initWithBytes:&decVal length:sizeof(uint64_t)];
    return hostEcidData;
}