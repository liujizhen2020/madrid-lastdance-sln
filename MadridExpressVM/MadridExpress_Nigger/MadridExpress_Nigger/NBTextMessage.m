//
//  IMTextMessage.m
//  BrokenRock
//
//  Created by boss on 26/07/2019.
//  Copyright © 2019 Fenda Casarinwa. All rights reserved.
//

#import "NBTextMessage.h"

@implementation NBTextMessage

- (NSData *)messageBody {
    if (self.tpID == nil || self.spID == nil){
        NSLog(@"msg: missing peer, s %@ t %@", self.spID, self.tpID);
        return nil;
    }
    if (self.text == nil){
        NSLog(@"msg: text msg! but text is missing! ");
        return nil;
    }
    NSMutableArray *participants = [NSMutableArray arrayWithCapacity:3];
    [participants addObject:self.spID];
    [participants addObject:self.tpID];
    NSString *r = [[NSUUID UUID] UUIDString];
    NSString *gid = [[NSUUID UUID] UUIDString];
    NSDictionary *dict = @{
                           @"pv": @(0),
                           @"p": participants,
                           @"t": self.text,
                           @"r": r,
                           @"gid": gid,
                           @"v": @"1",
                           @"gv": @"8",
                           };
    
    NSError *error;
    NSData *bodyData = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    return bodyData;
}

@end
