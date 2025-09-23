//
//  main.m
//  MadridExpress_Nigger
//
//  Created by yt on 15/07/22.
//

#import <Foundation/Foundation.h>
#import "BlackWorker.h"
#import "NBPeerBuddy.h"
#import "QueryResultItem.h"
#import "util.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2){
            NSLog(@"FATAL: no job to do...");
            return -1;
        }
        
        NSString *jobPath = [[NSString alloc] initWithCString:argv[1] encoding:NSUTF8StringEncoding];
        NSLog(@"me_worker: job path %@", jobPath);
        NSDictionary *jobDict = [NSDictionary dictionaryWithContentsOfFile:jobPath];
        [[NSFileManager defaultManager] removeItemAtPath:jobPath error:nil];
        
        // port
        int port = [jobDict[MASTER_PORT_ARG_KEY] intValue];
        if (port == 0){
            NSLog(@"FATAL: unknown master port.");
            return 1;
        }
        
        NSData *cbData = jobDict[CERT_BOX_DATA_ARG_KEY];
        BinaryCert *bc = [BinaryCert parseFrom:cbData];
        if (bc == nil){
            NSLog(@"FATAL: cert box is nil ...");
            return 2;
        }
        
        NSMutableArray *mTargets = [NSMutableArray array];
        NSArray *targets = jobDict[TARGETS_ARG_KEY];
        if ([targets count] != 0){
            [mTargets addObjectsFromArray:targets];
        }
    
    
        NSArray *qrets = jobDict[QUERY_RESULTS_ARG_KEY];
        if (qrets == nil || [qrets count] == 0){
            NSLog(@"Fatal: query result is empty");
            return 3;
        }
        NSMutableArray *mQrets = [NSMutableArray array];
        for (NSDictionary *qDict in qrets){
            QueryResultItem *qr = [QueryResultItem fromDictionary:qDict];
            if (qr){
                [mQrets addObject:qr];
            }
        }
        if (mQrets == nil || [mQrets count] == 0){
            NSLog(@"Fatal: query result is invalid");
            return 31;
        }
        
        NSString *msg = jobDict[TEXT_MESSAGE_ARG_KEY];
        if (msg == nil || [msg length] == 0){
            NSLog(@"Fatal: text message is empty");
            return 4;
        }
        
        NSString *emuID = jobDict[EMU_ID_ARG_KEY];
        
        // speed control
        SpeedConfig *cfg = [SpeedConfig defaultConfig];
        int sendInterval = [jobDict[SEND_INTERVAL_ARG_KEY] intValue];
        if (sendInterval > 0){
            cfg.sendInterval = sendInterval;
        }
        int finishWait = [jobDict[FINISH_WAIT_ARG_KEY] intValue];
        if (finishWait > 0){
            cfg.finishWait =finishWait;
        }

        
        // work
        BlackWorker *wk = [BlackWorker new];
        wk.masterPort = port;
        wk.cert = bc;
        wk.qrets = mQrets;
        wk.targets = mTargets;
        wk.text = msg;
        wk.spConfig = cfg;
        wk.emuID = emuID;
        [wk start];
        
        loop_forever();
    }
    return 0;
}
