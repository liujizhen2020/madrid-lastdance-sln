//
//  MacDumper.h
//  ThinAir
//
//  Created by yt on 30/08/22.
//

#import <Foundation/Foundation.h>
#import "BinaryCert.h"

extern const int kDumpOK;

FOUNDATION_EXPORT int mac_dump_cert(BinaryCert *bc);
