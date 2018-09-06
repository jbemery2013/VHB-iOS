//
//  T2CryptoLib.h
//  T2CryptoLib
//
//  Created by Scott Coleman on 9/14/15.
//  Copyright (c) 2015 Scott Coleman. All rights reserved.
//
/*
 *
 * Copyright � 2009-2015 United States Government as represented by
 * the Chief Information Officer of the National Center for Telehealth
 * and Technology. All Rights Reserved.
 *
 * Copyright � 2009-2015 Contributors. All Rights Reserved.
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
#pragma once

#ifndef _T2CRYPTOLIB_H
#define _T2CRYPTOLIB_H

#import <Foundation/Foundation.h>

// ------------------------------------------
// Public Constants
// ------------------------------------------
enum T2Operation :NSInteger {
    T2E = 1,
    T2D = -1,
    T2NOOP = 0
};

enum T2Enums :NSInteger{
    T2Error = -1,
    T2Success = 0,
    T2True = 1,
    T2False = 0,
    T2FipsModeOn = 1,
    T2FipsModeOff = 0,
    OpenSSLError = 0,
    OpenSSLSuccess = 1
};


enum AesMode :NSInteger{
    AMCbc = 1,
    AMGcm = 2,
};

enum SaltMode :NSInteger{
    SMSecure = 1,
    SMUnsecure = 2,
};

extern NSString *const KCHECK;

extern NSString *const KEY_P; //KEY_PIN
extern NSString *const KEY_E_P; //KEY_EXISTING_PIN
extern NSString *const KEY_N_P; //KEY_NEW_PIN
extern NSString *const KEY_SQ_1; //KEY_SECURITY_QUESTION_1
extern NSString *const KEY_SQ_2; //KEY_SECURITY_QUESTION_2
extern NSString *const KEY_SQ_3; //KEY_SECURITY_QUESTION_3
extern NSString *const KEY_SA_1; //KEY_SECURITY_ANSWER_1
extern NSString *const KEY_SA_2; //KEY_SECURITY_ANSWER_2
extern NSString *const KEY_SA_3; //KEY_SECURITY_ANSWER_3

extern NSString *const KEY_TEST; //KEY_TEST_DATA
extern NSString *const KEY_LGD_IN; //KEY_LOGGED_IN
extern NSString *const KEY_INITD; //KEY_INITIALIZED
extern NSString *const KEY_M_K; //KEY_MASTER_KEY
extern NSString *const KEY_O_M_K; //KEY_OLD_MASTER_KEY
extern NSString *const KEY_B_K; //KEY_BACKUP_KEY
extern NSString *const KEY_D; //KEY_DATABASE
extern NSString *const KEY_D_P; // KEY_DATABASE_PIN Holds the password (encrypted)
extern NSString *const KEY_D_C; // KEY_DATABASE_CHECK Holds literally the word 'check' (encrypted),used to make sure keys are set up correctly for decruption
extern NSString *const KEY_S; // KEY_SALT Holds the currently used salt


@interface T2CryptoLib : NSObject
// -----------------------------------------------------------------------------
// Initialization routines
// -----------------------------------------------------------------------------

/*!
 * @brief Initializes T2Crypto for use - MUST be called before anythingn else
 */
void initT2Crypto();

/*!
 * setVerboseLogging
 * @brief Sets logging mode
 */
int setVL(int vl);

/*!
 * @brief Sets use of test vectors
 */
void prepareT2Crypto(Boolean t);

/*!
 * setAesMode
 * @brief Sets mode of AES
 * @param aesMode AesModeCbc, or AesModeGcm
 */
void setAM(int AM);

/*!
 * getAesMode
 * @brief Returns AES mode
 * @return aesMode AesModeCbc, or AesModeGcm
 */
int getAM();

/*!
 * setSaltMode
 * @brief Sets mode of Salt Generation
 * @param SM SaltModeSecure, or SaltModeUnsecure
 */
void setSM(int SM);

/*!
 * getSaltMode
 * @brief Returns Salt mode
 * @return aesMode SaltModeSecure, or SaltModeUnsecure
 */
int getSM();

/*!
 * @brief Returns the current t2Wrapper version
 * @return Version string
 */
NSString *t2FIPSVersion();


// -----------------------------------------------------------------------------
// Routines for lost password functionality
// -----------------------------------------------------------------------------

/*!
 * @brief Tests to see if the app has been initialized
 * @return YES if initialized
 */
Boolean isLoginInitialized();

/*!
 * @brief De-initializes Crypto
 * @discussion Clears all of the NVM storage thus
 *             removing all of the stored keys
 */
void deInitializeLogin();

/*!
 * @brief peforms initialization and login using pin and answers
 * @discussion This will set up the encrypted Master Key and Backup Key
 *             and save them  to NVM
 * @discussion JSON Keys:
 *               KEY_P
 *               KEY_SA_1
 *               KEY_SA_2
 *               KEY_SA_3
 * @param pin String containing pin
 * @param answers String containining concatenated answers
 * @result Master Key is saved to NVM
 * @result Backup Key is saved to NVM
 * @return T2Success if successful
 */
int initializeLogin( NSString *p, NSString *a);

/*!
 * checkPin
 * @brief Checks to see of the pin matches the pin used to login
 * @param pin String containing pin
 * @return T2Success if pin is correct
 */
int checkP(NSString * p);

/*!
 * checkAnswers
 * @brief Checks to see of the answers matches the answers used to login
 * @param answers String containing answers
 * @return T2Success if answers are correct
 */
int checkA(NSString *a);

/*!
 * changePinUsingPin
 * @brief Changes login pin using previous pin
 * @param oldPin String containing previously used pin in login
 * @param newPin String containing new pin
 * @return T2Success if pin changed
 */
int changePUsingP(NSString *oP, NSString *nP);

/*!
 * changePinUsingAnswers
 * @brief Changes login pin using answers
 * @param pin String containing previously used pin in login
 * @param answers String containing new pin
 * @return T2Success if pin changed
 */
int changePUsingA(NSString *p, NSString *a);

/*!
 * changeAnswersUsingPin
 * @brief Changes login answers using previous pin
 * @param pin String containing previously used pin in login
 * @param answers String new answers
 * @return T2Success if answers changed
 */
int changeAUsingP(NSString *p, NSString *a);

/*!
 * migratePinAndAnswers
 * @brief Migrates the pin and answers to be encrypted using the given new aes mode
 * @param pin String containing previously used pin in login
 * @param answers String new answers
 * @param oldAESMode The AES mode the pin and answers are currently encrypted through
 * @param newAESMode The AES mode the pin and answers are being migrated too
 * @return T2Success if pin and answers have been migrated
 */
int migratePAndA(NSString *p, NSString *a, int c, int n);

/*!
 * getDatabaseKeyUsingPin
 * @brief Returns a formatted string containing a database key (SqlChiper_
 * @param pin String containing pin
 * @return formatted Database key
 */
NSString *getDKUsingP(NSString *p);



// -----------------------------------------------------------------------------
// Standalone encryption/decryption
// -----------------------------------------------------------------------------

/*!
 * encryptStringRaw
 * encryptRaw
 * @brief Encrypts an NSString given a password
 * @discussion Uses FIPS encryption/deccryption
 * @param pin Pin to use to generate a key
 * @param plainText Text to encrypt
 * @return Encrypted string
 */
NSString *eStringRaw(NSString *p, NSString * t);
NSString *eRaw(NSString *p, NSString *t);

/*!
 * decryptStringRaw
 * decryptRaw
 * @brief Decrypts a NSString given a password
 * @discussion Uses FIPS encryption/deccryption
 * @param pin Pin to use to generate a key
 * @param cipherText Text to decrypt
 * @return Decrypted string
 */
NSString *dStringRaw(NSString *p, NSString *t);
NSString *dRaw(NSString *p, NSString *t);


/*!
 * encryptBytesRaw
 * @brief Encrypts NSData given a password
 * @discussion Uses FIPS encryption/deccryption
 *  Note that this routine is different than encryptRaw in that the former also encrypts the string
 *  zero terminator. This one does not!
 *
 * @param pin Pin to use to generate a key
 * @param inputData data to encrypt
 * @return Encrypted data
 */
NSData * eBytesRaw(NSString *p, NSData *b);

/*!
 * decryptBytesRaw
 * @brief Decrypts NSData given a password
 * @discussion Uses FIPS encryption/deccryption
 *  Note that this routine is different than decryptRaw in that the former also decrypts the string
 *  zero terminator. This one does not!
 *
 * @param pin Pin to use to generate a key
 * @param inputData data to decrypt
 * @return Decrypted data
 */
NSData * dBytesRaw(NSString *p, NSData *b);

/*!
 * encryptCharString
 * encryptCharString_calloc
 * @brief encrypts char * string (utf 8)  using a pin
 * @discussion ** Note that the plaintext input to this routine MUST be zero terminated
 * @param pPin Pin use in encrypt/decrypt functions
 * @param pPlainText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Encrypted text
 */
unsigned char * eCharString(unsigned char * p, unsigned char * t, int * l); // For Unity only
unsigned char * eCharString_calloc(unsigned char * p, unsigned char * t, int * l); // For Unity only

/*!
 * decryptCharString
 * decryptCharString_calloc
 * @brief decrypts char * string (utf 8)  using a pin
 * @discussion ** Note that the pEncryptedText input to this routine MUST be zero terminated
 * @param pPin Pin use in encrypt/decrypt functions
 * @param pEncryptedText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Decrypted text
 */
unsigned char * dCharString(unsigned char * p, unsigned char * t, int * l); // For Unity only
unsigned char * dCharString_calloc(unsigned char * p, unsigned char * t, int * l); // For Unity only

/*!
 * @brief Encrypts or Decrypts a binary file
 * @discussion Uses FIPS encryption/deccryption
 * @param inputFile File to read from
 * @param outputFile File to write processed file to
 * @param operation T2Encrypt, T2Decrypt, T2NOOP
 * @param password Text password to use
 * @return 0 for success
 */
int processBinaryFile( NSString* i, NSString* o, int op, NSString* p);

/*
 * Generate secure password to be used in the P-variant functions
 */
NSString * t2p();

/*!
 * encryptRawP
 * decryptRawP
 * @brief Standalone routines
 * @discussion Uses internally generated password
 * @return 0 for success
 */
NSString *eRawP(NSString *t);
NSString *dRawP(NSString *t);

/*!
 * encryptBytesRawP
 * decryptBytesRawP
 * encryptCharStringP
 * encryptCharString_callocP
 * decryptCharStringP
 * decryptCharString_callocP
 */
NSData * eBytesRawP(NSData *b);
NSData * dBytesRawP(NSData *b);
unsigned char * eCharStringP(unsigned char * t, int * l); // For Unity only
unsigned char * eCharString_callocP(unsigned char * t, int * l); // For Unity only
unsigned char * dCharStringP(unsigned char * t, int * l); // For Unity only
unsigned char * dCharString_callocP(unsigned char * t, int * l); // For Unity only
int processBinaryFileP( NSString* i, NSString* o, int op);



// -----------------------------------------------------------------------------
// Routines for emulating memory
// -----------------------------------------------------------------------------
/*!
 * encryptedSaveValueForKey
 * encryptedGetValueForKey
 */
void eSaveValueForKey(NSString *p, NSString *v, NSString *k);
NSString * eGetValueForKey(NSString *p, NSString *k);


@end

#endif
