//
//  ServerAPI.m
//  ThinAir
//
//  Created by yt on 06/09/22.
//

#import "ServerAPI.h"
#import "../../MessagesDumpHelper/BinaryCert.h"

@implementation ServerAPI

//获取账号
- (void)fetchAccount:(NSString *)sn withCallback:(ServerAPIResponseHandler)cb {
    NSString *api = [NSString stringWithFormat:@"http://103.86.46.189:8080/id/fetch?sn=%@",sn];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:api] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil){
            cb(nil, error);
            return;
        }
        if (data == nil){
            cb(nil, [NSError errorWithDomain:@"DATA NIL" code:-1 userInfo:nil]);
            return;
        }
        NSError *err = nil;
        NSDictionary *rspDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil){
            cb(nil, err);
            return;
        }
        int code = [rspDict[@"RetCode"] intValue];
        if (code != 1){
            cb(nil, [NSError errorWithDomain:@"SERVER CODE != 1" code:-1 userInfo:nil]);
            return;
        }
        if (rspDict[@"Data"] == nil){
            cb(nil, [NSError errorWithDomain:@"NO DATA DICT" code:-1 userInfo:nil]);
            return;
        }
        NSDictionary *dict = rspDict[@"Data"];
        Account *acc = [Account new];
        acc.email = dict[@"Email"];
        acc.pwd = dict[@"Password"];
        acc.smsURL = dict[@"PID"];
        cb(acc, nil);
    }];
    [task resume];
}

//激活失败
- (void)reportImRegFatal:(NSString *)sn withCalback:(ServerAPIResponseHandler)cb {
    NSLog(@"***** reportImRegFatal ***** sn %@", sn);
    NSString *api = @"http://103.86.46.189:8080/macCode/imRegFatal";
    NSString *body = [NSString stringWithFormat:@"sn=%@",sn];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
    [mReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    mReq.HTTPMethod = @"POST";
    mReq.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger sc = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"***** reportImRegFatal ***** sc %ld", (long)sc);
        NSLog(@"***** reportImRegFatal ***** text \n %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (sc == 200){
            cb(nil, nil);
        }else{
            cb(nil, [NSError errorWithDomain:@"NETWORK_ERR" code:-1 userInfo:nil]);
        }
        
    }];
    [task resume];
}

//激活成功
- (void)reportImRegSucc:(NSString *)sn cert:(BinaryCert *)bc withCalback:(ServerAPIResponseHandler)cb {
    NSLog(@"***** reportImRegSucc ***** sn %@", sn);
    NSString *api = @"http://103.86.46.189:8080/macCode/registerSuccess";
    NSData *bcData = [bc packedData];
    NSDictionary *bodyDict = @{ @"sn":sn,
                                @"acc":bc.email,
                                @"cert": [bcData base64EncodedStringWithOptions:0] };
    NSError *err;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&err];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
    [mReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    mReq.HTTPMethod = @"POST";
    mReq.HTTPBody = bodyData;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger sc = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"***** reportImRegSucc ***** sc %ld", (long)sc);
        NSLog(@"***** reportImRegSucc ***** text \n %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (sc == 200){
            cb(nil, nil);
        }else{
            cb(nil, [NSError errorWithDomain:@"NETWORK_ERR" code:-1 userInfo:nil]);
        }
    }];
    [task resume];
}


//获取任务
- (void)fetchIMTask:(NSString *)sn withCallback:(ServerAPIResponseHandler)cb;{
    NSURL *fetchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://103.86.46.189:8080//imessage/pullMultiTask?sn=%@",sn]];
    NSMutableURLRequest *fetchReq = [NSMutableURLRequest requestWithURL:fetchURL];
    [fetchReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    NSURLSessionDataTask *fetchTask = [[NSURLSession sharedSession] dataTaskWithRequest:fetchReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSMutableDictionary *imTask = nil;
        NSError *err = nil;
        if (error){
            err = [NSError errorWithDomain:@"ERR_NETWORK" code:-1 userInfo:nil];
        }else{
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            //NSLog(@"resp %@", resp);
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code == 1 ){
                //NSLog(@"retDict %@", retDict);
                imTask = resp[@"Data"];
            }else{
                if (resp[@"RetMsg"]){
                    NSString *msg = resp[@"RetMsg"];
                    err = [NSError errorWithDomain:msg code:-1 userInfo:nil];
                }else{
                    err = [NSError errorWithDomain:@"ERR_NETWORK" code:-1 userInfo:nil];
                }
            }
        }
        cb(imTask,err);
    }];
    [fetchTask resume];
}

//上报任务状态
- (void)reportIMTaskResult:(IMResult *)r withCallback:(ServerAPIResponseHandler)cb{
    NSDictionary *dict = @{@"Identifier":r.taskID,@"Serial":r.serialNumber,@"Email":r.email,@"Success":r.sentPhones};
    NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    if (body == nil){
        NSLog(@"body is nil");
        return;
    }
    NSLog(@"post body %@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    NSURL *reportURL = [NSURL URLWithString:@"http://103.86.46.189:8080/imessage/pushTaskStatus"];
    NSMutableURLRequest *reportReq = [NSMutableURLRequest requestWithURL:reportURL];
    [reportReq setHTTPMethod:@"POST"];
    [reportReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [reportReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    [reportReq setHTTPBody:body];
    NSURLSessionDataTask *reportTask = [[NSURLSession sharedSession] dataTaskWithRequest:reportReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
         NSLog(@"got err %@, resp %@", error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (!error){
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSInteger code = [resp[@"RetCode"] integerValue];
            if (code != 1 ){
                NSLog(@"WARNING...report im result NG");
            }
        }
    }];
    [reportTask resume];
}

//登陆过程中ID有问题,密码不正确,不在激活状态,锁定等
-(void)reportAccountFatal:(NSString *)email withCallback:(ServerAPIResponseHandler)cb{
    NSLog(@"***** reportAccountFatal ***** email %@", email);
    NSString *api = @"http://103.86.46.189:8080/id/disabledStatus";
    NSString *body = [NSString stringWithFormat:@"email=%@",email];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
    [mReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    mReq.HTTPMethod = @"POST";
    mReq.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger sc = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"***** reportImRegFatal ***** sc %ld", (long)sc);
        NSLog(@"***** reportImRegFatal ***** text \n %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    }];
    [task resume];
}


//IM已失效,被踢出等
- (void)reportIMFatal:(NSString *)sn withCallback:(ServerAPIResponseHandler)cb{
    NSLog(@"***** reportIMFatal ***** sn %@", sn);
    NSString *api = @"http://103.86.46.189:8080/macCode/imFatal";
    NSString *body = [NSString stringWithFormat:@"sn=%@",sn];
    NSMutableURLRequest *mReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:api]];
    [mReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mReq setValue:@"Mac.UltimatePlan" forHTTPHeaderField:@"User-Agent"];
    mReq.HTTPMethod = @"POST";
    mReq.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:mReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger sc = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"***** reportIMFatal ***** sc %ld", (long)sc);
        NSLog(@"***** reportIMFatal ***** text \n %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
    }];
    [task resume];
}

@end
