//
//  MessagesDumpHelper.m
//  MessagesDumpHelper
//
//  Created by yt on 04/09/23.
//

#import "MessagesDumpHelper.h"
#import "mac_dumper.h"
#import "util.h"

static __attribute__((constructor)) void InitMessagesDumpHelper()
{
    NSLog(@"<<<<<<<<<<<<<<<<<< InitMessagesDumpHelper <<<<<<<<<<<<<<<<<<");
    BinaryCert *bc = [BinaryCert IMCert];
    int ret = mac_dump_cert(bc);
    NSLog(@"mac_dump_cert, ret = %d", ret);
    NSLog(@"bc %@", bc);
    if (ret == 0){
        bc.SN = mac_copy_sn();
        NSData *data = [bc packedData];
        [data writeToFile:CERT_DUMP_PATH atomically:NO];
    }
}
