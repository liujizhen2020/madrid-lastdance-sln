#import "../common/defines.h"
#import "../common/log.h"
#import "../src/Account.h"
#import "../src/Device.h"
#import <CydiaSubstrate.h>
#import <notify.h>

#define ids_log(fmt, ...)   NSLog((@"[IDS] " fmt), ##__VA_ARGS__)
// #define ids_log(fmt, ...) 

static void _sendiMessageActivationResultToDaemon(uint64_t code);

@interface IDSRegistrationMessage : NSObject
{
    NSArray *_services;
}
@property(copy) NSArray *services; // @synthesize services=_services;
@end


// x-headers
@interface IDSRegistration : NSObject
- (NSArray *)vettedEmails;
- (NSString *)regionID;
@end

%hook IDSRegistrationCenter

- (void)_processRegistrationMessage:(id)msg sentRegistrations:(id)regs descriptionString:(id)desc actionID:(id)actId actionString:(id)actStr isDeregister:(_Bool)isDereg deliveredWithError:(id)err resultCode:(long long)retCode resultDictionary:(NSDictionary *)retDict {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"actionString %@",actStr);
	ids_log(@"deliveredWithError %@",err);
	ids_log(@"resultCode %llu",retCode);
	ids_log(@"retDict %@", retDict);
	int ret = -1;
	if (!isDereg && retDict[@"services"]){
		NSArray *svsList = retDict[@"services"];
		for (NSDictionary *s in svsList){
			NSString *sName = s[@"service"];
			if ([@"com.apple.madrid" isEqualToString:sName]){
				NSArray *users = s[@"users"];
				NSDictionary *uRet = [users firstObject];
				if (uRet[@"status"]){
					ret = [uRet[@"status"] intValue];
					ids_log(@"*** raw register ret: %d 🍄 ", ret);
					if (ret == REGISTER_RESULT_OK){
						Account *acc = [[Account alloc] init];
						[acc loadFromFile:ACCOUNT_INFO_PATH];
						NSArray *uris = uRet[@"uris"];
						NSString *uri = @"";
						BOOL matched = NO;
						if([acc checkValid] && uris && [uris count] > 0){
							for(NSDictionary *dict in uris){
								uri = dict[@"uri"];
								ids_log(@"account:%@ uri:%@",acc.email,uri);
								uri = [uri stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
								if ([uri caseInsensitiveCompare:acc.email] == NSOrderedSame){
									matched = YES;
								}
							}
						}
						if (matched){
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
								_sendiMessageActivationResultToDaemon(ret);
							});
						}else{
							ids_log(@"maybe noice from anchor");
						}						
						%orig;						
						return;
					}else{
						_sendiMessageActivationResultToDaemon(ret);
						return;
					}					
				}
			}
		}
	}
	%orig;
}


- (void)__sendMessage:(NSObject *)msg {
	ids_log(@"%@ %@ ~~~ %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [msg class], msg);
	NSString *clsName = NSStringFromClass([msg class]);
	if ([@"IDSAuthenticateMessage" isEqualToString:clsName]){
	}else if ([@"IDSProfileGetHandlesMessage" isEqualToString:clsName]){
	}else if ([@"IDSValidationCertificateMessage" isEqualToString:clsName]){
	}else if ([@"IDSInitializeValidationMessage" isEqualToString:clsName]){
	}else if ([@"IDSRegistrationMessage" isEqualToString:clsName]){
		notify_post(NOTIFY_SEND_REGISTER_MESSAGE);
	}
	%orig;
}

%end // hook IDSAppleIDSRegistrationCenter

//ios 10.x
%hook IDSAppleIDSRegistrationCenter

- (void)_processRegistrationMessage:(id)msg sentRegistrations:(id)regs descriptionString:(id)desc actionID:(id)actId actionString:(id)actStr isDeregister:(_Bool)isDereg deliveredWithError:(id)err resultCode:(long long)retCode resultDictionary:(NSDictionary *)retDict {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"actionString %@",actStr);
	ids_log(@"deliveredWithError %@",err);
	ids_log(@"resultCode %llu",retCode);
	ids_log(@"retDict %@", retDict);
	int ret = -1;
	if (!isDereg && retDict[@"services"]){
		NSArray *svsList = retDict[@"services"];
		for (NSDictionary *s in svsList){
			NSString *sName = s[@"service"];
			if ([@"com.apple.madrid" isEqualToString:sName]){
				NSArray *users = s[@"users"];
				NSDictionary *uRet = [users firstObject];
				if (uRet[@"status"]){
					ret = [uRet[@"status"] intValue];
					ids_log(@"*** raw register ret: %d 🍄 ", ret);
					if (ret == REGISTER_RESULT_OK){						
						Account *acc = [[Account alloc] init];
						[acc loadFromFile:ACCOUNT_INFO_PATH];
						NSArray *uris = uRet[@"uris"];
						NSString *uri = @"";
						BOOL matched = NO;
						if([acc checkValid] && uris && [uris count] > 0){
							for(NSDictionary *dict in uris){
								uri = dict[@"uri"];
								ids_log(@"account:%@ uri:%@",acc.email,uri);
								uri = [uri stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
								if ([uri isEqualToString:acc.email]){
									matched = YES;
								}
							}
						}
						if (matched){
							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
								_sendiMessageActivationResultToDaemon(ret);
							});
						}else{
							ids_log(@"maybe noice from anchor");
						}			
						%orig;						
						return;
					}else{
						_sendiMessageActivationResultToDaemon(ret);
						return;
					}					
				}
			}
		}
	}

	%orig;
}


- (void)__sendMessage:(NSObject *)msg {
	ids_log(@"%@ %@ ~~~ %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [msg class], msg);
	NSString *clsName = NSStringFromClass([msg class]);
	if ([@"IDSAuthenticateMessage" isEqualToString:clsName]){
	}else if ([@"IDSProfileGetHandlesMessage" isEqualToString:clsName]){
	}else if ([@"IDSValidationCertificateMessage" isEqualToString:clsName]){
	}else if ([@"IDSInitializeValidationMessage" isEqualToString:clsName]){
	}else if ([@"IDSRegistrationMessage" isEqualToString:clsName]){
		IDSRegistrationMessage *m = (IDSRegistrationMessage *)msg;
		NSArray *svs = [m services];
		if (svs && [svs count] > 0){
			NSLog(@"IDSRegistrationMessage register message");
			notify_post(NOTIFY_SEND_REGISTER_MESSAGE);
		}
	}

	%orig;
}

%end

%hook IDSRegistrationMessage

- (NSString *)hardwareVersion {
	Device *d = [%c(Device) shared];
	if ([d checkValid]){
		return d.PT;
	}
	return %orig;
}

%end // hook IDSRegistrationMessage

%hook IMDeviceSupport

- (id)model {
	Device *d = [%c(Device) shared];
	if ([d checkValid]){
		return d.PT;
	}
	return %orig;
}

%end // hook IMDeviceSupport

// %hook IDSDAccount

// - (void)_retryRegister {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// }

// - (void)_writeAccountDefaults:(id)defs force:(_Bool)arg2 {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
// 	ids_log(@" ~ x defs %@", defs);
// }

// - (void)_registerForDeviceCenterNotifications {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// }

// %end // IDSDAccount

// %hook IDSDAccountController

// - (void)_repairTimerHit:(id)arg1 {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
// }

// - (void)_addAccount:(id)acc {
// 	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
// 	ids_log(@" ~ add account %@", acc);
// 	%orig;
// }

// - (void)_enableAccountWithUniqueID:(id)arg1 {
// 	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
// 	ids_log(@" ~ enable account %@", arg1);
// 	%orig;
// }

// - (void)_disableAccountWithUniqueID:(id)arg1 {
// 	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
// 	ids_log(@" ~ disable account %@", arg1);
// 	%orig;
// }

// - (void)_loadAndEnableStoredLegacyAccounts {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// }

// - (_Bool)_loadAndEnableStoredAccounts {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// 	return YES;
// }

// - (void)_setupPhoneNumberAccounts {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// }

// - (void)_setupLinkedAccounts {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// }

// - (void)_setupAdHocAccounts {
// 	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
// }

// %end // hook IDSDAccountController

%hook IDSRegistrationController

- (void)center:(id)c succeededIDSAuthentication:(id)r {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"c %@ r %@", c, r);
	%orig;
}

- (void)center:(id)c failedIDSAuthentication:(id)r error:(long long)ec info:(NSDictionary *)info {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"c %@ r %@ ec %lld info %@", c, r, ec, info);
	%orig;
}

- (void)center:(id)c succeededCurrentEmailsRequest:(id)r emailInfo:(NSArray *)ems {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"c %@ r %@ ems %@", c, r, ems);
	%orig;
}

- (void)center:(id)c failedCurrentEmailsRequest:(id)r error:(long long)ec info:(NSDictionary *)info {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"c %@ r %@ ec %lld info %@", c, r, ec, info);
	%orig;
}

- (void)center:(id)c succeededRegistration:(id)r {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"c %@ r %@", c, r);
	%orig;
}

- (void)center:(id)c failedRegistration:(id)r error:(long long)ec info:(NSDictionary *)info {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"c %@ r %@ ec %lld info %@", c, r, ec, info);	
	%orig;
}


// --- send flow
- (_Bool)_sendIDSAuthenticationOrRegistrationIfNeeded:(IDSRegistration *)r {
	ids_log(@"%@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	ids_log(@"r %@ %@", [r class], r);
	ids_log(@"r.vettedEmails %@", [r vettedEmails]);
	ids_log(@"r.regionID %@", [r regionID]);
	return %orig;
}

%end // hook IDSRegistrationController


%hook IDSDServiceController

- (void)_loadServiceWithDictionary:(NSDictionary *)sd {
    if (![@"com.apple.madrid" isEqualToString:sd[@"Identifier"]]){
        // ids_log(@"SKIP load service %@", sd[@"Identifier"]);
        return;
    }
    ids_log(@"  * only load service com.apple.madrid");
    %orig;
}

%end

%hook IDSSMSRegistrationCenter

+ (id)sharedInstance {
	// ids_log(@"%@ %@ will return nil...", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
	return nil;
}

- (id)init {
	//ids_log(@"%@ %@ will return nil...", NSStringFromClass([self class]), NSStringFromSelector(_cmd));	
	return nil;
}

%end // IDSSMSRegistrationCenter

%hook IMSystemMonitor

- (BOOL)isSetup {
	ids_log(@"~ %@ %@ ~ always YES", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
	return YES;
}

%end // hook IMSystemMonitor


%hook IDSRegistrationKeyManager

- (void)_regenerateIdentityTimerFired {
	ids_log(@"SKIP %@ %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

%end // hook IDSRegistrationKeyManager

%hook IDSValidationSession

- (BOOL)_shouldUseDebugPiscoLogging{
	ids_log(@"_shouldUseDebugPiscoLogging to YES");
	return YES;
}

%end

void _sendiMessageActivationResultToDaemon(uint64_t retCode){
	I(@"_sendiMessageActivationResultToDaemon %llu", retCode);
	int ims_token;
	notify_register_check(NOTIFY_IMESSAGE_REGISTER_RESULT, &ims_token);
	uint64_t ims_state = retCode + REGISTER_RESULT_MASK;
	notify_set_state(ims_token, ims_state);
	notify_post(NOTIFY_IMESSAGE_REGISTER_RESULT);
}

