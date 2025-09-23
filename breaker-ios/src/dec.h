#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSData* aesDecryptData(NSData *data, NSData *key);
FOUNDATION_EXPORT NSString* aesDecryptString(NSString *content, NSString *key);
FOUNDATION_EXPORT NSDictionary* aesDecryptDictionary(NSString *content, NSString *key);