//
//  UPAccountManager.h
//  UltimatePlan
//
//  Created by yt on 28/08/23.
//

#import <Foundation/Foundation.h>


@interface UPAccountManager : NSObject

+ (instancetype)sharedManager;

- (NSString *)activeAccount;

@end

