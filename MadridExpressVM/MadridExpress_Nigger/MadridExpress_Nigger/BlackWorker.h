//
//  BlackWorker.h
//  MadridExpress_Nigger
//
//  Created by yt on 18/07/22.
//

#import <Foundation/Foundation.h>
#import "../../Sources/BinaryCert.h"
#import "../../worker_defs.h"
#import "SpeedConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlackWorker : NSObject

@property (assign, nonatomic) int masterPort;

@property (strong, nonatomic) BinaryCert *cert;
@property (strong, nonatomic) NSMutableArray *qrets;
@property (strong, nonatomic) NSMutableArray *targets;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) SpeedConfig *spConfig;
@property (strong, nonatomic) NSString *emuID;

- (void)start;

@end

NS_ASSUME_NONNULL_END
