//
//  QueryResultItem.h
//  AppleEmulator
//
//  Created by boss on 10/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryResultItem : NSObject

@property (strong, nonatomic) NSString *target;
@property (strong, nonatomic) NSData *pushTokenData;
@property (strong, nonatomic) NSData *sessionTokenData;
@property (strong, nonatomic) NSData *publicMPData;

+ (instancetype)fromDictionary:(NSDictionary *)qDict;

- (NSDictionary *)toDictionary;

@end

