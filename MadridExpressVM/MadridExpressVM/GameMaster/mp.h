//
//  mp.h
//  AppleEmulator
//
//  Created by boss on 09/10/2019.
//  Copyright © 2019 FCHK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BinaryCert;

FOUNDATION_EXPORT NSData* _genNonce(BOOL s);
FOUNDATION_EXPORT NSData* _calcSig(SecKeyRef privKey, NSData *sha1);
FOUNDATION_EXPORT NSData* _calcSHA1(NSData *raw);

// enc
FOUNDATION_EXPORT NSData* _protectMessage(NSData *rawData, NSData *pubMPData, BinaryCert *bc);
