//
//  MadridConfig.h
//  ThinAir
//
//  Created by yt on 07/09/22.
//

#import <Foundation/Foundation.h>


@interface MadridConfig : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *pwd;

@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *country;

// gsa -->
@property (strong, nonatomic) NSString *PET;
@property (strong, nonatomic) NSString *altDSID;
@property (strong, nonatomic) NSString *gsaAction;
@property (strong, nonatomic) NSString *idmsToken;

@property (strong, nonatomic) NSString *smsApi; // secAuth

// login delegate -->
@property (strong, nonatomic) NSString *DSID;
@property (strong, nonatomic) NSString *authToken;

@end

