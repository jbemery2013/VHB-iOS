//
//  HashHelpers.m
//  PECoach
//
/*
 *
 * PECoach
 *
 * Copyright © 2009-2015 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright © 2009-2015 Contributors. All Rights Reserved.
 *
 * THIS OPEN SOURCE AGREEMENT ("AGREEMENT") DEFINES THE RIGHTS OF USE,
 * REPRODUCTION, DISTRIBUTION, MODIFICATION AND REDISTRIBUTION OF CERTAIN
 * COMPUTER SOFTWARE ORIGINALLY RELEASED BY THE UNITED STATES GOVERNMENT
 * AS REPRESENTED BY THE GOVERNMENT AGENCY LISTED BELOW ("GOVERNMENT AGENCY").
 * THE UNITED STATES GOVERNMENT, AS REPRESENTED BY GOVERNMENT AGENCY, IS AN
 * INTENDED THIRD-PARTY BENEFICIARY OF ALL SUBSEQUENT DISTRIBUTIONS OR
 * REDISTRIBUTIONS OF THE SUBJECT SOFTWARE. ANYONE WHO USES, REPRODUCES,
 * DISTRIBUTES, MODIFIES OR REDISTRIBUTES THE SUBJECT SOFTWARE, AS DEFINED
 * HEREIN, OR ANY PART THEREOF, IS, BY THAT ACTION, ACCEPTING IN FULL THE
 * RESPONSIBILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
 *
 * Government Agency: The National Center for Telehealth and Technology
 * Government Agency Original Software Designation: PECoach001
 * Government Agency Original Software Title: PECoach
 * User Registration Requested. Please send email
 * with your contact information to: robert.kayl2@us.army.mil
 * Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
 *
 */
#import "HashHelpers.h"

@implementation HashHelpers

/*
 // 06/23/15 BGD This is not needed now, but hold onto this code if we ever need to verify user entered PINs
+ (BOOL)compareKeychainValueForMatchingPIN:(NSUInteger)pinHash
{
    
    if ([[self keychainStringFromMatchingIdentifier:PIN_SAVED] isEqualToString:[self securedSHA256DigestHashForPIN:pinHash]]) {
        return YES;
    } else {
        return NO;
    }
}
 */

// Create a Hash to be used for a PIN, SQL Key, etc
//
// Input:
//      - Pass in a 'base value' that is unique to this device
//      - Merge this with a hardcoded string
//      - Mix in a lengthy SALT
//
//
// Mash the hardcoded string, the passed-in base value, and the 'SALT' to create one long, unique string.
// Then send that entire hash mashup into the SHA256 method below to create the base string
// Finally, use all, or portions, of this string as the key
+ (NSString *)securedSHA256DigestHashForPIN:(unsigned long)pinBase
{
    
    // Get a name, any name
    NSString *name = @"Brian";
    name = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // Mash these components together
    NSString *computedHashString = [NSString stringWithFormat:@"%@%lu%@", name, pinBase, SALT_HASH];
    
    // Harden the password some more
    NSString *finalHash = [self computeSHA256DigestForString:computedHashString];
    
    return finalHash;
}

// Encrypt the input string
+ (NSString*)computeSHA256DigestForString:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    // This is an iOS5-specific method.
    // It takes in the data, how much data, and then output format, which in this case is an int array.
    CC_SHA256(data.bytes, (int)data.length, digest);
    
    // Setup our Objective-C output.
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    // Parse through the CC_SHA256 results (stored inside of digest[]).
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",digest[i]];
    }
    
    return output;
}

@end
