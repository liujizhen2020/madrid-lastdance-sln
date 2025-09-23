//
//  RoyalMadrid.m
//  ThinAir
//
//  Created by yt on 07/09/22.
//

#import "RoyalMadrid.h"
#import "x/NSMutableURLRequest+AuthKit.h"
#import "x/IDSDaemonController.h"
#import "x/FTPasswordManager.h"
#import "x/IDSAccount.h"
#import "x/IDSService.h"
#import "Madrid.h"
#import "util.h"
#import "SecAuth.h"

NSInteger GSA_BAD_ACCOUNT = 444;

@interface RoyalMadrid()

@property (strong, nonatomic) MadridConfig *config;
@property (strong, nonatomic) SecAuth *sAuth;

@end

@implementation RoyalMadrid

+ (instancetype)madridWithConfig:(MadridConfig *)cfg {
    RoyalMadrid *rm = [RoyalMadrid new];
    rm.config = cfg;
    return rm;
}

- (void)runAll:(MadridCallback)cb {
    __block RoyalMadrid *weakSelf = self;
    
    // gsa
    [self doGsaLogin:^(NSError *gsaErr) {
        if (gsaErr != nil){
            NSLog(@"doGsaLogin err %@", gsaErr);
            cb(gsaErr);
        }else{
            if ([@"trustedDeviceSecondaryAuth" isEqualToString:weakSelf.config.gsaAction] || [@"secondaryAuth" isEqualToString:weakSelf.config.gsaAction] ){
                weakSelf.sAuth = [[SecAuth alloc] initWithConfig:weakSelf.config];
                [weakSelf.sAuth start:^(NSError *saErr) {
                    NSLog(@"🌶 secAuth callback %@", saErr);
                    if (saErr != nil){
                        cb(saErr);
                    }else{
                        [weakSelf _afterGsaActions:cb];
                    }
                }];
            }else{
                [weakSelf _afterGsaActions:cb];
            }
        }
    }];
}


- (void)_afterGsaActions:(MadridCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // delegate
    [self doLoginDelegate:^(NSError *dlgErr) {
        if (dlgErr != nil){
            NSLog(@"doLoginDelegate err %@", dlgErr);
            cb(dlgErr);
        }else{
            // register
            [self registerAccount:^(NSError *regErr) {
                if (regErr != nil){
                    NSLog(@"registerAccount err %@", regErr);
                }
                cb(regErr);
            }];
        }
    }];
}

- (void)doGsaLogin:(MadridCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.config.PET != nil){
        cb(nil);
        return;
    }
    [self _gsaLogin:cb];
}

- (void)doLoginDelegate:(MadridCallback)cb {
    NSDictionary *bodyDict = @{
        @"apple-id": self.config.email,
        @"client-id": self.config.clientID,
        @"password": self.config.PET,
        @"delegates":@{
            @"com.apple.gamecenter": @{},
            @"com.apple.mobileme": @{},
            @"com.apple.private.ids": @{ @"protocol-version": @(4) },
        },
    };
    
    NSMutableURLRequest *mReq = [self _loginDelegateRequest:@"https://setup.icloud.com/setup/iosbuddy/loginDelegates"];
    mReq.HTTPMethod = @"POST";
    [mReq ak_setBodyWithParameters:bodyDict];
    NSURLSession *s = [NSURLSession sharedSession];
    NSURLSessionDataTask *dt = [s dataTaskWithRequest:mReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"doLoginDelegate response text \n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        if (error){
            NSLog(@"login delegate got error: %@\n", error);
            cb([NSError errorWithDomain:@"LOGIN_DELEGATE_NETWORK_ERROR" code:44 userInfo:nil]);
            return;
        }
        
        NSDictionary *rspDict = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:nil];
        if (rspDict[@"status"]){
            int code = [rspDict[@"status"] intValue];
            if (code == 0){
                NSString *dsId = rspDict[@"dsid"];
                
                NSDictionary *delegatesMap = rspDict[@"delegates"];
                NSDictionary *idsRsp = delegatesMap[@"com.apple.private.ids"];
                NSString *authToken = idsRsp[@"service-data"][@"auth-token"];
                
                if (dsId != nil && authToken != nil){
                    self.config.DSID = dsId;
                    self.config.authToken = authToken;
                    
                    cb(nil);
                    return;
                }
            }
        }
        
        cb([NSError errorWithDomain:@"LOGIN_DELEGATE_NO_GOOD_RESULT" code:44 userInfo:nil]);
    }];
    [dt resume];
}

- (void)registerAccount:(MadridCallback)cb {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UPIMAccount *imAcc = [UPIMAccount new];
    imAcc.email = self.config.email;
    imAcc.pwd = self.config.email;
    imAcc.DSID = self.config.DSID;
    imAcc.altDSID = self.config.altDSID;
    imAcc.PET = self.config.PET;
    imAcc.mmeAuthToken = self.config.authToken;
    
    [imAcc addAndRegister];
    
    cb(nil);
}


- (NSMutableURLRequest *)_loginDelegateRequest:(NSString *)u {
    NSURL *theURL = [NSURL URLWithString:u];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:theURL];
    [mReq setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [mReq setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [mReq setValue:@"text/plist" forHTTPHeaderField:@"Content-Type"];
    [mReq ak_addDeviceUDIDHeader];
    [mReq setValue:self.config.country forHTTPHeaderField:@"X-MMe-Country"];
    NSString *clientInfo = [NSString stringWithFormat:@"<%@> <macOS;11.6.8;20G730> <com.apple.AuthKit/1 (com.apple.systempreferences/14.0)>",mac_copy_model()];
    [mReq setValue:clientInfo forHTTPHeaderField:@"X-MMe-Client-Info"];
    [mReq setValue:@"gzip, deflate, br" forHTTPHeaderField:@"Accept-Encoding"];
    [mReq setValue:@"en-us" forHTTPHeaderField:@"Accept-Language"];
    [mReq setValue:@"en-us" forHTTPHeaderField:@"X-MMe-Language"];
    [mReq setValue:@"GMT+8" forHTTPHeaderField:@"X-Apple-I-TimeZone"];
    [mReq setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)" forHTTPHeaderField:@"User-Agent"];
    [mReq setValue:self.config.altDSID forHTTPHeaderField:@"X-Apple-ADSID"];
    [mReq ak_addAnisetteHeaders];
    
    return mReq;
}


extern id AppleIDAuthSupportCreate(int arg0, id arg1, NSError **err);
extern int AppleIDAuthSupportAuthenticate(id ctx, NSURL *gsaURL, NSError **err);
extern id AppleIDAuthSupportCopyProvidedData(id ctx, NSError **err);
extern int AppleIDAuthSupportCopyToken(int arg0, int arg1, int arg2, int arg3);

- (void)_gsaLogin:(MadridCallback)cb {
    NSMutableURLRequest *xReq = [self _gsaRequest:@"https://gsa.apple.com/x"];
    NSMutableDictionary *xHeaders = [NSMutableDictionary dictionaryWithDictionary:[xReq allHTTPHeaderFields]];
    NSLog(@"xHeaders %@", xHeaders);
    NSDictionary *xTime = [NSMutableURLRequest ak_clientTimeHeader];
    
    /*
      ==== CPD from Mac ====
     AppleIDAuthSupportCreate: {
         Password = "<<VALUE>>";
         cpd =     {
             "X-Apple-I-Client-Time" = "2023-09-11T17:33:09Z";
             "X-Apple-I-MD" = "AAAABQAAABDgozYN7dLfPi8piuwvz1F2AAAAAQ==";
             "X-Apple-I-MD-LU" = E366519D98038AB1EE85D141DE52C5421CB8039E217D09201C5A47552C08E2C0;
             "X-Apple-I-MD-M" = "3rJOJ6N9n9xXUMHSecjTRKeR/N090DEKdadQXtOhGTt4O8Zde9+8tqCfWVdTEdmzopIkKU61afG/Np2N";
             "X-Apple-I-MD-RINFO" = 50660608;
             "X-Apple-I-MLB" = C020266027A01682W;
             "X-Apple-I-ROM" = 76e5650e3b5a;
             "X-Apple-I-SRL-NO" = C02D121LPN5V;
             "X-Mme-Device-Id" = "AB0685A6-7BC3-5C30-815A-A225C1C9FDF2";
             bootstrap = 1;
             capp = Messages;
             ckgen = 1;
             icscrec = 1;
             loc = "zh-Hans_US";
             pbe = 0;
             prkgen = 1;
             svct = iCloud;
         };
         kAppleIDAuthSupportClientInfo = "<iMac20,1> <Mac OS X;10.14;18A391> <com.apple.AuthKit/1 (com.apple.akd/1.0)>";
         u = "businessplus666sa@icloud.com";
     }
     */
    
    NSMutableDictionary *mCpd = [NSMutableDictionary dictionary];
    // X-Apple-I-Client-Time
    [mCpd addEntriesFromDictionary:xTime];
    // X-Apple-I-MD
    // X-Apple-I-MD-LU
    // X-Apple-I-MD-M
    // X-Apple-I-MD-RINFO
    // X-Apple-I-MLB
    // X-Apple-I-ROM
    // X-Apple-I-SRL-NO
    // X-Mme-Device-Id
    [mCpd addEntriesFromDictionary:xHeaders];
    
    // bootstrap = 1;
    mCpd[@"bootstrap"] = @(YES);
    // capp = Messages;
    mCpd[@"capp"] = @"Messages";
    // ckgen = 1;
    mCpd[@"ckgen"] = @(1);
    // icscrec = 1;
    mCpd[@"icscrec"] = @(YES);
    // loc = "zh-Hans_US";
    mCpd[@"loc"] = @"en-US";
    // pbe = 0;
    mCpd[@"pbe"] = @(NO);
    // prkgen = 1;
    mCpd[@"prkgen"] = @(YES);
    // svct = iCloud;
    mCpd[@"svct"] = @"iCloud";
    
    
    
    mCpd[@"AppleIDClientIdentifier"] = self.config.clientID;
    
    NSArray *keys = [mCpd allKeys];
    for (NSString *k in keys){
        NSLog(@"cpd %@ -> %@", k, mCpd[k]);
    }
    
    NSString *clientInfo = [NSString stringWithFormat:@"<%@> <macOS;11.6.8;20G730> <com.apple.akd/1.0 (com.apple.akd/1.0)>",mac_copy_model()];
    NSLog(@"client info %@", clientInfo);
    NSDictionary *params =  @{
        @"u": self.config.email,
        @"Password": self.config.pwd,
        @"kAppleIDAuthSupportClientInfo": clientInfo,
        @"cpd": mCpd
    };
    
    NSError *err = nil;
    id ctx = AppleIDAuthSupportCreate(0, params, &err);
    NSURL *gsaURL = [NSURL URLWithString:@"https://gsa.apple.com/grandslam/GsService2"];
    int ret = AppleIDAuthSupportAuthenticate(ctx,gsaURL, &err);
    NSLog(@"auth ret %d, err code: %ld %@", ret, (long)[err code], [err userInfo]);
    if ([err code] == 0){
        //ok
        err = nil;
        NSLog(@"ctx %@", ctx);
        NSDictionary *authInfo = (NSDictionary *)AppleIDAuthSupportCopyProvidedData(ctx, &err);
        NSLog(@"auth info %@", authInfo);

        int sc = [authInfo[@"status-code"] intValue];
        NSString *au = authInfo[@"url"];
        NSLog(@"gsa sc %d, bag %@", sc, au);
        /*
         sc:
            200 ok
            409 secondardAuth
            409 repair
            409 securityUpgrade
            409 trustedDeviceSecondaryAuth
            
         */
        
        BOOL petLater = NO;
        if (sc != 200){
            if (sc == 409 && [au isEqualToString:@"trustedDeviceSecondaryAuth"]){
                NSLog(@"****** trustedDeviceSecondaryAuth ******");
                self.config.gsaAction = @"trustedDeviceSecondaryAuth";
                petLater = YES;
            }else if (sc == 409 && [au isEqualToString:@"repair"]){
                // repair
                // we can continue
                self.config.gsaAction = @"repair";
            }else if (sc == 409 && [au isEqualToString:@"secondaryAuth"]){
                self.config.gsaAction = @"secondaryAuth";
                petLater = YES;
            }else{
                NSString *errMsg = [NSString stringWithFormat:@"GSA,%d-%@",sc,authInfo[@"url"]];
                cb([NSError errorWithDomain:errMsg code:41 userInfo:nil]);
                return;
            }
        }
        
        
        if (!petLater){
            NSString *PET = [[[authInfo objectForKey:@"t"] objectForKey:@"com.apple.gs.idms.pet"] objectForKey:@"token"];
            if (PET == nil){
                NSLog(@"no PET");
                cb([NSError errorWithDomain:@"GSA_NO_PET_ERR" code:44 userInfo:nil]);
                return;
            }
            NSLog(@" 🚁 gsa got PET, %@", PET);
            self.config.PET = PET;
        }
        
        
        NSString *altDSID = [authInfo objectForKey:@"adsid"];
        self.config.altDSID = altDSID;
        
        NSString *idmsToken = [authInfo objectForKey:@"GsIdmsToken"];
        self.config.idmsToken = idmsToken;
        
        cb(nil);
    }else{
        NSInteger ec = [[err userInfo][@"Status"][@"ec"] integerValue];
        NSString *au = [err userInfo][@"Status"][@"au"];
        NSString *em = [err userInfo][@"Status"][@"em"];
        NSString *errMsg = [NSString stringWithFormat:@"%ld,%@,%@", (long)ec, au, em];
        if (ec == -20209 || ec == -36607 ||ec == -20751 || ec == -22406){
            // -20209 ----------- iForgotAppleIdLocked
            // -36607 ----------- Unable to sign you in to your Apple ID, try again later
            // -20751 ----------- "This person is not active."
            // -22406 ----------- "Your Apple ID or password is incorrect."
            cb([NSError errorWithDomain:errMsg code:GSA_BAD_ACCOUNT userInfo:nil]);
        }else{
            // other error
            cb([NSError errorWithDomain:errMsg code:40 userInfo:nil]);
        }
    }
}

- (NSMutableURLRequest *)_gsaRequest:(NSString *)u {
    NSURL *theURL = [NSURL URLWithString:u];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:theURL];
    [mReq ak_addAnisetteHeaders];
    [mReq ak_addDeviceMLBHeader];
    [mReq ak_addDeviceROMHeader];
    [mReq ak_addDeviceSerialNumberHeader];
    [mReq ak_addDeviceUDIDHeader];
    return mReq;
}


@end
