#import "ServerAPI.h"
#import "dec.h"
#import "Device.h"
#import "Account.h"
#import "BinaryCert.h"
#import "../common/defines.h"

static NSString *kDecryptKey = @"ABCDEFGHIJKLMNOP";
static NSString *kUserAgent = @"Madrid";

@interface ServerAPI() 
{
    int _connMax;
    int _connOut;
    NSString* _baseURL;
}

@end

@implementation ServerAPI

- (instancetype)init {
    self = [super init];
    if (self){
        _connMax = (int)[NSURLSessionConfiguration defaultSessionConfiguration].HTTPMaximumConnectionsPerHost;
        _connOut = 0;
        _baseURL = @"http://";
    }
    return self;
}

// connections 
- (int)availConn {
    return (_connMax - _connOut);
}

- (int)busyConn {
    return _connOut;
}

- (void)fetchDevice {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    __block ServerAPI *weakSelf = self;
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iphoneCode/getDeviceToBind",_baseURL]];
    NSMutableURLRequest *fetchReq = [NSMutableURLRequest requestWithURL:fetchURL];
    [fetchReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *fetchTask = [[NSURLSession sharedSession] dataTaskWithRequest:fetchReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        //NSLog(@"rsp %@, err %@", response, error);
        Device *d = nil;
        NSDictionary *activationRecord = nil;
        NSError *err = nil;
        if (error){
            err = [NSError errorWithDomain:@"ERR_NETWORK" code:ERROR_NETWORK userInfo:nil];
        }else{
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code == 1 ){
                NSDictionary *dDict = aesDecryptDictionary(resp[@"Data"],kDecryptKey);
                NSLog(@"dDict:%@",dDict);
                NSDictionary *devDict = dDict[@"DeviceBasic"];
                d = [Device new];
                d.SN = devDict[@"Serial"];
                d.IMEI = devDict[@"Imei"];
                NSUInteger len = [devDict[@"Imei"] length];
                d.MEID = [devDict[@"Imei"] substringToIndex:len-1];
                d.BT = devDict[@"Bt"];
                d.WIFI = devDict[@"Wifi"];
                d.UDID = devDict[@"Udid"];
                d.ECID = devDict[@"Ecid"];
                d.PT = devDict[@"ProductType"];
                d.MLBSN = devDict[@"MLBSerial"];
                
                NSLog(@"got d %@", d);
                if (![d checkValid]){
                    err = [NSError errorWithDomain:@"ERR_DEVICE_INVALID" code:ERROR_SERVER_LOGIC userInfo:nil];
                }else{
                    NSString *deviceCert = dDict[@"DeviceCert"];
                    if (!deviceCert){
                        err = [NSError errorWithDomain:@"ERR_DEVICE_CERT" code:ERROR_SERVER_LOGIC userInfo:nil];
                    }
                    NSData *dCertData = [deviceCert dataUsingEncoding:NSUTF8StringEncoding];
                    activationRecord = [NSPropertyListSerialization propertyListWithData:dCertData options:NSPropertyListImmutable format:NULL error:nil];
                    NSLog(@"activationRecord:%@",activationRecord);
                }

            }else{
                NSString *msg = resp[@"RetMsg"];
                err = [NSError errorWithDomain:msg code:ERROR_SERVER_LOGIC userInfo:nil];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(providerDidFetchDevice:withActivationRecord:withError:)]){
            dispatch_async(dispatch_get_main_queue(),^(){
                [weakSelf.delegate providerDidFetchDevice:d withActivationRecord:activationRecord withError:err];
            });
        }
    }];
    [fetchTask resume];
}

- (void)fetchAppleId {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (_connMax - _connOut <= 0){
        if ([self.delegate respondsToSelector:@selector(providerDidFetchAppleId:withError:)]){
            NSError *connErr = [NSError errorWithDomain:@"ERR_NO_CONN" code:-1001 userInfo:nil];
            [self.delegate providerDidFetchAppleId:nil withError:connErr];
        }
        return;
    }
    _connOut++;
    __block ServerAPI *weakSelf = self;
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/appleId/getIDToBind",_baseURL]];
    NSMutableURLRequest *fetchReq = [NSMutableURLRequest requestWithURL:fetchURL];
    [fetchReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *fetchTask = [[NSURLSession sharedSession] dataTaskWithRequest:fetchReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        _connOut--;
        Account *acc = nil;
        NSError *err = nil;
        if (error){
            err = [NSError errorWithDomain:@"ERR_NETWORK" code:ERROR_NETWORK userInfo:nil];
        }else{
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"resp %@", resp);
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code == 1){
                NSDictionary *accDict = aesDecryptDictionary(resp[@"Data"],kDecryptKey);
                acc = [Account new];
                acc.email = accDict[@"Email"];
                acc.pwd = accDict[@"Password"];
                if(accDict[@"SecType"]){
                    acc.secType = accDict[@"SecType"];
                }
                if(accDict[@"SecAPI"]){
                    acc.secAPI = accDict[@"SecAPI"];
                }
                if(accDict[@"SecCode"]){
                    acc.secCode = accDict[@"SecCode"];
                }
                NSLog(@"got acc %@", acc);
                if (![acc checkValid]){
                    err = [NSError errorWithDomain:@"ERR_ACCOUNT_INVALID" code:ERROR_SERVER_LOGIC userInfo:nil];
                }
            }else{
                if (resp[@"RetMsg"]){
                    NSString *msg = resp[@"RetMsg"];
                    err = [NSError errorWithDomain:msg code:ERROR_SERVER_LOGIC userInfo:nil];
                }else{
                    err = [NSError errorWithDomain:@"ERR_NETWORK" code:ERROR_NETWORK userInfo:nil];
                }
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(providerDidFetchAppleId:withError:)]){
            dispatch_async(dispatch_get_main_queue(),^(){
                NSLog(@"providerDidFetchAppleId err:%@",err);
                [weakSelf.delegate providerDidFetchAppleId:acc withError:err];
            });
        }
    }];
    [fetchTask resume];
}

- (void)reportBadDevice:(Device *)d {
    //NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSString *query = [NSString stringWithFormat:@"serial=%@&status=%d", d.SN, -100];
    //NSLog(@"http query is %@", query); 
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/iphoneCode/disabledStatus",_baseURL]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [reportReq setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        // NSLog(@"got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (!error){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"WARNING...report bad device NG");
            }
        }
    }];
    [reportTask resume];
}

- (void)reportBadAccount:(Account *)acc {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (acc == nil){
        return;
    }
    NSString *email = acc.email;
    if (email == nil){
        return;
    }
    NSString *query = [NSString stringWithFormat:@"email=%@&status=%d", email, -1];
    //NSLog(@"reportBadAccount: query is %@", query); 
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/appleId/disabledStatus",_baseURL]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [reportReq setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        //NSLog(@"reportBadAccount: got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (!error){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"reportBadAccount: WARNING...report bad id NG");
            }
        }
    }];
    [reportTask resume];
}

- (void)reportBreakResult:(NSString *)acc withSN:(NSString *)sn {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSDictionary *ret = @{@"ACC":acc,@"SN":sn};
    NSData *body = [NSJSONSerialization dataWithJSONObject:ret options:0 error:nil];
    if (body == nil){
        NSLog(@"body is nil");
        return;
    }
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/appleId/postBreak",_baseURL]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [reportReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [reportReq setHTTPBody:body];
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSError *reportErr = nil;
        if (error != nil){
            reportErr = [NSError errorWithDomain:@"ERR_NETWORK" code:ERROR_NETWORK userInfo:nil];
        }else {
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"WARNING...report break result NG");
                reportErr = [NSError errorWithDomain:@"ERROR_SERVER_LOGIC" code:ERROR_SERVER_LOGIC userInfo:nil];
            }
        }

        if ([self.delegate respondsToSelector:@selector(providerDidReportBreakResult:withSN:withError:)]){
            [self.delegate providerDidReportBreakResult:acc withSN:sn withError:reportErr];
        }
    }];
    [reportTask resume];
}


@end