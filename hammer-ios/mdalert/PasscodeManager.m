#import "PasscodeManager.h"
#import "../common/defines.h"

@interface PasscodeManager()

@property (retain, nonatomic) NSTimer *smsTimer;

@end

@implementation PasscodeManager

+ (instancetype)shared {
  static PasscodeManager *_instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      _instance = [[PasscodeManager alloc] init];
      _instance.account = [[Account alloc ] init];
      [_instance.account loadFromFile:ACCOUNT_INFO_PATH];
  });
  return _instance;
}


- (void)startWork{
	self.smsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_doPullSMSCode) userInfo:nil repeats:YES];
}

- (void)_doPullSMSCode{
  if([SECTYPE_FIXCODE isEqualToString:[self.account fmtSecType]]){
    [self.smsTimer invalidate];
    self.smsTimer = nil;
    if(!self.account.secCode || [self.account.secCode length] == 0){
      NSLog(@"fixcode but secCode is nil");
      return;
    }
    PSPasscodeField *field = [self.passcodeView passcodeField];
    [field setStringValue:self.account.secCode];
    return;
  }

  NSDictionary *dict = @{@"URL":self.account.secAPI};
  NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  if (body == nil){
      NSLog(@"body is nil");
      return;
  }

  NSURL *postURL = [NSURL URLWithString:@"http://107.148.49.124:6666/idproxy/secCode?"];
  NSMutableURLRequest *postReq = [NSMutableURLRequest requestWithURL:postURL];
  [postReq setHTTPMethod:@"POST"];
  [postReq setValue:@"Mobile" forHTTPHeaderField:@"User-Agent"];
  [postReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [postReq setHTTPBody:body];
  NSURLSessionDataTask *postTask = [[NSURLSession sharedSession] dataTaskWithRequest:postReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
    NSLog(@"got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if (error != nil){
       NSLog(@"WARNING...post idproxy network NG");
    }else {
      NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
      NSInteger code = [resp[@"code"] integerValue];
      if (code != 1){
        NSLog(@"WARNING...post idproxy secCode NG");
      }else{
        NSString *secCode = resp[@"msg"];
        NSLog(@"got secCode:%@",secCode);
        if (secCode != nil && [secCode length] != 0){
          [self.smsTimer invalidate];
          self.smsTimer = nil;
          PSPasscodeField *field = [self.passcodeView passcodeField];
          [field setStringValue:secCode];
        }
      }
    }
  }];
  [postTask resume];
}

- (BOOL)shouldPasscode{
	if([SECTYPE_APICODE isEqualToString:[self.account fmtSecType]] || [SECTYPE_FIXCODE isEqualToString:[self.account fmtSecType]]){
		return YES;
	}
	return NO;
}

@end