//
//  MadridAccount.m
//  CrazyMadrid
//
//  Created by yt on 16/12/22.
//

#import "UPIMAccount.h"
#import "x/IDSDaemonController.h"
#import "x/ACAccount.h"
#import "x/ACAccountType.h"
#import "x/ACAccountStore.h"
#import "x/ACAccountCredential.h"
#import "x/FTPasswordManager.h"
#import "x/IDSService.h"
#import "x/IDSAccount.h"

@implementation UPIMAccount

- (void)addAndRegister {
    NSLog(@"🚒 %@", NSStringFromSelector(_cmd));
    
    NSString *DSID = self.DSID;
    NSString *email = self.email;
    NSString *mmeAuthToken = self.mmeAuthToken;
    NSString *profileID = [NSString stringWithFormat:@"D:%@", DSID];
    NSString *selfHandle = [NSString stringWithFormat:@"urn:ds:%@",DSID];
    [[FTPasswordManager sharedInstance] setAuthTokenForProfileID:profileID username:email service:@"iMessage" authToken:mmeAuthToken selfHandle:selfHandle outRequestID:nil completionBlock:nil];
            
    
    ACAccountStore *accStore = [ACAccountStore new];
    ACAccountType *imAccType = [accStore accountTypeWithAccountTypeIdentifier:@"com.apple.account.IdentityServices"];
    NSLog(@"imAccType %@", imAccType);

    NSArray *imAccs = [accStore accountsWithAccountType:imAccType];
    NSLog(@"imAccs %@", imAccs);

    ACAccount *theAcc = nil;
    for (ACAccount *ac in imAccs){
        if ([email isEqualToString:ac.username]){
            theAcc = ac;
            break;
        }
    }
    NSLog(@"theAcc %@", theAcc);
    
    if (theAcc == nil){
        NSLog(@"FATAL... where is my added account?");
        return;
    }
    
    ACAccountCredential *cred = [accStore credentialForAccount:theAcc];
    NSLog(@"cred %@", cred);
    NSLog(@"cred token %@", cred.token);
    
    
    // add to ids
    NSString *idsEmail = self.email;
    NSString *idsDSID = self.DSID;
    NSString *idsUUID = theAcc.identifier;
    IDSDaemonController *daemon = [IDSDaemonController sharedInstance];
    
    NSString *loginID = [NSString stringWithFormat:@"E:%@", idsEmail];
    NSDictionary *userInfo = @{
        @"AccountPrefs": @{},
        @"AccountType": [NSNumber numberWithInt:1],
        @"AutoLogin": [NSNumber numberWithBool:YES],
        @"LoginAs": loginID,
        @"Profile": @{},
        @"ServiceName": @"com.apple.madrid"
    };
    [daemon addAccountWithLoginID:loginID serviceName:@"com.apple.madrid" uniqueID:idsUUID accountType:1 accountInfo:userInfo];
    
    // update
    [daemon updateAuthorizationCredentials:profileID token:mmeAuthToken forAccount:idsUUID];
    NSDictionary *updateInfo = @{
        @"AuthID": @"",
        @"AutoLogin": [NSNumber numberWithBool:YES],
        @"LoginAs": idsEmail
    };
    [daemon updateAccount:idsUUID withAccountInfo:updateInfo];
    updateInfo = @{
        @"AppleID": idsEmail,
        @"AuthID": [NSString stringWithFormat:@"D:%@", idsDSID],
        @"SelfHandle": [NSString stringWithFormat:@"urn:ds:%@", idsDSID],
        @"VettedAliases": @[ idsEmail ]
    };
    [daemon iCloudUpdateForUserName:idsEmail accountInfo:updateInfo];

    // enable
    [daemon enableAccount:idsUUID];

    // authenticate
    [daemon authenticateAccount:idsUUID];

    // add aliases
    [daemon addAliases:@[idsEmail, @"____--sentinel--alias--v0--____"] toAccount:idsUUID];

    // register
    [daemon registerAccount:idsUUID];
}


@end
