//
//  util.h
//  BlackTrain
//
//  Created by boss on 24/07/2019.
//  Copyright © 2019 Fenda Casarinwa. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT int load_binary_apsd(void);

FOUNDATION_EXPORT int load_binary_query(void);

FOUNDATION_EXPORT int load_binary_ids(void);

FOUNDATION_EXPORT void loop_forever(void);

// random
FOUNDATION_EXPORT NSData* uuid_data(NSUUID *srcUUID);
FOUNDATION_EXPORT long random_identifier(void);
