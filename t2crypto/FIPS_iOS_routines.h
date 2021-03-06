/*
 *
 * Copyright � 2009-2014 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright � 2009-2014 Contributors. All Rights Reserved.
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
 * Government Agency Original Software Designation: T2Crypto
 * Government Agency Original Software Title: T2Crypto
 * User Registration Requested. Please send email
 * with your contact information to: robert.a.kayl.civ@mail.mil
 * Government Agency Point of Contact for Original Software: robert.a.kayl.civ@mail.mil
 *
 */

#ifndef FIPS_iOS_routines_h
#define FIPS_iOS_routines_h

//
// FIPS_mode, FIPS_mode_set, ERR_get_error, etc
//#include <openssl/crypto.h>
#include <openssl/crypto.h>
#include <openssl/err.h>

// Random operations to test FIPS mode
#include <openssl/rand.h>
#include <openssl/aes.h>

// FIPS data

//
// Debug instrumentation
#include "fips_assert.h"

// Functions to test FIPS
BOOL FIPS_turnOn();
void FIPS_flip();

// SQL Databasekey
NSString *FIPS_SQLKey();

// PIN
NSString *FIPS_Pin();

// Plist Encryption/Decryption routines
// NSString Value
NSString * secureGetStringForKeyPlist(NSString *p, NSString *k, NSDictionary *d);
void secureSaveStringForKeyPlist(NSString *p, NSString *v, NSString *k, NSDictionary *d);


// NSNumber Value
NSNumber * secureGetNumberForKeyPlist(NSString *p, NSString *k, NSDictionary *d);
void secureSaveNumberForKeyPlist(NSString *p, NSNumber *v, NSString *k, NSDictionary *d);



#endif
