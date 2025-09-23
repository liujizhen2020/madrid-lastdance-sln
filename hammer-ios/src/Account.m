#import "Account.h"

static NSString *kEmail    = @"kEmail";
static NSString *kPassword = @"kPassword";
static NSString *kSecType  = @"kSecType";
static NSString *kSecAPI   = @"kSecAPI";
static NSString *kSecCode  = @"kSecCode";

@implementation Account

- (NSString *)fmtSecType{
	if([SECTYPE_FIXCODE isEqualToString:self.secType]){
		return SECTYPE_FIXCODE;
	}
	if([SECTYPE_APICODE isEqualToString:self.secType]){
		return SECTYPE_APICODE;
	}
	if([SECTYPE_DIRECT isEqualToString:self.secType] || [self secEmpty]){
		return SECTYPE_DIRECT;
	}
	return SECTYPE_UNKNOW;
}

- (BOOL)secEmpty{
	if ((self.secType == nil || [self.secType length] == 0) && (self.secAPI == nil || [self.secAPI length] == 0) && (self.secCode == nil || [self.secCode length] == 0)){
		return YES;
	}
	return NO;
}

- (BOOL)checkValid {
    if (self.email == nil || [self.email length] == 0){
        return NO;
    }
    if (self.pwd == nil || [self.pwd length] == 0){
        return NO;
    }

    return YES;
}

- (BOOL)write:(NSString *)path{
	if (![self checkValid]){
		return NO;
	}
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{kEmail:self.email,kPassword:self.pwd}];
	if(self.secType){
		dict[kSecType] = self.secType;
	}
	if(self.secAPI){
		dict[kSecAPI] = self.secAPI;
	}
	if(self.secCode){
		dict[kSecCode] = self.secCode;
	}
	return [dict writeToFile:path atomically:NO];
}

- (BOOL)loadFromFile:(NSString *)path{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	self.email = dict[kEmail];
	self.pwd = dict[kPassword];
	if(dict[kSecType]){
		self.secType = dict[kSecType];
	}
	if(dict[kSecAPI]){
		self.secAPI = dict[kSecAPI];
	}
	if(dict[kSecCode]){
		self.secCode = dict[kSecCode];
	}
	return [self checkValid];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %@ %@ >", NSStringFromClass([self class]), self.email, ([self checkValid]?@"Good":@"NG")];
}


@end