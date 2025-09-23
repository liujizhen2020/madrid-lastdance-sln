//
//  IMTextMessage.h
//  BrokenRock
//
//  Created by boss on 26/07/2019.
//  Copyright © 2019 Fenda Casarinwa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NBTextMessage : NSObject

@property (strong, nonatomic) NSString *tpID;
@property (strong, nonatomic) NSString *spID;

@property (strong, nonatomic) NSString *text;

- (NSData *)messageBody;

@end

