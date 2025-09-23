//
//  ServerAPI.m
//  CoreTrojan
//
//  Created by yt on 17/08/23.
//

#import "ServerAPI.h"

static NSString *kUserAgent = @"CoreTrojan";
static NSString *kVmcPortal = @"http://192.168.133.1:51888";

@implementation ServerAPI

+ (void)setVmcIP:(NSString *)vmc {
    kVmcPortal = [NSString stringWithFormat:@"http://%@:51888", vmc];
}

+ (MacCode *)sync_fetchMacCodeWithROM:(NSString *)rom {
    NSLog(@"sync_fetchMacCodeWithROM");
    __block MacCode *mc = nil;
    NSLog(@"use local portal: %@", kVmcPortal);
    NSString *url = [NSString stringWithFormat:@"%@/macCode/findByROM?rom=%@", kVmcPortal, rom];
    NSURL *fetchURL = [NSURL URLWithString:url];
    NSMutableURLRequest *fetchReq = [NSMutableURLRequest requestWithURL:fetchURL];
    [fetchReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    dispatch_semaphore_t csem = dispatch_semaphore_create(0);
    NSURLSessionDataTask *fetchTask = [[NSURLSession sharedSession] dataTaskWithRequest:fetchReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError *_Nullable error){
           if (error == nil){
               NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
               NSLog(@"sync_fetchMacCodeWithROM resp %@", resp);
               NSInteger code = [resp[@"RetCode"] integerValue];
               if (code == 1 ){
                   NSDictionary *codeDict = resp[@"Data"];
                   mc = [MacCode new];
                   mc.SN = codeDict[@"sn"];
                   mc.MLB = codeDict[@"mlb"];
                   mc.ROM = codeDict[@"rom"];
                   mc.BID = codeDict[@"board"];
                   mc.MODEL = codeDict[@"pt"];
                   mc.smUUID = [[NSUUID UUID] UUIDString];
                   mc.ip  = codeDict[@"Ip"];
                   mc.port  = [codeDict[@"Port"] integerValue];
               }
           }
        dispatch_semaphore_signal(csem);
    }];
    [fetchTask resume];
    dispatch_semaphore_wait(csem, DISPATCH_TIME_FOREVER);
    return mc;
}

+ (void)sync_markDeadVMWithROM:(NSString *)rom {
    NSLog(@"sync_markDeadVMWithROM");
    NSLog(@"use local portal: %@", kVmcPortal);
    NSString *query = [NSString stringWithFormat:@"rom=%@",rom];
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/macCode/macFatalByROM?", kVmcPortal]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [reportReq setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
    dispatch_semaphore_t csem = dispatch_semaphore_create(0);
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSLog(@"sync_markDeadVMWithROM: got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (error == nil){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"sync_markDeadVMWithROM: WARNING not good");
            }
        }
        dispatch_semaphore_signal(csem);
    }];
    [reportTask resume];
    dispatch_semaphore_wait(csem, DISPATCH_TIME_FOREVER);
}

+ (void)sync_markSuccVMWithROM:(NSString *)rom{
    NSLog(@"sync_markSuccVMWithROM");
    NSLog(@"use local portal: %@", kVmcPortal);
    NSString *query = [NSString stringWithFormat:@"rom=%@",rom];
    NSURL *reportURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/macCode/macSuccByROM?",kVmcPortal]];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    [reportReq setHTTPBody:[query dataUsingEncoding:NSUTF8StringEncoding]];
    dispatch_semaphore_t csem = dispatch_semaphore_create(0);
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSLog(@"sync_markSuccVMWithROM: got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (error == nil){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"sync_markDeadVMWithROM: WARNING not good");
            }
        }
        dispatch_semaphore_signal(csem);
    }];
    [reportTask resume];
    dispatch_semaphore_wait(csem, DISPATCH_TIME_FOREVER);
}

@end
