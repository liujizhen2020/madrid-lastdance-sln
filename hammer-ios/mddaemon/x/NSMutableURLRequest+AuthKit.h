@interface NSMutableURLRequest(AuthKit)


// Image: /System/Library/PrivateFrameworks/AuthKit.framework/AuthKit

+ (id)ak_anisetteHeadersWithCompanionData:(id)arg1;
+ (id)ak_anisetteHeadersWithData:(id)arg1;
+ (id)ak_clientTimeHeader;
+ (id)ak_proxiedAnisetteHeadersWithData:(id)arg1;

- (void)_setAuthorizationHeaderWithToken:(id)arg1 altDSID:(id)arg2 key:(id)arg3;
- (void)ak_addAbsintheHeader;
- (void)ak_addAcceptedSLAHeaderWithVersion:(unsigned int)arg1;
- (void)ak_addAnisetteHeaders;
- (void)ak_addAuthorizationHeaderWithHeartbeatToken:(id)arg1 forAltDSID:(id)arg2;
- (void)ak_addAuthorizationHeaderWithIdentityToken:(id)arg1 forAltDSID:(id)arg2;
- (void)ak_addAuthorizationHeaderWithServiceToken:(id)arg1 forAltDSID:(id)arg2;
- (void)ak_addClientInfoHeader;
- (void)ak_addCompanionClientInfoHeader:(id)arg1;
- (void)ak_addContextHeaderForServiceType:(int)arg1;
- (void)ak_addContinutationKeyHeader:(id)arg1;
- (void)ak_addCountryHeader;
- (void)ak_addDeviceMLBHeader;
- (void)ak_addDeviceROMHeader;
- (void)ak_addDeviceSerialNumberHeader;
- (void)ak_addDeviceUDIDHeader;
- (void)ak_addEphemeralAuthHeader;
- (void)ak_addICSCIntentHeader;
- (void)ak_addICSCRecoveryHeaderWithIdentityToken:(id)arg1 forAltDSID:(id)arg2;
- (void)ak_addInternalBuildHeader;
- (void)ak_addLocalUserHasAppleIDLoginHeader;
- (void)ak_addPRKRequestHeader;
- (void)ak_addPasswordResetKeyHeader:(id)arg1;
- (void)ak_addProxiedAnisetteHeaders:(id)arg1;
- (void)ak_addProxiedClientInfoHeader:(id)arg1;
- (void)ak_addProxiedDeviceUDIDHeader:(id)arg1;
- (void)ak_addShortLivedTokenHeaderWithIdentityToken:(id)arg1 forAltDSID:(id)arg2;
- (void)ak_addStingrayDisableEligibilityHeader:(BOOL)arg1;
- (void)ak_setBodyWithParameters:(id)arg1;
- (void)ak_setJSONBodyWithParameters:(id)arg1;

@end