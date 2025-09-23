//
//  MacCode.m
//  HelloMac
//
//  Created by yt on 07/08/23.
//

#import "MacCode.h"

@implementation MacCode

- (NSString *)description {
    return [NSString stringWithFormat:@"<MacCode sn %@ bid %@ mlb %@ model %@ rom %@ ip %@ port %ld>", self.SN, self.BID, self.MLB, self.MODEL, self.ROM,self.ip,self.port];
}

@end
