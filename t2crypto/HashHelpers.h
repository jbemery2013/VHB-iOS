//
//  HashHelpers.h
//  PECoach
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

#import <Foundation/Foundation.h>


#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import "T2CryptoLib.h"
#import "FIPS_iOS_routines.h"

#include <openssl/crypto.h>
#include <openssl/err.h>

// Random operations to test FIPS mode
#include <openssl/rand.h>
#include <openssl/aes.h>

#define SALT_HASH @"FvTivqTqZXsgLLx1v3P8TGRyVHaSOB1pvfm02wvGadj7RLHV8GrfxaZ84oGA8RsKdNRpxdAojXYg9iAj"

@interface HashHelpers : NSObject



// Generates an SHA256 (much more secure than MD5) hash.
+ (NSString *)securedSHA256DigestHashForPIN:(unsigned long)pinHash;
+ (NSString*)computeSHA256DigestForString:(NSString*)input;


@end
