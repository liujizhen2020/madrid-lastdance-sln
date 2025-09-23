#import <Foundation/Foundation.h>
#import "BinaryCert.h"

extern const int kDumpOK;

FOUNDATION_EXPORT int dump_ids_registration(BinaryCert *box);
FOUNDATION_EXPORT int dump_message_protection_keys(BinaryCert *box);
FOUNDATION_EXPORT int dump_push_cert_and_key(BinaryCert *box);