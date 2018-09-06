//
//  DefaultsWrapper.m
//  VirtualHopeBox
//
//  Created by Stephen ody on 7/27/15.
//

#import <Foundation/Foundation.h>
#import "T2CryptoLib.h"
#import "VHBAppDelegate.h"
bool decryptBoolForKey(NSString *key)
{
    if ([eGetValueForKey(encodeKey, key) isEqualToString:@"true"]) {
        return true;
    }
    else
        return false;
}

void encryptBoolForKey(NSString *key, bool value)
{
    if (value) {
        eSaveValueForKey(encodeKey, @"true", key);
    }
    else
        eSaveValueForKey(encodeKey, @"false", key);
}

int decryptIntForKey(NSString *key)
{
    return [[NSString stringWithFormat:@"%@",eGetValueForKey(encodeKey, t2p())] intValue];
}

void encryptIntForKey(NSString *key, int value)
{
    NSString *iValue = [NSString stringWithFormat:@"%d", value];
    eSaveValueForKey(encodeKey, iValue, key);
}

float decryptFloatForKey(NSString *key)
{
    return [[NSString stringWithFormat:@"%@",eGetValueForKey(encodeKey, key)] floatValue];
}

void encryptFloatForKey(NSString *key, float value)
{
    NSString *iValue = [NSString stringWithFormat:@"%f", value];
    eSaveValueForKey(encodeKey, iValue, key);
}


NSDate* decryptDateForKey(NSString *key)
{
    NSString *sValue = eGetValueForKey(encodeKey, key);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    NSDate *dValue = [[NSDate alloc] init];
    dValue = [formatter dateFromString:sValue];
    
    return dValue;
}

void encryptDateForKey(NSString *key, NSDate *value)
{
    NSString *dateString = [NSDateFormatter localizedStringFromDate:value dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
    eSaveValueForKey(encodeKey, dateString, key);
}

NSString* decryptStringForKey(NSString *key)
{
    return eGetValueForKey(encodeKey, key);
}

void encryptStringForKey(NSString *key, NSString *value)
{
    eSaveValueForKey(encodeKey, value, key);
}

NSData * decryptNSDataForKey(NSString *key)
{
    NSString *vString = eGetValueForKey(encodeKey, key);
    
    NSData *data = (NSData *) vString;
    
    return data;
    
}

void encryptNSDataForKey(NSString *key, NSData *value)
{
    NSString *vString = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    eSaveValueForKey(encodeKey, vString, key);
    
}

NSDictionary * decryptDictionaryForKey(NSString *key)
{
    NSString *vString = eGetValueForKey(encodeKey, key);
    
    NSData *data = (NSData *) vString;
    NSDictionary *value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return value;
    
}

void encryptDictionaryForKey(NSString *key, NSMutableDictionary *value)
{
    NSData* vData = [NSKeyedArchiver archivedDataWithRootObject:value];
    NSString* vString = [[NSString alloc] initWithData:vData encoding:NSUTF8StringEncoding];
    eSaveValueForKey(encodeKey, vString, key);
    
}
