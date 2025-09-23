#import "ServerAPI.h"
#import "dec.h"
#import "defs.h"

//#define BENCHMARK_FETCH_TASK_REQUEST

static NSString *kDecryptKey=@"ABCDEFGHIJKLMNOP";

@interface ServerAPI()

@property (assign, nonatomic, readwrite) int availalbeConnectionsCount;
@property (assign, nonatomic, readwrite) int requestingConnectionsCount;
@property (retain, nonatomic) NSString *originSN;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSString *rootURL;

@end

@implementation ServerAPI

- (instancetype)init {
	self = [super init];
	if (self){
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.networkServiceType = NSURLNetworkServiceTypeResponsiveData;
        config.allowsCellularAccess = NO;
        config.timeoutIntervalForRequest = 30;
        config.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        config.URLCredentialStorage = nil;
        config.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        config.HTTPMaximumConnectionsPerHost = 32;
        config.HTTPShouldUsePipelining = NO;
        self.session = [NSURLSession sessionWithConfiguration:config];
        
        self.originSN = @"AppleEmulator";
        self.availalbeConnectionsCount = (int)(config.HTTPMaximumConnectionsPerHost);
        self.requestingConnectionsCount = 0;
	}
	return self;
}

- (void)fetchCertBoxAndTaskInfo:(NSUInteger) pool{
	//NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    
    self.rootURL = [self.delegate serverRootURL];
    if (self.rootURL == nil){
        NSLog(@"S: root URL is nil");
        return;
    }
    
    if (self.availalbeConnectionsCount <= 0){
        NSLog(@"S: we don't have any available connections...");
        return;
    }
    
    self.availalbeConnectionsCount--;
    self.requestingConnectionsCount++;
	
#ifdef BENCHMARK_FETCH_TASK_REQUEST
    uint64_t start_ts = (uint64_t)(1000 * [[NSDate date] timeIntervalSince1970]);
#endif
    
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@imessage/pullMultiTask?whoami=emulator&pool=%lu", self.rootURL,(unsigned long)pool]];
    __weak ServerAPI *weakSelf = self;
	NSMutableURLRequest *fetchReq = [NSMutableURLRequest requestWithURL:fetchURL];
	[fetchReq setValue:@"AppleEmulator" forHTTPHeaderField:@"User-Agent"];
	NSURLSessionDataTask *fetchTask = [self.session dataTaskWithRequest:fetchReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        weakSelf.availalbeConnectionsCount++;
        weakSelf.requestingConnectionsCount--;
#ifdef BENCHMARK_FETCH_TASK_REQUEST
        uint64_t end_ts = (uint64_t)(1000 * [[NSDate date] timeIntervalSince1970]);
        NSLog(@"benchmark: req %llu use %llu ms", start_ts, (end_ts - start_ts));
#endif
        //NSLog(@"rsp %@, err %@", response, error);
		NSError *err = nil;
		if (error){
			err = [NSError errorWithDomain:@"ERR_NETWORK" code:ERROR_NETWORK userInfo:nil];
		}else{
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"resp %@", resp);
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code == 1 ){
                	//NSDictionary *retDict = aesDecryptDictionary(resp[@"Data"],kDecryptKey);
                    NSDictionary *retDict = resp[@"Data"];
                    NSLog(@"retDict %@", retDict);
                    if (retDict == nil){
                        err = [NSError errorWithDomain:@"ERR_NO_TASK_DICT" code:ERROR_SERVER_LOGIC userInfo:nil];
                    }else{
                        if (retDict[@"CertTargetInfo"]){
                            NSLog(@"CertTargetInfo:%@",retDict[@"CertTargetInfo"]);
                            NSArray *ctList = retDict[@"CertTargetInfo"];
                            for(NSDictionary *ctDict in ctList){
                                NSMutableDictionary *taskDict = [NSMutableDictionary dictionaryWithDictionary:retDict];
                                [taskDict removeObjectForKey:@"CertTargetInfo"];
                                NSString *cert = ctDict[@"CertBox"];
                                NSArray *tgs = ctDict[@"PhoneNoList"];
                                taskDict[@"PhoneNoList"] = tgs;
                                NSData *cbData = [[NSData alloc] initWithBase64EncodedString:cert options:0];
                                BinaryCert *certBox = [BinaryCert parseFrom:cbData];
                                if (![certBox checkValid]){
                                    NSLog(@"serverAPI serverBox invalid");
                                    continue;
                                }
                                if ([weakSelf.delegate respondsToSelector:@selector(providerDidFetchBinaryCert:andTaskInfo:withError:)]){
                                    dispatch_async(dispatch_get_main_queue(),^(){
                                        [weakSelf.delegate providerDidFetchBinaryCert:certBox andTaskInfo:taskDict withError:err];
                                    });
                                }
                            }
                        }
                    }
            }else{
				if (resp[@"RetMsg"]){
					NSString *msg = resp[@"RetMsg"];
                    NSLog(@"serverAPI server says:%@",msg);
				}else{
                    NSLog(@"serverAPI return bad code");
				}
			}
        }
	}];
	[fetchTask resume];
}

- (void)reportSendResult:(SendResult *)sr {
    if (!sr){
        return;
    }
    NSDictionary *dict = @{@"Identifier":sr.taskID, @"Serial":sr.serialNumber,@"Success":sr.sentPhones};
    NSLog(@"sr:%@",dict);
    NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (body == nil){
        NSLog(@"body is nil");
        return;
    }
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/imessage/pushTaskStatus",self.rootURL]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [reportReq setHTTPBody:body];
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
           // NSLog(@"got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *reportErr = nil;
        if (error != nil){
            reportErr = [NSError errorWithDomain:@"ERR_NETWORK" code:ERROR_NETWORK userInfo:nil];
        }else {
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"WARNING...report send result NG");
                reportErr = [NSError errorWithDomain:@"ERROR_SERVER_LOGIC" code:ERROR_SERVER_LOGIC userInfo:nil];
            }
        }
    }];
    [reportTask resume];
}


- (void)reportBadCertBox:(BinaryCert *)bc {
	NSLog(@"reportBadCertBox %@", bc);
    self.rootURL = [self.delegate serverRootURL];
    if (self.rootURL == nil){
        return;
    }
    
	NSString *query = [NSString stringWithFormat:@"serial=%@&email=%@", bc.SN, bc.email];
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@iphoneCode/bindingRecertInvalid", self.rootURL]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:@"AppleEmulator" forHTTPHeaderField:@"User-Agent"];
    [reportReq setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *reportTask = [self.session dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
		// NSLog(@"got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (!error){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"WARNING...report box invalid NG");
            }
        }
    }];
    [reportTask resume];
}

@end
