//
//  PeerBuddy.m
//  SuperDialer
//
//  Created by zebra on 2021/8/4.
//

#import "NBPeerBuddy.h"

@implementation NBPeerBuddy

+ (NSString *)formatTarget:(NSString *)target {
    NSString *uri = nil;
    do {
        if ([target hasPrefix:@"tel:"] || [target hasPrefix:@"mailto:"]){
            uri = target;
            break;
        }
        if ([target containsString:@"@"]){
            uri = [NSString stringWithFormat:@"mailto:%@", [target lowercaseString]];
            break;
        }
        if ([target length] < 5){
            break;
        }
        if ([target hasPrefix:@"+"]){
            uri = [NSString stringWithFormat:@"tel:%@", target];
        }
        break;
    } while (1);
    return uri;
}

+ (NSString *)originTarget:(NSString *)target {
    NSString *uri = nil;
    do {
        if ([target containsString:@"tel:"]){
            uri = [target stringByReplacingOccurrencesOfString:@"tel:" withString:@""];
            break;
        }
        if ([target containsString:@"mailto:"]){
            uri = [target stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
            break;
        }
        uri = target;
        break;
    } while (1);
    return uri;
}

@end
