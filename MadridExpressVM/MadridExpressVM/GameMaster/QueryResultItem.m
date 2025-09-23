//
//  QueryResultItem.m
//  AppleEmulator
//
//  Created by boss on 10/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import "QueryResultItem.h"

@implementation QueryResultItem

- (NSString *)description {
    return [NSString stringWithFormat:@"<QueryResultItem %@ >", self.target];
}

+ (instancetype)fromDictionary:(NSDictionary *)qDict {
    QueryResultItem *qret = [QueryResultItem new];
    qret.target = qDict[@"target"];
    qret.pushTokenData = qDict[@"push_token"];
    qret.sessionTokenData = qDict[@"session_token"];
    qret.publicMPData = qDict[@"public_mp"];
    
    if (qret.target == nil ||
        qret.pushTokenData == nil ||
        qret.sessionTokenData == nil ||
        qret.publicMPData == nil) {
        return nil;
    }
    return qret;
}

- (NSDictionary *)toDictionary {
    if (self.target == nil ||
        self.pushTokenData == nil ||
        self.sessionTokenData == nil ||
        self.publicMPData == nil) {
        return nil;
    }
    
    return @{
        @"target": self.target,
        @"push_token": self.pushTokenData,
        @"session_token": self.sessionTokenData,
        @"public_mp": self.publicMPData,
    };
}

@end
