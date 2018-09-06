//
//  DefaultsWrapper.h
//  VirtualHopeBox
//
//  Created by Stephen ody on 7/27/15.
//  Copyright (c) 2015 The Geneva Foundation. All rights reserved.
//

#ifndef VirtualHopeBox_DefaultsWrapper_h
#define VirtualHopeBox_DefaultsWrapper_h


#endif

//
//  DefaultsWrapper.m
//  VirtualHopeBox
//
//  Created by Stephen ody on 7/27/15.
//

#import <Foundation/Foundation.h>
#import "T2CryptoLib.h"

bool decryptBoolForKey(NSString *key);
void encryptBoolForKey(NSString *key, bool value);
int decryptIntForKey(NSString *key);
void encryptIntForKey(NSString *key, int value);
float decryptFloatForKey(NSString *key);
void encryptFloatForKey(NSString *key, float value);
NSDate* decryptDateForKey(NSString *key);
void encryptDateForKey(NSString *key, NSDate *value);
NSString* decryptStringForKey(NSString *key);
void encryptStringForKey(NSString *key, NSString *value);
NSData * decryptNSDataForKey(NSString *key);
void encryptNSDataForKey(NSString *key, NSData *value);
NSDictionary * decryptDictionaryForKey(NSString *key);
void encryptDictionaryForKey(NSString *key, NSMutableDictionary *value);

