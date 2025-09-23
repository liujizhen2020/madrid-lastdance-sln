//
//  SpeedConfig.h
//  MadridExpress_Nigger
//
//  Created by yt on 18/07/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpeedConfig : NSObject

// 隔几秒发一条。。
@property (assign, nonatomic) int sendInterval;

// 发完等几秒
@property (assign, nonatomic) int finishWait;

// 单条消息等待几秒，适用于快速确认，部分不给力的提前完成
@property (assign, nonatomic) int singleWaitMax;


+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
