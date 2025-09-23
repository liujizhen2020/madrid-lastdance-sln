//
//  UPAccountManager.m
//  UltimatePlan
//
//  Created by yt on 28/08/23.
//

#import "UPAccountManager.h"
#import "x/IDSService.h"
#import "x/IDSAccount.h"

#define LAST_LOGINED_EMAIL_KEY      @"LAST_LOGINED_EMAIL"


@implementation UPAccountManager

+ (instancetype)sharedManager {
    static UPAccountManager *ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [UPAccountManager new];
    });
    return ins;
}

- (NSString *)activeAccount {
    IDSService *service = [[IDSService alloc] initWithService:@"com.apple.madrid"];
    NSSet *accounts = [service accounts];
    NSLog(@" 🍏 im accounts %@", accounts);
    if ([accounts count] == 0){
        NSLog(@" 🍎 NO ACCOUNT");;
        return nil;
    }
    
    NSString *activeAcc = nil;
    for (IDSAccount *acc in accounts){
        NSLog(@" 🎾 %@, active? %@", [acc loginID], [acc isActive]?@"Y":@"N" );
        if ([acc isActive]){
            activeAcc = [acc loginID];
        }
    }
    return activeAcc;
}


@end
