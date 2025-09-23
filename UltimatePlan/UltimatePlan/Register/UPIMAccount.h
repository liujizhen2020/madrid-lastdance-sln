//
//  MadridAccount.h
//  CrazyMadrid
//
//  Created by yt on 16/12/22.
//

#import <Foundation/Foundation.h>


@interface UPIMAccount : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *pwd;

@property (strong, nonatomic) NSString *PET;
@property (strong, nonatomic) NSString *DSID;
@property (strong, nonatomic) NSString *altDSID;
@property (strong, nonatomic) NSString *mmeAuthToken;

- (void)addAndRegister;

@end

