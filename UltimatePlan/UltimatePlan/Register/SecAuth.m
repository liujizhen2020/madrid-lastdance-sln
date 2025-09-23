//
//  SecAuth.m
//  UltimatePlan
//
//  Created by yt on 29/08/23.
//

#import "SecAuth.h"
#import "x/NSMutableURLRequest+AuthKit.h"
#import "util.h"

#define GET_SMS_TIMEOUT 50


@interface SecAuth()

@property (weak, nonatomic) MadridConfig *cfg;
@property (strong, nonatomic) NSString *smsCode;
@property (copy, nonatomic) SecAuthCallback callback;
@property (assign, nonatomic) long smsExpireTs;
@property (strong, nonatomic) NSTimer *smsTimer;

@property (strong, nonatomic) NSString *phoneNumID;

@end

@implementation SecAuth

- (instancetype)initWithConfig:(MadridConfig *)cfg {
    self = [super init];
    if (self){
        self.cfg = cfg;
    }
    return self;
}

- (void)start:(SecAuthCallback)cb {
    if (self.cfg.smsApi == nil){
        cb([NSError errorWithDomain:@"NO_SMS_API" code:-1 userInfo:nil]);
        return;
    }
    
    self.callback = cb;
    __block SecAuth *weakSelf = self;
    [self _sendCodeToTrustedDevice:^(NSError *codeErr){
        if (codeErr != nil){
            NSLog(@"_sendCodeToTrustedDevice err %@", codeErr);
            cb(codeErr);
            
        }else{
            [self _tellAppleToSendSMS:^(NSError *sendErr) {
                if (sendErr != nil){
                    NSLog(@"_tellAppleToSendSMS err %@", sendErr);
                    cb(sendErr);
                    
                }else{
                    NSLog(@"_tellAppleToSendSMS ok");
                    weakSelf.smsExpireTs = (long)[[NSDate date] timeIntervalSince1970] + GET_SMS_TIMEOUT;
                    [weakSelf _startSMSTimer];
                }
            }];
        }
    }];
}

- (void)_startSMSTimer {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.smsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_getSMSTimerHit) userInfo:nil repeats:NO];
    });
}

- (void)_getSMSTimerHit {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    __block SecAuth *weakSelf = self;
    [self _tryGetSMS:^(NSError *smsErr) {
        if (smsErr != nil){
            NSLog(@"_tryGetSMS err %@", smsErr);
            long nowTs = (long)[[NSDate date] timeIntervalSince1970];
            if (nowTs > weakSelf.smsExpireTs){
                smsErr = [NSError errorWithDomain:@"GET_SMS_TIMEOUT" code:-2 userInfo:nil];
                weakSelf.callback(smsErr);
            }else{
                [weakSelf _startSMSTimer];
            }
            
        }else{
            [weakSelf _sendSMSBackToApple:^(NSError *putErr){
                NSLog(@"_sendSMSBackToApple err %@", putErr);
                weakSelf.callback(putErr);
            }];
        }
    }];
}


- (void)_sendCodeToTrustedDevice:(SecAuthCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://gsa.apple.com/auth/verify/trusteddevice"]];
    [req setValue:@"zh_CN" forHTTPHeaderField:@"X-Apple-I-Locale"];
    [req setValue:@"false" forHTTPHeaderField:@"X-Apple-I-CDP-Circle-Status"];
    [req setValue:@"0" forHTTPHeaderField:@"X-Apple-I-Device-Configuration-Mode"];
    [req setValue:@"1706" forHTTPHeaderField:@"X-Apple-iOS-SLA-Version"];
    [req setValue:@"W3sic2xvdElEIjoxLCJkYXRhUHJlZmVycmVkIjp0cnVlLCJwaHlzaWNhbFNpbSI6dHJ1ZSwiaW5Vc2UiOjAsImRlZmF1bHRWb2ljZSI6dHJ1ZX1d" forHTTPHeaderField:@"X-Apple-I-Phone"];
    [req setValue:@"br, gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"%E8%AE%BE%E7%BD%AE/1053 CFNetwork/1206 Darwin/20.1.0" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"US" forHTTPHeaderField:@"X-MMe-Country"];
    [req setValue:@"PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8YXJyYXkvPgo8L3BsaXN0Pgo=" forHTTPHeaderField:@"X-Apple-I-CFU-State"];
    

    [req ak_addDeviceUDIDHeader];
    
    //    [req ak_addClientInfoHeader];
    NSString *clientInfo = [NSString stringWithFormat:@"<%@> <macOS;11.6.8;20G730> <com.apple.AuthKit/1 (com.apple.systempreferences/14.0)>",mac_copy_model()];
    [req setValue:clientInfo forHTTPHeaderField:@"X-MMe-Client-Info"];

    NSString *idntToken = [[[NSString stringWithFormat:@"%@:%@", self.cfg.altDSID, self.cfg.idmsToken] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    //NSLog(@" 🍅 identity token: %@", idntToken);
    [req setValue:idntToken forHTTPHeaderField:@"X-Apple-Identity-Token"];
    [req setValue:@"GMT+8" forHTTPHeaderField:@"X-Apple-I-TimeZone"];
    [req setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [req setValue:@"0" forHTTPHeaderField:@"X-Apple-I-DeviceUserMode"];
    [req setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"com.apple.authkit.generic" forHTTPHeaderField:@"X-Apple-Security-Upgrade-Context"];
    [req setValue:@"28800" forHTTPHeaderField:@"X-Apple-I-TimeZone-Offset"];
    [req ak_addDeviceSerialNumberHeader];
    [req setValue:@"Preferences" forHTTPHeaderField:@"X-Apple-Client-App-Name"];
    [req setValue:@"application/x-buddyml" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/x-plist" forHTTPHeaderField:@"Content-Type"];
    [req ak_addAnisetteHeaders];
    
    [req setHTTPMethod:@"GET"];
    
    __block SecAuth *weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
        NSInteger sc = rsp.statusCode;
        NSLog(@"send code to trusted device, sc %ld ~ %@", (long)sc, rsp.URL.absoluteString);
        NSLog(@"send code to trusted device, text: \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [data writeToFile:@"/tmp/_sendCodeToTrustedDevice.txt" atomically:NO];
        
        if (sc == 200){
            NSString *pn = [self _extractPhoneNumID:data];
            if (pn == nil){
                NSLog(@"@@@ FAIL TO GET PHONE NUM ID");
                cb([NSError errorWithDomain:@"SA_NO_PHONE_ID" code:-11 userInfo:nil]);
            }else{
                weakSelf.phoneNumID = pn;
                NSLog(@"send code to trusted device ok");
                cb(nil);
            }
            
        }else{
           NSError *xErr = [NSError errorWithDomain:@"SEND_LOGIN_CODE_FAIL" code:sc userInfo:nil];
           cb(xErr);
        }
    }];
    [task resume];
}



- (void)_tellAppleToSendSMS:(SecAuthCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"phoneNumID = %@", self.phoneNumID);
    if (self.phoneNumID == nil){
        cb([NSError errorWithDomain:@"NO_PHONE_NUM_NO_SMS" code:-22 userInfo:nil]);
        return;
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://gsa.apple.com/auth/verify/phone/put?mode=sms&referrer=/auth/verify/trusteddevice"]];
    [req setValue:@"zh_CN" forHTTPHeaderField:@"X-Apple-I-Locale"];
    [req setValue:@"false" forHTTPHeaderField:@"X-Apple-I-CDP-Circle-Status"];
    [req setValue:@"0" forHTTPHeaderField:@"X-Apple-I-Device-Configuration-Mode"];
    [req setValue:@"1706" forHTTPHeaderField:@"X-Apple-iOS-SLA-Version"];
    [req setValue:@"W3sic2xvdElEIjoxLCJkYXRhUHJlZmVycmVkIjp0cnVlLCJwaHlzaWNhbFNpbSI6dHJ1ZSwiaW5Vc2UiOjAsImRlZmF1bHRWb2ljZSI6dHJ1ZX1d" forHTTPHeaderField:@"X-Apple-I-Phone"];
    [req setValue:@"br, gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"%E8%AE%BE%E7%BD%AE/1053 CFNetwork/1206 Darwin/20.1.0" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"US" forHTTPHeaderField:@"X-MMe-Country"];
    [req setValue:@"PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8YXJyYXkvPgo8L3BsaXN0Pgo=" forHTTPHeaderField:@"X-Apple-I-CFU-State"];
    
    [req setValue:@"imessage" forHTTPHeaderField:@"X-Apple-AK-Context-Type"];
    [req setValue:@"facetime,itunesstore" forHTTPHeaderField:@"X-Apple-I-Logged-In-Services"];

 
    [req ak_addDeviceUDIDHeader];
    
    // eg: <iPhone9,1> <iPhone OS;14.2;18B92> <com.apple.AuthKit/1 (com.apple.Preferences/1053)>
    //    [req ak_addClientInfoHeader];
    NSString *clientInfo = [NSString stringWithFormat:@"<%@> <macOS;11.6.8;20G730> <com.apple.AuthKit/1 (com.apple.systempreferences/14.0)>",mac_copy_model()];
    [req setValue:clientInfo forHTTPHeaderField:@"X-MMe-Client-Info"];

    NSString *idntToken = [[[NSString stringWithFormat:@"%@:%@", self.cfg.altDSID, self.cfg.idmsToken] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    //NSLog(@" 🍅 identity token: %@", idntToken);
    [req setValue:idntToken forHTTPHeaderField:@"X-Apple-Identity-Token"];
    [req setValue:@"GMT+8" forHTTPHeaderField:@"X-Apple-I-TimeZone"];
    [req setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [req setValue:@"0" forHTTPHeaderField:@"X-Apple-I-DeviceUserMode"];
    [req setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"com.apple.authkit.generic" forHTTPHeaderField:@"X-Apple-Security-Upgrade-Context"];
    [req setValue:@"28800" forHTTPHeaderField:@"X-Apple-I-TimeZone-Offset"];
    [req ak_addDeviceSerialNumberHeader];
    [req setValue:@"Preferences" forHTTPHeaderField:@"X-Apple-Client-App-Name"];
    [req setValue:@"application/x-buddyml" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/x-plist" forHTTPHeaderField:@"Content-Type"];
    [req ak_addAnisetteHeaders];
    
    [req setHTTPMethod:@"POST"];
    NSDictionary *bodyDict = @{ @"serverInfo": @{ @"phoneNumber.id": self.phoneNumID } };
    [req ak_setBodyWithParameters:bodyDict];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
        NSInteger sc = rsp.statusCode;
        NSLog(@"send login code, sc %ld ~ %@", (long)sc, rsp.URL.absoluteString);
        NSLog(@"send login code, text: \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [data writeToFile:@"/tmp/_tellAppleToSendSMS.txt" atomically:NO];
        
        if (sc == 200){
            NSLog(@"send login code ok");
            cb(nil);
        }else{
           NSError *xErr = [NSError errorWithDomain:@"SEND_LOGIN_CODE_FAIL" code:sc userInfo:nil];
           cb(xErr);
        }
    }];
    [task resume];
}


- (void)_tryGetSMS:(SecAuthCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    __block SecAuth *weakSelf = self;
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.cfg.smsApi]];
    [mReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *rspText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"_tryGetSMS, text \n %@", rspText);
        NSError *smsErr = nil;
        if (error != nil){
            smsErr = [NSError errorWithDomain:@"NO_SMS_BODY_ERR" code:-1 userInfo:nil];
        }else{
            NSLog(@"sms body: %@", rspText);
            smsErr = [NSError errorWithDomain:@"SMS_EXTRACT_CODE_ERR" code:-2 userInfo:nil];
            
            NSString *pattern = @"\\d{6}";
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
            NSArray *matches = [regex matchesInString:rspText options:0 range:NSMakeRange(0, rspText.length)];
            NSString *smsCode = @"";
            for (NSTextCheckingResult *match in matches) {
                  [self.smsTimer invalidate];
                  self.smsTimer = nil;
                  NSRange matchRange = [match range];
                  smsCode = [rspText substringWithRange:matchRange];
                  smsErr = nil;
                  NSLog(@"smsCode: %@", smsCode);
            }
            weakSelf.smsCode = smsCode;
        }
        
        cb(smsErr);
    }];
    [task resume];
}

- (void)_sendSMSBackToApple:(SecAuthCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://gsa.apple.com/auth/verify/phone/securitycode?referrer=/auth/verify/phone/put"]];
    [req setValue:@"zh_CN" forHTTPHeaderField:@"X-Apple-I-Locale"];
    [req setValue:@"false" forHTTPHeaderField:@"X-Apple-I-CDP-Circle-Status"];
    [req setValue:@"0" forHTTPHeaderField:@"X-Apple-I-Device-Configuration-Mode"];
    [req setValue:@"1706" forHTTPHeaderField:@"X-Apple-iOS-SLA-Version"];
    [req setValue:@"W3sic2xvdElEIjoxLCJkYXRhUHJlZmVycmVkIjp0cnVlLCJwaHlzaWNhbFNpbSI6dHJ1ZSwiaW5Vc2UiOjAsImRlZmF1bHRWb2ljZSI6dHJ1ZX1d" forHTTPHeaderField:@"X-Apple-I-Phone"];
    [req setValue:@"br, gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [req setValue:@"%E8%AE%BE%E7%BD%AE/1053 CFNetwork/1206 Darwin/20.1.0" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"US" forHTTPHeaderField:@"X-MMe-Country"];
    [req setValue:@"PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPCFET0NUWVBFIHBsaXN0IFBVQkxJQyAiLS8vQXBwbGUvL0RURCBQTElTVCAxLjAvL0VOIiAiaHR0cDovL3d3dy5hcHBsZS5jb20vRFREcy9Qcm9wZXJ0eUxpc3QtMS4wLmR0ZCI+CjxwbGlzdCB2ZXJzaW9uPSIxLjAiPgo8YXJyYXkvPgo8L3BsaXN0Pgo=" forHTTPHeaderField:@"X-Apple-I-CFU-State"];
    
    [req setValue:@"imessage" forHTTPHeaderField:@"X-Apple-AK-Context-Type"];
    [req setValue:@"facetime,itunesstore" forHTTPHeaderField:@"X-Apple-I-Logged-In-Services"];

 
    [req ak_addDeviceUDIDHeader];
    
    // eg: <iPhone9,1> <iPhone OS;14.2;18B92> <com.apple.AuthKit/1 (com.apple.Preferences/1053)>
    //    [req ak_addClientInfoHeader];
    NSString *clientInfo = [NSString stringWithFormat:@"<%@> <macOS;11.6.8;20G730> <com.apple.AuthKit/1 (com.apple.systempreferences/14.0)>",mac_copy_model()];
    [req setValue:clientInfo forHTTPHeaderField:@"X-MMe-Client-Info"];

    NSString *idntToken = [[[NSString stringWithFormat:@"%@:%@", self.cfg.altDSID, self.cfg.idmsToken] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    //NSLog(@" 🍅 identity token: %@", idntToken);
    [req setValue:idntToken forHTTPHeaderField:@"X-Apple-Identity-Token"];
    [req setValue:@"GMT+8" forHTTPHeaderField:@"X-Apple-I-TimeZone"];
    [req setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [req setValue:@"0" forHTTPHeaderField:@"X-Apple-I-DeviceUserMode"];
    [req setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    [req setValue:@"com.apple.authkit.generic" forHTTPHeaderField:@"X-Apple-Security-Upgrade-Context"];
    [req setValue:@"28800" forHTTPHeaderField:@"X-Apple-I-TimeZone-Offset"];
    [req ak_addDeviceSerialNumberHeader];
    [req setValue:@"Preferences" forHTTPHeaderField:@"X-Apple-Client-App-Name"];
    [req setValue:@"application/x-buddyml" forHTTPHeaderField:@"Accept"];
    [req setValue:@"application/x-plist" forHTTPHeaderField:@"Content-Type"];
    [req ak_addAnisetteHeaders];
    
    [req setHTTPMethod:@"POST"];
    NSDictionary *bodyDict = @{
        @"securityCode.code": self.smsCode,
        @"serverInfo": @{
            @"mode": @"sms",
            @"phoneNumber.id": self.phoneNumID }
    };
    [req ak_setBodyWithParameters:bodyDict];
    
    __block SecAuth *weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSHTTPURLResponse *rsp = (NSHTTPURLResponse *)response;
        NSInteger sc = rsp.statusCode;
        NSLog(@"put sms, sc %ld ~ %@", (long)sc, rsp.URL.absoluteString);
        NSString *rspText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"put sms, text: \n%@", rspText);
        
        [data writeToFile:@"/tmp/_sendSMSBackToApple.txt" atomically:NO];
        
        /*
         <xmlui action="dismiss" />
         */
        
        if (sc == 200 && [rspText containsString:@"action=\"dismiss"]){
            NSLog(@"put sms ok");
            
            // get PET
            NSError *petErr = nil;
            NSDictionary *rspHeaders = [rsp allHeaderFields];
            NSString *petRaw = rspHeaders[@"X-Apple-PE-Token"];
            NSLog(@"petRaw %@", petRaw);
            if (petRaw == nil){
                petErr = [NSError errorWithDomain:@"PUT_SMS_RSP_NO_PET" code:204 userInfo:nil];
            }else{
                NSData *xpetData = [[NSData alloc] initWithBase64EncodedString:petRaw options:0];
                NSString *xpet = [[NSString alloc] initWithData:xpetData encoding:NSUTF8StringEncoding];
                NSLog(@"xpet %@", xpet);
                NSArray *parts = [xpet componentsSeparatedByString:@":"];
                if ([parts count] != 3){
                    // com.apple.gs.idms.pet:{long value...PET}:300
                    petErr = [NSError errorWithDomain:@"PUT_SMS_RSP_PET_NG" code:205 userInfo:nil];
                }else{
                    NSString *pet = parts[1];
                    NSLog(@"🌶 ✅ pet %@", pet);
                    weakSelf.cfg.PET = pet;
                }
            }
            cb(petErr);
            
        }else{
           NSError *xErr = [NSError errorWithDomain:@"PUT_SMS_CODE_FAIL" code:sc userInfo:nil];
           cb(xErr);
        }
    }];
    [task resume];
}

- (NSString *)_extractPhoneNumID:(NSData *)data {
    NSError *err;
    NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"phoneNumber.id=\"(.*)\"" options:NSRegularExpressionCaseInsensitive error:&err];
    
    if (err) {
        NSLog(@"Error %@", [err description]);
    }

    NSRange r = [regex rangeOfFirstMatchInString:body options:0 range:NSMakeRange(0, [body length])];
    if (r.location == NSNotFound){
        NSLog(@"phoneNumber.id NOT FOUND");
        return nil;
    }
    
    NSString *x = [body substringWithRange:r];
    NSLog(@"☎️ %@", x);
    x = [x stringByReplacingOccurrencesOfString:@"phoneNumber.id=" withString:@""];
    x = [x stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    if ([x length] == 0){
        return nil;
    }
    NSLog(@"☎️ bingo. got id = %@", x);
    return x;
}

@end
