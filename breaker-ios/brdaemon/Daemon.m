#import "Daemon.h"
#import "daemon_stage.h"
#import "handyman.h"
#import "../common/defines.h"
#import "../src/Account.h"
#import "../src/Device.h"
#import "../src/ServerAPI.h"
#import "../src/nk_run_cmd.h"
#import "../src/dump.h"
#import "../src/IMAutoLoginHelper.h"
#import "../src/IMAutoLoginHelper+Caller.h"
#import <objc/runtime.h>
#import <notify.h>
#import <mach/mach.h>

// link /usr/lib/libMobileGestalt.dylib
extern id MGCopyAnswer(NSString *inKey);

@interface Daemon()<ServerAPIDelegate> {
}

@property (strong, nonatomic) ServerAPI *provider;

// stage
@property (strong, nonatomic) NSTimer *stageTimer;
@property (strong, nonatomic) Device *device;
@property (strong, nonatomic) Account *account;
@property (strong, nonatomic) NSDictionary *activationRecord;

@property (assign, nonatomic) int currentStage; 
@property (assign, nonatomic) int expectedStage;

@end


@implementation Daemon

- (void)start {
    NSLog(@"%@ %@ 👍 %@ - %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), BIZ_NAME, BIZ_VERSION);
    NSDictionary *bizDict = @{
		kBizNameKey: BIZ_NAME,
		kBizVersionKey: BIZ_VERSION
	};
	[bizDict writeToFile:(NSString *)kBizInfoPath atomically:NO];
	[self _registerNotifyHandlers];
    self.provider = [ServerAPI new];
    self.provider.delegate = self;
    self.origSN = (NSString *)MGCopyAnswer(@"SerialNumber");
    [self _enterStage:STAGE_RESET];
}

- (void) _writeResetFlag{
	NSDictionary *dict = @{@"T":[NSDate date]};
	[dict writeToFile:LAST_RESET_PATH atomically:NO];
}

- (void)_enterStage:(int)newStage {
	NSLog(@"%@ %@ %d", NSStringFromClass([self class]), NSStringFromSelector(_cmd), newStage);
	if (newStage == self.expectedStage || newStage == STAGE_RESET){
		// normal flow
		self.currentStage = newStage;
	}else{
		NSLog(@"WARN~ wrong stage! (new %d ～ %d expected)", newStage, self.expectedStage);
		return;
	}	
    // __block Daemon *weakSelf = self;
    switch (newStage){
		case STAGE_RESET:
		{
            NSLog(@"STAGE_RESET");
            self.device = nil;
            self.activationRecord = nil;
			self.account = nil;
			nk_clear_tmp_files();
            kc_clear_imsg();
			[self _writeResetFlag];
			[self _invalidateStageTimer];
			[self _checkStageTimeout:TIMEOUT_STAGE_SERVER_API expectedStage:STAGE_DEVICE_INFO];
			break;
		}
		case STAGE_DEVICE_INFO:
		{
			NSLog(@"STAGE_DEVICE_INFO");
			[self _checkStageTimeout:TIMEOUT_STAGE_ACTIVATE_DEVICE expectedStage:STAGE_FAKE_DEVICE];
			NSData *fpKeyData = self.activationRecord[@"ActivationRecord"][@"FairPlayKeyData"];
			NSLog(@"fpKeyData:%@",fpKeyData);
			NSData *derFpKeyData = decode_pem_data(fpKeyData, @"CONTAINER");

			if ([derFpKeyData length] == 0){
				NSLog(@" 😡 PEM decode fp Err");
			    [self _enterStage:STAGE_RESET];
			    return;
			}
			nk_run_cmd("mkdir -p /private/var/mobile/Library/FairPlay/iTunes_Control/iTunes");

			BOOL ok = [derFpKeyData writeToFile:@"/private/var/mobile/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv" atomically:NO];
			if (!ok){
			    NSLog(@" 😡 Write fp key to FairPlay Err");
			    [self _enterStage:STAGE_RESET];
			    return;
			}

			nk_run_cmd("cd /private/var/mobile/Library/FairPlay/iTunes_Control/iTunes; chmod 664 IC-Info.sisv; chown mobile:mobile IC-Info.sisv");

			NSString *cICInfoPath = nk_get_path_from_container(@"Documents/Library/FairPlay/iTunes_Control/iTunes/IC-Info.sisv");
			NSLog(@"cICInfoPath:%@",cICInfoPath);
			ok = [derFpKeyData writeToFile:cICInfoPath atomically:NO];
			if (!ok){
			    NSLog(@" 😡 Write fp key to FairPlay container Err");
			    [self _enterStage:STAGE_RESET];
			    return;
			}
			NSString *chownCMD = [NSString stringWithFormat:@"chown mobile:nobody %@",cICInfoPath];
			nk_run_cmd([chownCMD cStringUsingEncoding:NSUTF8StringEncoding]);

			NSString *chmodCMD = [NSString stringWithFormat:@"chmod 664 %@",cICInfoPath];
			nk_run_cmd([chmodCMD cStringUsingEncoding:NSUTF8StringEncoding]);

			[self _enterStage:STAGE_FAKE_DEVICE];
			break;
		}
		case STAGE_FAKE_DEVICE:
		{
			nk_imsg_kill();
			NSLog(@"STAGE_FAKE_DEVICE");
			[self _checkStageTimeout:TIMEOUT_STAGE_SERVER_API expectedStage:STAGE_ACCOUNT];
			[self.provider fetchAppleId];
			break;
		}
		case STAGE_ACCOUNT:
		{
			NSLog(@"STAGE_ACCOUNT");
			[self _checkStageTimeout:TIMEOUT_STAGE_IMS_REGISTER expectedStage:STAGE_IMS_REGISTER];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	        	[IMAutoLoginHelper prefsIMLogin];
	    	});
			break;
		}
		case STAGE_IMS_REGISTER:
		{
			NSLog(@"STAGE_IMS_REGISTER");
			kc_clear_imsg();
			nk_imsg_kill();
			break;
		}
		case STAGE_SWEEP_UP:
		{
			break;
		}

		case STAGE_BREAK_IT:
		{

		}

		case STAGE_UPLOAD_CERT:
		{
			NSLog(@"STAGE_UPLOAD_CERT");
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
	        	[self _enterStage:STAGE_RESET];
	    	});
			break;
		}
	}
}

- (void)_invalidateStageTimer {
	if (self.stageTimer != nil){
		[self.stageTimer invalidate];
		self.stageTimer = nil;
	}
}

- (void)_checkStageTimeout:(NSTimeInterval)timeout expectedStage:(int)expStage {
	[self _invalidateStageTimer];
	self.expectedStage = expStage;
	self.stageTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(_doStageTimeout) userInfo:nil repeats:YES];
}

- (void)_doStageTimeout {
	NSLog(@"_doStageTimeout current:%d expected:%d",self.currentStage,self.expectedStage);
	if (self.currentStage < self.expectedStage){
		NSLog(@"stage check TIMEOUT ... (current %d , expected %d) 🕙  🕙  🕙 ", self.currentStage, self.expectedStage);
		[self _enterStage:STAGE_RESET];
	}
}


- (void)_handleRegisterResult:(BOOL)isSucc {
	if (isSucc){
		if(self.expectedStage == STAGE_IMS_REGISTER){
			[self _enterStage:STAGE_IMS_REGISTER];
		}else{
			NSLog(@"IMS registered in unknow expectedStage:%d",self.expectedStage);
		}	
	}else{
		if(self.expectedStage == STAGE_IMS_REGISTER){
			[self _enterStage:STAGE_RESET];
		}else{
			NSLog(@"IMS regfatal in unknow expectedStage:%d",self.expectedStage);
		}
	}
}

#pragma mark - handle notify signals
- (void)_registerNotifyHandlers {
	dispatch_queue_t mq =  dispatch_get_main_queue();

	__block Daemon *weakSelf = self;

	// register result
	int reg_ret_token;
	notify_register_dispatch(NOTIFY_IMESSAGE_REGISTER_RESULT, &reg_ret_token, mq, ^(int ims_token){
		uint64_t state = 0;
		notify_get_state(ims_token, &state);
		BOOL isSucc = (state == REGISTER_RESULT_MASK);
		if (isSucc){
			NSLog(@"register code: 0  🐥 ");
		}else{
			NSLog(@"register code: %llu  😡 😡 😡", state - REGISTER_RESULT_MASK);
		}
		[weakSelf _handleRegisterResult:isSucc];
	});

	int accFatalToken = 0;
	notify_register_dispatch(NOTIFY_APPLE_ID_FATAL, &accFatalToken, dispatch_get_main_queue(), ^(int token){
		NSLog(@"got NOTIFY_APPLE_ID_FATAL");
		if(weakSelf.expectedStage == STAGE_IMS_REGISTER){
			[weakSelf.provider reportBadAccount:weakSelf.account];
			[weakSelf _checkStageTimeout:TIMEOUT_STAGE_SERVER_API expectedStage:STAGE_APPLEID];
			nk_run_cmd("killall -9 Preferences");
			[weakSelf.provider fetchAppleId];
		}
	});

	int accLockToken = 0;
	notify_register_dispatch(NOTIFY_APPLE_ID_LOCKED, &accLockToken, dispatch_get_main_queue(), ^(int token){
		NSLog(@"got NOTIFY_APPLE_ID_LOCKED");
		if(weakSelf.expectedStage == STAGE_IMS_REGISTER){
			[weakSelf.provider reportBadAccount:weakSelf.account];
			[weakSelf _checkStageTimeout:TIMEOUT_STAGE_SERVER_API expectedStage:STAGE_APPLEID];
			nk_run_cmd("killall -9 Preferences");
			[weakSelf.provider fetchAppleId];
		}
	});

}

#pragma mark - ServerAPIDelegate

- (void)providerDidSyncCloudBaseURL:(NSString *)baseURL{
	NSLog(@"serve for endpoint:%@",baseURL);
	[self.provider fetchDevice];
}

- (void)providerDidFetchDevice:(Device *)device withActivationRecord:(NSDictionary *)activationRecord withError:(NSError *)err {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSLog(@"device %@ err %@", device, err);
	if (err != nil){		
		NSLog(@"providerDidFetchDevice...err %@", err);
		return;
	}
	if (self.expectedStage != STAGE_DEVICE_INFO){
		NSLog(@"WARN~ we got device... but not expecting... now DROP it");
		return;
	}
    self.device = device;
    self.activationRecord = activationRecord;
    [self.device write];
    [self _enterStage:STAGE_DEVICE_INFO];
}

- (void)providerDidFetchAppleId:(Account *)acc withError:(NSError *)err {
    NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    NSLog(@"account %@ err %@", acc, err);
	if (err != nil){		
		NSLog(@"providerDidFetchAppleId...err %@", err);
		return;
	}
	if (self.expectedStage != STAGE_APPLEID){
		NSLog(@"WARN~ we got account... but not expecting... now DROP it");
		return;
	}
    self.account = acc;
    [self.account write:ACCOUNT_INFO_PATH];
    [self _enterStage:STAGE_APPLEID];
}

- (void)providerDidReportBinaryCert:(BinaryCert *)cert withOrigSN:(NSString *)origSN withError:(NSError *)err {
	NSLog(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	if (err != nil){
		NSLog(@"%@ %@ err %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), err);
		[self _invalidateStageTimer];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _enterStage:STAGE_RESET];
        });
		return;
	}
	[self _enterStage:STAGE_UPLOAD_CERT];
}

@end