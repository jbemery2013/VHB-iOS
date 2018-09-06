//
//  T2CryptoLib.m
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
 * RESPONSI BILITIES AND OBLIGATIONS CONTAINED IN THIS AGREEMENT.
 *
 * Government Agency: The National Center for Telehealth and Technology
 * Government Agency Original Software Designation: T2Crypto
 * Government Agency Original Software Title: T2Crypto
 * User Registration Requested. Please send email
 * with your contact information to: robert.a.kayl.civ@mail.mil
 * Government Agency Point of Contact for Original Software: robert.a.kayl.civ@mail.mil
 *
 */

#import "T2CryptoLib.h"


#include "openssl/evp.h"
#include "openssl/crypto.h"      // FIPS_mode, FIPS_mode_set, ERR_get_error, etc
#include "openssl/err.h"
#include "openssl/rand.h"       // Random operations to test FIPS mode
#include "openssl/aes.h"

#include "openssl/sha.h"
#include <sys/sysctl.h>

@implementation T2CryptoLib

#define LOGE(...) \
NSLog(@__VA_ARGS__);


#define LOGI(...) \
do { \
if (vlOn) NSLog(@__VA_ARGS__);  \
} while (0);



enum T2Lengths :NSInteger {
    GENERIC_SIZE = 1024, //GENERIC_BUFFER_SIZE
    MAX_K_LENGTH = 32, //MAX_KEY_LENGTH
    S_LENGTH = 8, //SALT_LENGTH
    EVP_aes_256_cbc_Key_LENGTH = 32,
    EVP_aes_256_cbc_Iv_LENGTH = 16,
    EVP_aes_256_gcm_Key_LENGTH = 32,
    EVP_aes_256_gcm_Iv_LENGTH = 12
};



/*!
 * @typedef T2Key
 * @discussion Structure containing elements necessary for an encryption key
 *              "opaque" encryption, decryption ctx structures that libcrypto
 *              uses to record status of enc/dec operations
 */
typedef struct {
    EVP_CIPHER_CTX eContext; //encryptContext
    EVP_CIPHER_CTX dContext; //decryptContext
    int ivLength;
    int keyLength;
    unsigned char key[MAX_K_LENGTH], iv[MAX_K_LENGTH];
} T2Key;


int AM = AMGcm;  // AesMode Default to GSM mode

int SM = SMSecure; // SaltMode

bool vlOn = FALSE; //verboseLoggingOn
bool isInd = FALSE; //isInitialized

int EvpAesxxxKeyLength = EVP_aes_256_cbc_Key_LENGTH;
int EvpAesxxxIvLength = EVP_aes_256_cbc_Iv_LENGTH;

unsigned char * generic[GENERIC_SIZE]; //genericBuffer
unsigned char * genericE[GENERIC_SIZE]; //genericBufferEncrypt
unsigned char * genericD[GENERIC_SIZE]; //genericBufferDecrypt

NSString *const KCHECK = @"check";
NSString *const KEY_P = @"KEY_PIN";
NSString *const KEY_E_P = @"KEY_EXISTING_PIN";
NSString *const KEY_N_P = @"KEY_NEW_PIN";
NSString *const KEY_SQ_1 = @"KEY_SECURITY_QUESTION_1";
NSString *const KEY_SQ_2 = @"KEY_SECURITY_QUESTION_2";
NSString *const KEY_SQ_3 = @"KEY_SECURITY_QUESTION_3";
NSString *const KEY_SA_1 = @"KEY_SECURITY_ANSWER_1";
NSString *const KEY_SA_2 = @"KEY_SECURITY_ANSWER_2";
NSString *const KEY_SA_3 = @"KEY_SECURITY_ANSWER_3";


NSString *const KEY_TEST= @"TestData";
NSString *const KEY_LGD_IN = @"LoggedIn";
NSString *const KEY_INITD = @"Initialized";
NSString *const KEY_M_K = @"MasterKey";
NSString *const KEY_O_M_K = @"OldMasterKey";
NSString *const KEY_B_K = @"BackupKey";
NSString *const KEY_D = @"DatabaseKey";
NSString *const KEY_D_P = @"KEY_DATABASE_PIN";
NSString *const KEY_D_C = @"KEY_DATABASE_CHECK";
NSString *const KEY_S = @"KEY_SALT";


NSString *initP; //initializedPin

BOOL l() {
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    info.kp_proc.p_flag = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}


/*!
 * @brief salt - Salt used in ALL key calculations
 */
unsigned char *t2S; //t2Salt

int setVL(int vl) {
    vlOn = (vl == 1) ? TRUE : FALSE;
    return 0;
}

void setAM(int aAM) {
    LOGI("switching A mode to %d", aAM);
    AM = aAM;
}

int getAM() {
    return AM;
}

void setSM(int aSM) {
    LOGI("Switching S mode to %d", aSM);
    SM = aSM;

    if (t2S != NULL) {
        free(t2S);
        t2S = NULL;
    }
}

int getSM() {
    return SM;
}

NSString *t2FIPSVersion() {
    return @"2.1.0";
}

void initT2Crypto() {
    t2S = NULL;

    // Don't allow debugger to run!!!!
    // Do NOT manipulate the follow two lines
    /* If your app is crashing as a result of the follow two lines you are using release FCIDS assets and need to be using debug-  
    *  release FCIDS assets. No app should be published with debug-release FCIDS assets. Be sure to replace the debug-release
     * FCIDS assets with release FCIDS assets before publication
     */
//    BOOL debg =  l();
//    NSCAssert((debg == NO), @"Debugger attached - quit");

    initP = @"";

    switch (AM) {
        case AMGcm:
            EvpAesxxxKeyLength = EVP_aes_256_gcm_Key_LENGTH;
            EvpAesxxxIvLength = EVP_aes_256_gcm_Iv_LENGTH;
            NSLog(@" -------- Initializing T2Crypto ---------------- Using AES_GCM encryption mode");
            break;

        case AMCbc:
            EvpAesxxxKeyLength = EVP_aes_256_cbc_Key_LENGTH;
            EvpAesxxxIvLength = EVP_aes_256_cbc_Iv_LENGTH;
            NSLog(@" -------- Initializing T2Crypto ---------------- Using AES_CBC encryption mode");
            break;
    }

    int iFipsMode = FIPS_mode();
    if (iFipsMode == 0) {
       iFipsMode = FIPS_mode_set(1);
       if (iFipsMode == 1) {
            NSLog(@" -------- FIPS mode is set correctly -----------");
       }
        NSCAssert((iFipsMode == TRUE), @"ERROR: ***  T2Crypto can not enter FIPS mode");
    }

    isInd = TRUE;
}

void prepareT2Crypto(Boolean t)  {
    t2S = NULL;
}

Boolean isLoginInitialized() {
    // If it's initialized its master key will have been initialized
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *masterKey= [defaults objectForKey:KEY_M_K];
    if (masterKey == nil) {
        return NO;
    }
    else {
        return YES;
    }
}

void deInitializeLogin() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Clear everything!
    [defaults removeObjectForKey:KEY_P];
    [defaults removeObjectForKey:KEY_SQ_1];
    [defaults removeObjectForKey:KEY_SQ_2];
    [defaults removeObjectForKey:KEY_SQ_3];
    [defaults removeObjectForKey:KEY_SA_1];
    [defaults removeObjectForKey:KEY_SA_2];
    [defaults removeObjectForKey:KEY_SA_3];
    [defaults removeObjectForKey:KEY_TEST];
    [defaults removeObjectForKey:KEY_LGD_IN];
    [defaults removeObjectForKey:KEY_INITD];
    [defaults removeObjectForKey:KEY_M_K];
    [defaults removeObjectForKey:KEY_B_K];
    [defaults removeObjectForKey:KEY_D];
    [defaults removeObjectForKey:KEY_D_P];
    [defaults removeObjectForKey:KEY_D_C];
    [defaults synchronize];

    initP = @"";
}

int initializeLogin( NSString *p, NSString *a) {
    T2Key RIKey;
    T2Key LockingKey;
    T2Key SecondaryLockingKey;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    /**
     * @brief RIKeyBytes - Bytes used as input for RIKey calulation
     * This is the initial set of bytes (password) used to create the Random Initialization Key (RIKey)
     * which will be used as a basis for all of the encryption/decryption
     */

    LOGI("INFO: === initializeLogin ===\n");

    initP = p;

    char *RIKeyBytes;
    int RIKeyBytesLen;

    // Get random password for RiKey
    RIKeyBytes = (char*) calloc(MAX_K_LENGTH, sizeof(char));
    RIKeyBytesLen = MAX_K_LENGTH;
    NSCAssert((RIKeyBytes != NULL), @"ERROR: memory allocation");
    int result = RAND_bytes((unsigned char*)RIKeyBytes, RIKeyBytesLen);
    NSCAssert((result == OpenSSLSuccess), @"ERROR: - Can't calculate RIKeyBytes");

    logAsHexString((unsigned char*) RIKeyBytes, (unsigned int) RIKeyBytesLen, (char *) "xx     Password =  ");

    // Generate RIKey
    // RIKey is the main key used to encrypt and decrypt everyting. Note,it is never stored unencrypted.
    // Only the master key and backup key are stored, from which the RIKey can be derrived using
    // the pin and answers respectively.
    // -----------------
    LOGI("INFO: *** Generating RIKey ***\n");
    {
        /* gen key and iv. init the cipher ctx object */
        if (key_init((unsigned char*) RIKeyBytes, RIKeyBytesLen, (unsigned char *)t2s(), &RIKey)) {
            NSCAssert(FALSE, @"ERROR: initalizing key");
            if (RIKeyBytes != NULL)  free(RIKeyBytes);
            return T2Error;
        }
    }

    // Generate LockingKey = kdf(PIN)
    // ------------------------------
    LOGI("INFO: *** Generating LockingKey kdf(%s) ***\n", p.UTF8String);

    {
        unsigned char *key_data = (unsigned char *)p.UTF8String;
        int key_data_len = 0;
        for(int i = 0; p.UTF8String[i] != '\0'; i++) {
          key_data_len++;
        }

        /* gen key and iv. init the cipher ctx object */
        if (key_init(key_data, key_data_len, (unsigned char *)t2s(), &LockingKey)) {
            EVP_CIPHER_CTX_cleanup(&RIKey.eContext);
            EVP_CIPHER_CTX_cleanup(&RIKey.dContext);
            if (RIKeyBytes != NULL)  free(RIKeyBytes);
            NSCAssert(FALSE, @"ERROR: initalizing key");
        }
    }

    // Generate SecondaryLockingKey = kdf(Answers)
    // ------------------------------
    LOGI("INFO: *** Generating SecondaryLockingKey ***\n");

    {
        unsigned char *key_data = (unsigned char *)a.UTF8String;
        int key_data_len = 0;
        for(int i = 0; a.UTF8String[i] != '\0'; i++) {
          key_data_len++;
        }

        /* gen key and iv. init the cipher ctx object */
        if (key_init(key_data, key_data_len, (unsigned char *)t2s(), &SecondaryLockingKey)) {
            EVP_CIPHER_CTX_cleanup(&RIKey.eContext);
            EVP_CIPHER_CTX_cleanup(&RIKey.dContext);
            EVP_CIPHER_CTX_cleanup(&LockingKey.eContext);
            EVP_CIPHER_CTX_cleanup(&LockingKey.dContext);
            NSCAssert(FALSE, @"ERROR: initalizing key");
            if (RIKeyBytes != NULL)  free(RIKeyBytes);
            return T2Error;
        }
    }

    // Generate MasterKey = encrypt(RI Key, LockingKey)
    // ------------------------------
    LOGI("INFO: *** Generating and saving to NVM MasterKey ***\n");
    generateMasterOrRemoteKeyAndSave(&RIKey, &LockingKey, KEY_M_K);


    // Generate BackupKey = encrypt(RI Key, SecondaryLockingKey)
    // ------------------------------
    LOGI("INFO: *** Generating and saving to nvm BackupKey ***\n");
    generateMasterOrRemoteKeyAndSave(&RIKey, &SecondaryLockingKey, KEY_B_K);

    // Encrypt the PIN and save to NVM
    NSMutableData *encryptedPIN = eUsingKey(&RIKey, p);


    if (AM == AMGcm) {
        // Note, in GCM mode we must re-init RIKey because of counter
        if (key_init((unsigned char*) RIKeyBytes, RIKeyBytesLen, (unsigned char *)t2s(), &RIKey)) {
            if (RIKeyBytes != NULL)  free(RIKeyBytes);
            NSCAssert(FALSE, @"ERROR: initalizing key");
            return T2Error;
        }
    }


    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedPIN forKey:KEY_D_P];

    // Encrypt the 'check' (a constant string) and save to NVM
    // We use this as a test to see if the keys/password are/is correct
    // When we switch to a real database the password check is done automatically by the database open command
    NSMutableData *encryptedCheck= eUsingKey(&RIKey, KCHECK);
    [defaults setObject:encryptedCheck forKey:KEY_D_C];
    [defaults synchronize];

    EVP_CIPHER_CTX_cleanup(&RIKey.eContext);
    EVP_CIPHER_CTX_cleanup(&RIKey.dContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.dContext);
    EVP_CIPHER_CTX_cleanup(&SecondaryLockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&SecondaryLockingKey.dContext);

    return T2Success;
}

//<##>

int keyCredentialsFromBytes(unsigned char *key_data, int key_data_len, int iv_data_len, T2Key *aCredentials) {
    for (int i = 0; i < key_data_len; i++) {
        aCredentials->key[i] = key_data[i];
    }

    for (int i = 0; i < iv_data_len; i++) {
        aCredentials->iv[i] = key_data[i + key_data_len];
    }

    if (vlOn) {
        logAsHexString((unsigned char *)aCredentials->key, (unsigned int) key_data_len, "    key");
        logAsHexString((unsigned char *)aCredentials->iv, (unsigned int) iv_data_len, "   iv");
    }

    // Setup encryption context
    if (AM == AMGcm) {
        EVP_CIPHER_CTX_init(&aCredentials->eContext);                                     // Initialize ciipher context
        EVP_EncryptInit_ex(&aCredentials->eContext, EVP_aes_256_gcm(), NULL, aCredentials->key, aCredentials->iv);    // Set up context to use specific cyper type

        EVP_CIPHER_CTX_init(&aCredentials->dContext);                                     // Initialize ciipher context
        EVP_DecryptInit_ex(&aCredentials->dContext, EVP_aes_256_gcm(), NULL, aCredentials->key, aCredentials->iv);    // Set up context to use specific cyper type

        /* Initialise key and IV */
        int i = EVP_EncryptInit_ex(&aCredentials->eContext, NULL, NULL, aCredentials->key, aCredentials->iv);
        if (i != 1)
            return T2Error;

        i = EVP_EncryptInit_ex(&aCredentials->dContext, NULL, NULL, aCredentials->key, aCredentials->iv);
        if (i != 1)
            return T2Error;

    } else {
        EVP_CIPHER_CTX_init(&aCredentials->eContext);                                     // Initialize ciipher context
        EVP_EncryptInit_ex(&aCredentials->eContext, EVP_aes_256_cbc(), NULL, aCredentials->key, aCredentials->iv);    // Set up context to use specific cyper type

        EVP_CIPHER_CTX_init(&aCredentials->dContext);                                     // Initialize ciipher context
        EVP_DecryptInit_ex(&aCredentials->dContext, EVP_aes_256_cbc(), NULL, aCredentials->key, aCredentials->iv);    // Set up context to use specific cyper type
    }

    return T2Success;
}


/*!
 * @brief Utility to log a binary array as a string
 * @param binary array to log
 * @param binsz Length of input
 * @param message Message to prepend to log line
 */
void logAsHexString(unsigned char * bin, unsigned int binsz, char * message) {
    char *result;
    char          hex_str[]= "0123456789abcdef";
    unsigned int  i;

    result = (char *)calloc(binsz * 2 + 1, sizeof(char));
    if (result == NULL) {
        return;
    }
    (result)[binsz * 2] = 0;

    if (!binsz)
        return;

    for (i = 0; i < binsz; i++) {
        (result)[i * 2 + 0] = hex_str[bin[i] >> 4  ];
        (result)[i * 2 + 1] = hex_str[bin[i] & 0x0F];
    }

    LOGI("   %s = : %s \n", message, result);
    free(result);

}

/*!
 * @brief Utility to convert binary bytes to hex string
 * @param bin array to convert
 * @param binsz Length of input
 */
char * binAsHexString_calloc(unsigned char *bin, unsigned int binsz ) {
    char *result;
    char          hex_str[]= "0123456789abcdef";
    unsigned int  i;

    result = calloc(binsz * 2 + 1, sizeof(char));
    (result)[binsz * 2] = 0;

    if (!binsz)
        return NULL;

    for (i = 0; i < binsz; i++) {
        (result)[i * 2 + 0] = hex_str[bin[i] >> 4  ];
        (result)[i * 2 + 1] = hex_str[bin[i] & 0x0F];
    }

    return result;
}

/*!
 * @brief Utility to covet Hex string to binary
 * @param hex String to covert
 * @param stringLength Length of input (Also gets set to length of output)
 * @return  Binary representation of input string
 */
unsigned char * hexStringAsBin_calloc(unsigned char * hex, int *stringLength) {
    unsigned char *result;
    unsigned int  i;

    if (!stringLength) {
        LOGI("No string length!");
        return NULL;
    }

    unsigned long inStringLength = (unsigned long) *stringLength;

    *stringLength = *stringLength / 2;

    result = calloc((unsigned long) *stringLength, sizeof(unsigned char));
    if (result == NULL) {
        LOGE("xxFAILxx   Unable to allocate memory");
        return NULL;
    }

    int resultIndex = 0;
    unsigned char tmp = 0;;
    for (i = 0; i < inStringLength; i++) {
        unsigned char digit = hex[i];
        //LOGI("digit = %x", digit);
        if (digit >= 0x30 && digit <= 0x39) {
            tmp = digit - 0x30;
        } else if (digit >= 0x61 && digit <= 0x66) {
            tmp = digit - 0x61 + 10;
        }

        if ((i & 1) == 0) {
            result[resultIndex] = (unsigned char) (tmp << 4);
        } else {
            result[resultIndex] |= tmp;
            resultIndex++;
        }
    }
    return result;
}


/*!
 * @brief encrypts plain text
 * @param encryptContext Encryption context
 * @param plaintext bytes to encrypt
 * @param len Length of input (also gets set as length of output)
 * @return  encrypted bytes
 */
unsigned char * aes_e_calloc(EVP_CIPHER_CTX * c , unsigned char * t, int * l) {
    /* max ciphertext len for a n bytes of plaintext is n + AES_BLOCK_SIZE -1 bytes */
    int c_len = *l + AES_BLOCK_SIZE;
    int f_len = 0;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    unsigned char *pCiphertext = calloc((unsigned long) c_len, sizeof(unsigned char));
    if (pCiphertext == NULL) {
        LOGE("xxFailxx Memory allocation error");
        return NULL;
    }

    if (AM == AMGcm) {
        EVP_EncryptUpdate(c, pCiphertext, &c_len, t, *l);
        EVP_EncryptFinal_ex(c, pCiphertext+c_len, &f_len);
    } else if (AM == AMCbc) {
        /* allows reusing of 'encryptContext' for multiple encryption cycles */
        EVP_EncryptInit_ex(c, NULL, NULL, NULL, NULL); //

        /* update ciphertext, c_len is filled with the length of ciphertext generated,
         *len is the size of plaintext in bytes */
        EVP_EncryptUpdate(c, pCiphertext, &c_len, t, *l);

        /* update ciphertext with the final remaining bytes */
        EVP_EncryptFinal_ex(c, pCiphertext+c_len, &f_len);

    }
    *l = c_len + f_len;
    return pCiphertext;
}

/*!
 * @brief Decrypts encrypted text
 * @discussion
 * @param decryptContext Decryption context
 * @param ciphertext bytes to decrypt
 * @param len Length of input (also gets set as length of output)
 * @return  Decrypted bytes
 */
unsigned char * aes_d_calloc(EVP_CIPHER_CTX * c, unsigned char * t, int *l) {
    /* plaintext will always be equal to or lesser than length of ciphertext*/
    int p_len = *l, f_len = 0;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    unsigned char *plaintext = calloc((unsigned long) p_len, sizeof(unsigned char));
    if (plaintext == NULL) {
        LOGE("xxFailxx Memory allocation error");
        return NULL;
    }

    if (AM == AMGcm) {
        EVP_DecryptUpdate(c, plaintext, &p_len, t, *l);
        EVP_DecryptFinal_ex(c, plaintext+p_len, &f_len);
    } else if (AM == AMCbc) {
        EVP_DecryptInit_ex(c, NULL, NULL, NULL, NULL);
        EVP_DecryptUpdate(c, plaintext, &p_len, t, *l);
        EVP_DecryptFinal_ex(c, plaintext+p_len, &f_len);
    }
    *l = p_len + f_len;

    return plaintext;
}

/*!
 * @brief Initializes a T2Key based on a password
 * @discussion Performs KDF function on a password and salt to initialize a T2Key.
 * This is used to generate a T2Key from a password (or pin)
 * @param key_data Password to use in KDF function
 * @param key_data_len Length of password
 * @param salt Salt to use in KDF function
 * @param aCredentials T2Key to initialize
 * @return  T2Success2 or T2Error2
 */
int key_init(unsigned char * key_data, int key_data_len, unsigned char * s, T2Key * aCredentials) {
    int i, nrounds = 5;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    if (AM == AMGcm) {
        /*
         * Gen key & IV for AES 256 GCM mode. A SHA1 digest is used to hash the supplied key material.
         * rounds is the number of times the we hash the material. More rounds are more secure but
         * slower.
         * This uses the KDF algorithm to derive key from password phrase
         */
        i = EVP_BytesToKey(EVP_aes_256_gcm(), EVP_sha1(), s, key_data, key_data_len, nrounds, aCredentials->key, aCredentials->iv);
        if (i != EVP_aes_256_gcm_Key_LENGTH) {
            LOGI("ERROR: Key size is %d bits - should be %d bits\n", i, EvpAesxxxKeyLength * 8);
            return T2Error;
        }

        // For EVP_aes_256_cbc, key length = 32 bytes, iv length = 12 bytes
        aCredentials->keyLength = EVP_aes_256_gcm_Key_LENGTH;
        aCredentials->ivLength = EVP_aes_256_gcm_Iv_LENGTH;

        if (vlOn) {
            logAsHexString(( unsigned char *)aCredentials->key, (unsigned int) aCredentials->keyLength, "    key");
            logAsHexString((unsigned char *)aCredentials->iv, (unsigned int) aCredentials->ivLength, "     iv");
        }

        //<##>
        // Setup encryption context
        EVP_CIPHER_CTX_init(&aCredentials->eContext);
        i = EVP_EncryptInit_ex(&aCredentials->eContext, EVP_aes_256_gcm(), NULL, NULL, NULL);    // Set up context to use specific cyper type
        if (i != 1) return T2Error;

        EVP_CIPHER_CTX_init(&aCredentials->dContext);
        i = EVP_DecryptInit_ex(&aCredentials->dContext, EVP_aes_256_gcm(), NULL, NULL, NULL);    // Set up context to use specific cyper type
        if (i != 1) return T2Error;


        /* Initialise key and IV */
        i = EVP_EncryptInit_ex(&aCredentials->eContext, NULL, NULL, aCredentials->key, aCredentials->iv);
        if (i != 1) return T2Error;

        i = EVP_EncryptInit_ex(&aCredentials->dContext, NULL, NULL, aCredentials->key, aCredentials->iv);
        if (i != 1) return T2Error;


    } else if ( AM == AMCbc) {
        /*
         * Gen key & IV for AES 256 CBC mode. A SHA1 digest is used to hash the supplied key material.
         * rounds is the number of times the we hash the material. More rounds are more secure but
         * slower.
         * This uses the KDF algorithm to derive key from password phrase
         */
        i = EVP_BytesToKey(EVP_aes_256_cbc(), EVP_sha1(), s, key_data, key_data_len, nrounds, aCredentials->key, aCredentials->iv);
        if (i != EvpAesxxxKeyLength) {
            LOGI("ERROR: Key size is %d bits - should be %d bits\n", i, EvpAesxxxKeyLength * 8);
            return T2Error;
        }

        // For EVP_aes_256_cbc, key length = 32 bytes, iv length = 16 bytes
        aCredentials->keyLength = EvpAesxxxKeyLength;
        aCredentials->ivLength = EvpAesxxxIvLength;

        if (vlOn) {
            logAsHexString(( unsigned char *)aCredentials->key, (unsigned int) aCredentials->keyLength, "    key");
            logAsHexString((unsigned char *)aCredentials->iv, (unsigned int) aCredentials->ivLength, "     iv");
        }
        // Setup encryption context
        EVP_CIPHER_CTX_init(&aCredentials->eContext);                                     // Initialize ciipher context
        i = EVP_EncryptInit_ex(&aCredentials->eContext, EVP_aes_256_cbc(), NULL, aCredentials->key, aCredentials->iv);    // Set up context to use specific cyper type
        if (i != 1) return T2Error;

        EVP_CIPHER_CTX_init(&aCredentials->dContext);                                     // Initialize ciipher context
        i = EVP_DecryptInit_ex(&aCredentials->dContext, EVP_aes_256_cbc(), NULL, aCredentials->key, aCredentials->iv);    // Set up context to use specific cyper type
        if (i != 1) return T2Error;
    }

    return T2Success;
}

/*!
 * @brief encrypts string using a T2Key
 * @discussion ** Note that the plaintext input to this routine MUST be zero terminated
 * @param credentials T2Key credentials to use in encrypt/decrypt functions
 * @param pUencryptedText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Encrypted text
 */
unsigned char * eStringUsingKey_calloc(T2Key * c, unsigned char * t, int * l) {
    int key_data_len = 0;
    for(int i = 0; t[i] != '\0'; i++) {
      key_data_len++;
    }
    int len1 = key_data_len + (int) 1; // Make sure we encrypt the terminating 0 also!
    unsigned char* szEncryptedText =  aes_e_calloc(&c->eContext, t, &len1);
    *l = len1;
    return szEncryptedText;
}

/*!
 * @brief Decrypts binary array using a T2Key
 * @discussion
 * @param credentials T2Key credentials to use in encrypt/decrypt functions
 * @param encryptedText Bytes to decrypt
 * @param inLength length if input (Also gets set to length of output)
 * @return  Decrypted binary
 */
unsigned char * dUsingKey_calloc1(T2Key * c, unsigned char * t, int * l) {
    unsigned char* decryptedText =  aes_d_calloc(&c->dContext, t, l);
    return decryptedText;
}

/*!
 * @brief encrypts char * string (utf 8)  using a pin
 * @discussion ** Note that the plaintext input to this routine MUST be zero terminated // For Unity only
 * @param pPin Pin use in encrypt/decrypt functions
 * @param pPlainText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Encrypted text
 */
unsigned char * eCharString_calloc(unsigned char * p, unsigned char * t, int * l) {
    T2Key RawKey;
    char * retPtr = NULL;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    if (p == NULL || t == NULL || l == NULL) {
        LOGE("Error Null Pointers on input");
        return (unsigned char *) retPtr;
    }

    int pinLen = 0;
    for(int i = 0; p[i] != '\0'; i++) {
      pinLen++;
    }

    if (key_init(p, pinLen, t2s(), &RawKey)) {
        LOGE("Error Initializing Key");
        return (unsigned char *) retPtr;

    } else {
        unsigned char *encryptedText= eStringUsingKey_calloc(&RawKey, t, l);
        NSCAssert((encryptedText != NULL), @"Memory allocation error");

        // Note: we can't return the encrhypted string directoy because JAVA will try to
        // interpret it as a string and fail UTF-8 conversion if any of the encrypted characters
        // have the high bit set. Therefore we must return a hex string equivalent of the binary
        retPtr = binAsHexString_calloc(encryptedText, (unsigned int) *l);
        free(encryptedText);

        if (retPtr == NULL) {
            LOGE("Memory allocation error");
        }
    }

    return (unsigned char *) retPtr;
}

/*!
 * @brief ederypts char * string (utf 8)  using a pin
 * @discussion ** Note that the pEncryptedText input to this routine MUST be zero terminated // For Unity only
 * @param pPin Pin use in encrypt/decrypt functions
 * @param pEncryptedText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Decrypted text - or NULL on error
 */
unsigned char * dCharString_calloc(unsigned char * p, unsigned char * t, int * l) {
    T2Key RawKey;
    char * retPtr = NULL;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    if (p == NULL || t == NULL || l == NULL) {
        LOGE("Error Null Pointers on input");
        return (unsigned char *) retPtr;
    }

    int pinLen = 0;
    for(int i = 0; p[i] != '\0'; i++) {
      pinLen++;
    }

    if (key_init(p, pinLen, t2s(), &RawKey)) {
        LOGE("Error Initializing Key");
        return (unsigned char *) retPtr;
    } else {
        int length = 0;
        for(int i = 0; ((const char *)t)[i] != '\0'; i++) {
          length++;
        }
        *l = length;

        unsigned char *resultBinary = hexStringAsBin_calloc(t, l);
        NSCAssert((resultBinary != NULL), @"Memory allocation error");

        retPtr = (char *) dUsingKey_calloc1(&RawKey, resultBinary, l);
        NSCAssert((retPtr != NULL), @"Memory allocation error");

        free(resultBinary);
    }

    return (unsigned char *) retPtr;
}

/*!
 * @brief encrypts char * string (utf 8)  using a pin
 * @discussion ** Note that the plaintext input to this routine MUST be zero terminated // For Unity only
 * @param pPin Pin use in encrypt/decrypt functions
 * @param pPlainText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Encrypted text
 */
unsigned char * eCharString(unsigned char * p, unsigned char * t, int * l) {
    T2Key RawKey;
    genericE[0] = 0;   // Clear out generic buffer in case we fail

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    if (p ==NULL || t == NULL || l == NULL) {
        LOGE("Error Null Pointers on input");
        return (unsigned char *) genericE;
    }

    int pinLen = 0;
    for(int i = 0; p[i] != '\0'; i++) {
      pinLen++;
    }

    if (key_init(p, pinLen, t2s(), &RawKey)) {
        LOGE("Error Initializing Key");
        return t;
    } else {
        unsigned char *encryptedString = eStringUsingKey_calloc(&RawKey, t, l);
        NSCAssert((encryptedString != NULL), @"Memory allocation error");

        // Note: we can't return the encrhypted string directoy because JAVA will try to
        // interpret it as a string and fail UTF-8 conversion if any of the encrypted characters
        // have the high bit set. Therefore we must return a hex string equivalent of the binary
        char *tmp = binAsHexString_calloc(encryptedString, (unsigned int) *l);
        NSCAssert((tmp != NULL), @"Memory allocation error");

        unsigned long size = 0;
        for(int i = 0; tmp[i] != '\0'; i++) {
          size++;
        }
        char* buffer[size * sizeof(char)];

        snprintf((char*) buffer, size + 1, "%s", tmp);
        free(tmp);

        NSString* message = [NSString stringWithFormat:@"%s", (char *) buffer];
        return (unsigned char*) message.UTF8String;
    }
}

/*!
 * @brief decrypts char * string (utf 8)  using a pin
 * @discussion ** Note that the pEncryptedText input to this routine MUST be zero terminated // For Unity only
 * @param pPin Pin use in encrypt/decrypt functions
 * @param pEncryptedText Zero terminated input string
 * @param outlength Gets set to length of output
 * @return  Decrypted text
 */
unsigned char * dCharString(unsigned char * p, unsigned char * t, int * l) {
    T2Key RawKey;
    genericD[0] = 0;   // Clear out generic buffer in case we fail

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    int pinLen = 0;
    for(int i = 0; p[i] != '\0'; i++) {
      pinLen++;
    }
    int resultLength = 0;
    if (t != nil) {
        for(int i = 0; t[i] != '\0'; i++) {
          resultLength++;
        }
    } else {
        return nil;
    }
    char* buffer[resultLength * sizeof(char)];

    if (key_init(p, pinLen, t2s(), &RawKey)) {
        LOGE("Error Initializing Key");
        NSString* message = [NSString stringWithFormat:@"%s", (char *) buffer];
        return (unsigned char*) message.UTF8String;
    } else {
        unsigned char *resultBinary = hexStringAsBin_calloc(t, &resultLength);
        if (resultBinary != NULL) {
            unsigned char *decrypted = dUsingKey_calloc1(&RawKey, ( unsigned char*)resultBinary, &resultLength);

            NSCAssert((decrypted != NULL), @"Memory allocation error");

            memmove(buffer, decrypted, resultLength);
            free(resultBinary);
        }
    }

    NSString* message = [NSString stringWithFormat:@"%s", (char *) buffer];
    return (unsigned char*) message.UTF8String;
}

int processBinaryFile( NSString* i, NSString* o, int op, NSString* p) {
    int retVal = 0;
    NSData* originalContents = nil;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    // Open the input file, error out if issue
    NSFileHandle* inputHandle = [NSFileHandle fileHandleForReadingAtPath:i ];
    if (inputHandle == nil) {
        return -1;
    }

    // Delete the output file so we know we're starting fresh
    NSError* anError;
    if ([[NSFileManager defaultManager]  fileExistsAtPath:o] == YES) {
        [[NSFileManager defaultManager]  removeItemAtPath:o error:&anError];
    }

    // Open the output file, error out if issue
    NSFileHandle* outFileHandle = [NSFileHandle fileHandleForWritingAtPath:o];
    if (outFileHandle == nil) {

        // File doesn't exist, must create it first
        NSLog(@"*** creating file!");
        [[NSFileManager defaultManager] createFileAtPath:o contents:nil attributes:nil];
        outFileHandle = [NSFileHandle fileHandleForWritingAtPath:o];

        if (outFileHandle) {
        }
        else {
            return -1;
        }
    }

     // Both file handles have been created successfully
    // Walk through the file and encrypt/decrypt it
    while(true) {
        unsigned long  blocklength;
        if (op == T2E) {
            blocklength = 1024; // Arbitarry chunk of bytes to process
        }
        else {
            // since we know the plaitext block is 1024, doe to the encryption we're using the encrypted block is 1040
            if (AM == AMGcm) {
                // Note, in gcm mode cyphertext is same size as plaintext
                blocklength = 1024;
            } else {
                blocklength = 1040; // since we know the plaitext block is 1024, doe to the encryption we're using the encrypted block is 1040
            }
        }

        originalContents = [inputHandle readDataOfLength:blocklength];
        if (originalContents.length == 0) {
            break;
        }

        if (op == T2E) {
            NSData *encryptedData = eBytesRaw(p, originalContents);

            [outFileHandle writeData:encryptedData];
        }

        if (op == T2D) {
            NSData *decryptedData = dBytesRaw(p, originalContents);

            [outFileHandle writeData:decryptedData];
        }

        // Just pass the data stright through (copyFile)
        if (op == T2NOOP) {
            [outFileHandle writeData:originalContents];
        }
    }

    return retVal;
}


NSData * dBytesRaw(NSString *p, NSData *b) {
    T2Key RawKey;
    int length;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    unsigned char *bytes = (unsigned char *)[b bytes];


    unsigned char *key_data;
    int key_data_len = 0;
    key_data = (unsigned char *)p.UTF8String;
    for(int i = 0; p.UTF8String[i] != '\0'; i++) {
      key_data_len++;
    }

    // Generate RawKey = kdf(PIN)
    // ------------------------------
    /* gen key and iv. init the cipher ctx object */

    if (key_init(key_data, key_data_len, t2s(), &RawKey)) {
        NSCAssert(FALSE, @"ERROR: initializing key");
        return NULL;
    } else {

        length = (int) b.length;
        unsigned char* szDecryptedBytes =  aes_d_calloc(&RawKey.dContext, bytes, &length);
        if (szDecryptedBytes == NULL) {
            return nil;
        }
        else {
            NSData *outputData;
            outputData = [NSData dataWithBytes:szDecryptedBytes length: (unsigned long) length];
            free (szDecryptedBytes);
            return outputData;
        }
    }

}

NSData * eBytesRaw(NSString *p, NSData *b) {
    T2Key RawKey;
    int length;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    unsigned char *bytes = (unsigned char *)[b bytes];

    unsigned char *key_data;
    int key_data_len = 0;
    key_data = (unsigned char *)p.UTF8String;
    for(int i = 0; p.UTF8String[i] != '\0'; i++) {
      key_data_len++;
    }

    // Generate RawKey = kdf(PIN)
    // ------------------------------
    /* gen key and iv. init the cipher ctx object */

    if (key_init(key_data, key_data_len, t2s(), &RawKey)) {
        NSCAssert(FALSE, @"ERROR: initializing key");
        return NULL;
    } else {
        length = (int) b.length;
        unsigned char* szEncryptedBytes =  aes_e_calloc(&RawKey.eContext, bytes, &length);
        if (szEncryptedBytes == NULL) {
            return nil;
        }
        else {
            NSData *outputData;
            outputData = [NSData dataWithBytes:szEncryptedBytes length: (unsigned long) length];
            free (szEncryptedBytes);
            return outputData;
        }
    }
}

/*!
 * @brief Encrypts a key/value pair and saves them to user defaults
 * @discussion Uses FIPS encryption/deccryption
 * @param pin Pin to use to generate a key
 * @param value Value to save to user defaults
 * @param key Key to use
 */
void eSaveValueForKey( NSString *p, NSString *v, NSString *k) {
    NSString *encryptedKey = eRaw(p, k);
    NSString *encryptedValue = eRaw(p, v);

    LOGE("eSaveValueForKey -  pin: %@, key: %@, value: %@, encrypted key: %@, encrypted value: %@", p, k, v, encryptedKey, encryptedValue);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedValue forKey:encryptedKey];
    [defaults synchronize];
}

/*!
 * @brief Decrypts a key/value pair and recalls from user defaults
 * @discussion Uses FIPS encryption/deccryption
 * @param pin Pin to use to generate a key
 * @param key Key to use
 * @return returned value
 */
NSString * eGetValueForKey(NSString *p, NSString *k) {

    NSString *encryptedKey = eRaw(p, k);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *encryptedValue = [defaults objectForKey:encryptedKey];

    NSString *decryptedValue = dRaw(p, encryptedValue);
    LOGE("eGetValueForKey -  pin: %@, key: %@, encryptedKey: %@, encryptedValue: %@, decryptedValue: %@ ", p, k, encryptedKey, encryptedValue, decryptedValue);
    return decryptedValue;
}

NSString * complexShift() {
    NSMutableString *s = [NSMutableString stringWithCapacity:20];

    for (int j = 0; j < 4; j++) {
        int k = j ^ (int) sizeof(int);
        [s appendFormat:@"%d", k];
        for (int i = 0; i < (int) sizeof(float); i++ ) {
            char c = (char) (arc4random_uniform(94) + ' ');
            [s appendFormat:@"%c", c];
        }
    }

    return s;
}

/*!
* @brief Returns an appropriate salt
* @discussion Calculates sale if not previously calculated
* @return calculated salt
*/
unsigned char *t2s() {
    if(SM == SMSecure) {
        if (t2S == NULL) {
            unsigned char cannedSaltRaw[S_LENGTH] = { 0x93, 0x0e, 0x4b, 0x4f, 0x72, 0x62, 0xaf, 0x75};
            t2S = calloc(S_LENGTH, sizeof(unsigned char));
            NSCAssert((t2S != NULL), @"Memory allocation error for _salt!");

            int r = 1;
            NSString *t =  NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"];
            const char *tc = [t UTF8String];
            unsigned long len = 0;
            for(int i = 0; tc[i] != '\0'; i++) {
              len++;
            }
            unsigned char hash[SHA256_DIGEST_LENGTH];
            SHA256_CTX sha256;
            r = private_SHA256_Init(&sha256) == 1 ? r : 0;
            r = SHA256_Update(&sha256, tc, len) == 1 ? r : 0;
            r = SHA256_Final(hash, &sha256) == 1  ? r : 0;


            if (r == 1) {
                memmove(t2S,hash,S_LENGTH);

            } else {
                memmove(t2S,cannedSaltRaw,S_LENGTH);
            }
        }
        return t2S;
    }
    else if(SM == SMUnsecure) {
        if (t2S == NULL) {
            unsigned char cannedSaltRaw[S_LENGTH] = { 0x93, 0x0e, 0x4b, 0x4f, 0x72, 0x62, 0xaf, 0x75};
            t2S = calloc(S_LENGTH, sizeof(unsigned char));
            NSCAssert((t2S != NULL), @"Memory allocation error for _salt!");
            memmove(t2S,cannedSaltRaw,S_LENGTH);
            logAsHexString(t2S, (unsigned int) S_LENGTH, (char*) "   T2 Using forced salt");
        }
        return t2S;
    }
}

/*!
 * @brief Returns agenerated password
 *   Note that this routine is intentially obfuscated using opaque predicate and short names !
 * @return calculated salt
 */
NSString *t2p() {
    NSString *alphabet  = @"abcdefg!@#$%^&*()-hijklmnopqrstuvwxyzABCDEFG!@#$%^&*()-HIJKLMNOPQRSTUVWXZY012345678!@#$%^&*()-90ABCDEFGHIJKLMNOPQRSTUVWXYZ12!@#$%^&*()-";
    int i2 = sizeof(double);
    int j = 3^2;
    int parity = 6 + 4 - 2;
    int q = (int) exp(i2);
    long longMax = 21474;
    long zz1 = (long) pow(sizeof(int) + 5,4);

    zz1 += longMax * 11234 / q + 5;

    NSString *c1;

    NSString *string = [NSString stringWithFormat:@"%ld", zz1];
    NSMutableString *ss = [NSMutableString stringWithCapacity:210];
    NSString *ss1 = @"12834658";

    for (int even = 0; even < parity; even++) {

        int multiplier = 1;
        for (int i = 0; i < (int) string.length; i++) {
            NSRange rng = NSMakeRange((unsigned long) i,1);
            c1 = [string substringWithRange:rng];

            int ix = [c1 intValue];

            int ixm = ix * multiplier + even;
            multiplier++;
            if (multiplier > 9) {
                multiplier = 1;
            }
            if (ixm <= (int) alphabet.length) {
                ss1 = [alphabet substringWithRange:NSMakeRange((NSUInteger)ixm, 1)];

            }
            else {
                ss1 = @"ERROR";
            }
            [ss appendFormat:@"%@", ss1];
        }
    }

    int xx = sizeof(double) * 2;
    int result = 0;
    int f1 = (int) (log(j) ) * 32 + 1239327;

    if (f1 == 1239327) {
        result = 1257964;
    } else if (f1 == 1239327/16) {
        result = 22342266;
        zz1 += 1029;
        [ss appendFormat:@"%@", complexShift()];
    } else if (f1 == 1239327/32) {
        result = 3;
        zz1 *= 1029 + j;
    }

    f1 += xx/2 + 2;
    long final = f1 + 2836459;
    switch(final) {
        case 1268:
            [ss appendFormat:@"%@", ss1];
            break;
        case 44827590:
            [ss appendFormat:@"%@36812", ss1];
            break;
        case 22248593:
            [ss appendFormat:@"%@", complexShift()];
            break;
    }

    NSString *ret = [NSString stringWithString:ss];
    return ret;
}

// ---------------------------
// Routines for lost password


void generateMasterOrRemoteKeyAndSave(T2Key *RIKey, T2Key *LockingKey, NSString *const keyType) {
    //- (void)generateMasterOrRemoteKeyAndSave:(T2Key *) RIKey :(T2Key *) LockingKey :(NSString *const ) keyType {

    // This input to encrypt wil be the RIKey (key and iv concatenated)
    unsigned char *RIKeyAndIv = calloc((unsigned long) (RIKey->ivLength + RIKey->keyLength) + 1, sizeof(unsigned char));
    for (int i = 0; i < RIKey->keyLength; i++) {
        RIKeyAndIv[i] = RIKey->key[i];
    }
    for (int i = 0; i < RIKey->ivLength; i++) {
        RIKeyAndIv[i + RIKey->keyLength] = RIKey->iv[i];
    }
    RIKeyAndIv[RIKey->ivLength + RIKey->keyLength] = 0; // Terminate it with a zero

    /* The enc/dec functions deal with binary data and not C strings. strlen() will
     return length of the string without counting the '\0' string marker. We always
     pass in the marker byte to the encrypt/decrypt functions so that after decryption
     we end up with a legal C string */
    int len = (RIKey->ivLength + RIKey->keyLength) + 1;
    unsigned char *rawMasterKey = aes_e_calloc(&LockingKey->eContext, RIKeyAndIv, &len);

    if (rawMasterKey == NULL) {
        return;
    }
    // plaintext = (char *)aes_decrypt(&LockingKey.dContext, rawMasterKey, &len); // This is here just for debugging to confirm we can get it back

    free (RIKeyAndIv);

    if (vlOn) {
        logAsHexString((unsigned char *)rawMasterKey, (unsigned int) (RIKey->ivLength + RIKey->keyLength), (char *)  [NSString stringWithFormat:@"   %@", keyType].UTF8String);
    }

    NSMutableData *masterKey = [[NSMutableData alloc] init];
    [masterKey appendBytes:rawMasterKey length: (unsigned long)(RIKey->ivLength + RIKey->keyLength)];

    // Save Master Key to User Preferences
    // ------------------------------
    LOGI("INFO:   *** Save %@ Key to User Preferences ***\n", keyType);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:masterKey forKey:keyType];
    [defaults synchronize];

    free(rawMasterKey);
}

NSMutableData *eUsingKey(T2Key *c, NSString *t) {
    int len1 = (int) t.length;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    // Make sure we encrypt the terminating 0 also!
    char * entText = calloc((unsigned long)len1 + 1, sizeof(char));
    strcpy(entText, [t UTF8String]);
    entText[len1] = 0;
    len1++;
    unsigned char* szEncryptedText =  aes_e_calloc(&c->eContext, (unsigned char*)entText, &len1);
    free(entText);

    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    [encryptedData appendBytes:szEncryptedText length: (unsigned long)len1];
    return encryptedData;
}

NSString* dUsingKey(T2Key *c, NSMutableData *t) {
    int len1 = (int) t.length;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    // Make sure we decrypt the terminating 0 also!
    char * entText = calloc((unsigned long) len1 + 1, sizeof(char));
    memmove(entText, [t bytes], len1);
    entText[len1] = 0;
    len1++;
    unsigned char* szDecryptedText =  aes_d_calloc(&c->dContext,(unsigned char*)entText, &len1);
    free(entText);

    NSString *decryptedText = [NSString stringWithFormat:@"%s", szDecryptedText];
    return decryptedText;
}

int getRIKeyUsing(T2Key *RiKey, NSString *answersOrPin, NSString *const keyType) {
    Boolean retVal = false;
    T2Key LockingKey;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    if ([keyType isEqualToString:KEY_M_K]) {
        LOGI("INFO: ***  Generate Locking key ***\n");
    }
    else {
        LOGI("INFO: ***  Generate Secondarylocking key ***\n");
    }


    // Generate LockingKey = kdf(PIN)
    // ------------------------------
    unsigned char *key_data;
    int key_data_len = 0;
    key_data = (unsigned char *)answersOrPin.UTF8String;
    for(int i = 0; answersOrPin.UTF8String[i] != '\0'; i++) {
      key_data_len++;
    }

    /* gen key and iv. init the cipher ctx object */
    if (key_init(key_data, key_data_len, (unsigned char *)t2s(), &LockingKey)) {
        NSCAssert(FALSE, @"ERROR: initalizing key");
        return T2Error;
    }

    // Recall Masterkey or BackupKey from NVM based on keyType
    // --------------------------
    LOGI("INFO: ***  Recall %@ from NVM ***\n", keyType);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *masterKey= [defaults objectForKey:keyType];
    LOGI("INFO: Stored value = %@ ",masterKey);

    unsigned char *rawMasterKey = (unsigned char *)masterKey.bytes;
    int len;
    len = (EvpAesxxxKeyLength + EvpAesxxxIvLength) + 1;

    char *RIKeyAndIv = calloc((unsigned long)(EvpAesxxxKeyLength + EvpAesxxxIvLength) + 1, sizeof(char));
    RIKeyAndIv[EvpAesxxxKeyLength + EvpAesxxxIvLength] = 0; // Terminate it with a zero

    if ([keyType isEqualToString:KEY_M_K]) {
        LOGI("INFO: *** Generate RIKey = decrypt(MasterKey, LockingKey) ***\n");
    }
    else {
        LOGI("INFO: *** Generate RIKey = decrypt(BackupKey, SecondaryLockingKey) ***\n");
    }


    RIKeyAndIv = (char *) aes_d_calloc(&LockingKey.dContext, rawMasterKey, &len);
    // We now have the raw data, be must recreate the actual key contect from this
    keyCredentialsFromBytes((unsigned char*) RIKeyAndIv, EvpAesxxxKeyLength, EvpAesxxxIvLength, RiKey);
    RiKey->ivLength = EvpAesxxxIvLength;
    RiKey->keyLength = EvpAesxxxKeyLength;

    free(RIKeyAndIv);

    EVP_CIPHER_CTX_cleanup(&LockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.dContext);


    if (AM == AMGcm) {
        // Setup encryption context
        EVP_CIPHER_CTX_init(&RiKey->eContext);
        int i = EVP_EncryptInit_ex(&RiKey->eContext, EVP_aes_256_gcm(), NULL, NULL, NULL);    // Set up context to use specific cyper type
        if (i != 1) return retVal;

        EVP_CIPHER_CTX_init(&RiKey->dContext);
        i = EVP_DecryptInit_ex(&RiKey->dContext, EVP_aes_256_gcm(), NULL, NULL, NULL);    // Set up context to use specific cyper type
        if (i != 1) return retVal;


        /* Initialise key and IV */
        i = EVP_EncryptInit_ex(&RiKey->eContext, NULL, NULL, RiKey->key, RiKey->iv);
        if (i != 1) return retVal;

        i = EVP_EncryptInit_ex(&RiKey->dContext, NULL, NULL, RiKey->key, RiKey->iv);
        if (i != 1) return retVal;
    }

    return retVal;
}


NSString * eRaw(NSString *p, NSString *t) {
    T2Key RawKey;
    generic[0] = 0;   // Clear out generic buffer in case we fail

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    unsigned char *key_data;
    int key_data_len = 0;
    key_data = (unsigned char *)p.UTF8String;
    for(int i = 0; p.UTF8String[i] != '\0'; i++) {
      key_data_len++;
    }

    // Generate RawKey = kdf(PIN)
    // ------------------------------
    /* gen key and iv. init the cipher ctx object */

    if (key_init(key_data, key_data_len, t2s(), &RawKey)) {
        NSCAssert(FALSE, @"ERROR: initializing key");
        return t;
    } else {
        int outLength;
        unsigned char *encryptedString = eStringUsingKey_calloc(&RawKey, (unsigned char *)t.UTF8String, &outLength);
        NSCAssert((encryptedString != NULL), @"Memory allocation error");

        // Note: we can't return the encrhypted string directoy because JAVA will try to
        // interpret it as a string and fail UTF-8 conversion if any of the encrypted characters
        // have the high bit set. Therefore we must return a hex string equivalent of the binary
        char *tmp = binAsHexString_calloc(encryptedString, (unsigned int) outLength);
        NSCAssert((tmp != NULL), @"Memory allocation error");

        unsigned long size = 0;
        for(int i = 0; tmp[i] != '\0'; i++) {
          size++;
        }
        char* buffer[size * sizeof(char)];

        snprintf((char*) buffer, size + 1, "%s", tmp);
        free(tmp);

        NSString* message = [NSString stringWithFormat:@"%s", (char *) buffer];
        return message;
    }
}

NSString *eStringRaw(NSString *p, NSString * t) {
    return eRaw(p, t);
}

NSString * dRaw(NSString *p, NSString *t) {
    T2Key RawKey;
    generic[0] = 0;   // Clear out generic buffer in case we fail

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    unsigned char *key_data;
    int key_data_len = 0;
    key_data = (unsigned char *)p.UTF8String;
    for(int i = 0; p.UTF8String[i] != '\0'; i++) {
      key_data_len++;
    }
    int resultLength = 0;
    if (t != nil) {
        for(int i = 0; t.UTF8String[i] != '\0'; i++) {
          resultLength++;
        }
    } else {
        return nil;
    }
    char* buffer[resultLength * sizeof(char)];

    // Generate RawKey = kdf(PIN)
    // ------------------------------
    /* gen key and iv. init the cipher ctx object */

    if (key_init(key_data, key_data_len, t2s(), &RawKey)) {
        NSCAssert(FALSE, @"ERROR: initializing key");
        NSString* message = [NSString stringWithFormat:@"%s", (char *) buffer];
        return message;
    } else {

        unsigned char *resultBinary = hexStringAsBin_calloc((unsigned char*)t.UTF8String, &resultLength);
        if (resultBinary != NULL) {

            unsigned char *decrypted = dUsingKey_calloc1(&RawKey, ( unsigned char*)resultBinary, &resultLength);

            NSCAssert((decrypted != NULL), @"Memory allocation error");

            memmove(buffer, decrypted, resultLength);
            free(resultBinary);
        }
    }

    NSString* message = [NSString stringWithFormat:@"%s", (char *) buffer];
    return message;
}

NSString *dStringRaw(NSString *p, NSString *t)  {
    return dRaw(p, t);
}

int checkP(NSString * p) {
    int retVal = T2Error;
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    LOGI("INFO: === checkP ===\n");
    LOGI("INFO: *** Generating LockingKey  kdf(%s) ***\n", p.UTF8String);

    // Generate the RIKey based on Pin and Master Key
    getRIKeyUsing(rIKey_1, p, KEY_M_K);

    // Read the PIN from NVM and make sure we can decode it properly
    // if not fail login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *encryptedPin = [defaults objectForKey:KEY_D_P];
    NSString *decryptedPIN = dUsingKey(rIKey_1, encryptedPin);

    EVP_CIPHER_CTX_cleanup(&acredential.eContext);
    EVP_CIPHER_CTX_cleanup(&acredential.eContext);

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);

    if ([decryptedPIN isEqualToString:p]) {
        initP = p;
        retVal = T2Success;
    }
    else {
        LOGI("WARNING: PIN does not match");
    }
    return retVal;
}

int checkA(NSString *a) {
    int retVal = T2Error;
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    LOGI("INFO: === checkA ===\n");
    LOGI("INFO: *** Generating Secondary LockingKey  kdf(%s) ***\n", a.UTF8String);

    // Generate the RIKey based on Pin and Master Key
    getRIKeyUsing(rIKey_1, a, KEY_B_K);

    EVP_CIPHER_CTX_cleanup(&acredential.eContext);
    EVP_CIPHER_CTX_cleanup(&acredential.eContext);

    // Read the CHECK from NVM and make sure we can decode it properly
    // if not fail login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *encryptedCheck = [defaults objectForKey:KEY_D_C];
    NSString *decryptedCheck = dUsingKey(rIKey_1, encryptedCheck);

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);
    if ([decryptedCheck isEqualToString:KCHECK]) {
        retVal = T2Success;
    }
    else {
        LOGI("WARNING: answers does not match");
    }
    return retVal;
}

// -----------------------------------------------------------------------------------
#pragma mark - Pin management routines
// -----------------------------------------------------------------------------------


int changePUsingP(NSString *oP, NSString *nP) {
    T2Key LockingKey;
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");
    LOGI("INFO: === changePUsingP ===\n");

    int result = checkP(oP);
    if (result != T2Success) {
        return T2Error;
    }

    // Generate the RIKey based on oldPin and Master Key
    getRIKeyUsing(rIKey_1, oP, KEY_M_K);

    // Generate LockingKey = kdf(newPin)
    // ------------------------------
    LOGI("INFO: *** Generating LockingKey  kdf(%s) ***\n", nP.UTF8String);

    {
        unsigned char *key_data = (unsigned char *)nP.UTF8String;
        int key_data_len = 0;
        for(int i = 0; nP.UTF8String[i] != '\0'; i++) {
          key_data_len++;
        }

        /* gen key and iv. init the cipher ctx object */
        if (key_init(key_data, key_data_len, (unsigned char *)t2s(), &LockingKey)) {
            NSCAssert(FALSE, @"ERROR: initalizing key");
            return T2Error;
        }
    }

    // Generate MasterKey = encrypt(RI Key, LockingKey)
    // ------------------------------
    LOGI("INFO: *** Generating and saving to NVM MasterKey ***\n");
    generateMasterOrRemoteKeyAndSave(rIKey_1, &LockingKey, KEY_M_K);

    initP = nP;

    // Encrypt the PIN and save to NVM
    NSMutableData *encryptedPIN = eUsingKey(rIKey_1, nP);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedPIN forKey:KEY_D_P];
    [defaults synchronize];

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.dContext);

    return T2Success;
}

int changePUsingA(NSString *p, NSString *a) {
    T2Key LockingKey;
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    int result = checkA(a);
    if (result != T2Success) {
        return T2Error;
    }

    LOGI("INFO: === changePUsingA ===\n");
    LOGI("INFO: *** getRIKeyUsing answers and backup key %s ***\n", a.UTF8String);
    // Generate the RIKey based on oldPin and Master Key
    getRIKeyUsing(rIKey_1, a, KEY_B_K);

    // Generate LockingKey = kdf(newPin)
    // ------------------------------
    LOGI("INFO: *** Generating New LockingKey  kdf(%s) ***\n", p.UTF8String);

    {
        unsigned char *key_data = (unsigned char *)p.UTF8String;
        int key_data_len = 0;
        for(int i = 0; p.UTF8String[i] != '\0'; i++) {
          key_data_len++;
        }

        /* gen key and iv. init the cipher ctx object */
        if (key_init(key_data, key_data_len, (unsigned char *)t2s(), &LockingKey)) {
            NSCAssert(FALSE, @"ERROR: initalizing key");
            return T2Error;
        }
    }

    // Generate MasterKey = encrypt(RI Key, LockingKey)
    // ------------------------------
    LOGI("INFO: *** Generating and saving to NVM  new MasterKey ***\n");
    generateMasterOrRemoteKeyAndSave(rIKey_1, &LockingKey, KEY_M_K);

    initP = p;

    // Encrypt the PIN and save to NVM
    NSMutableData *encryptedPIN = eUsingKey(rIKey_1, p);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encryptedPIN forKey:KEY_D_P];
    [defaults synchronize];

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.dContext);

    return T2Success;
}

int changeAUsingP(NSString *p, NSString *a) {
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;
    T2Key SecondaryLockingKey;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");
    LOGI("INFO: === changeAnswersUsingPin ===\n");

    // If the pin is not correct error out
    int result = checkP(p);
    if (result != T2Success) {
        return T2Error;
    }

    // Pin is ok, go ahead and change the backup key
    // Generate the RIKey based on Pin and Master Key
    getRIKeyUsing(rIKey_1, p, KEY_M_K);

    // Generate new SecondaryLockingKey = kdf(answers)
    // ------------------------------
    LOGI("INFO: *** Generating SecondaryLockingKey ***\n");

    {
        unsigned char *key_data = (unsigned char *)a.UTF8String;
        int key_data_len = 0;
        for(int i = 0; a.UTF8String[i] != '\0'; i++) {
          key_data_len++;
        }

        /* gen key and iv. init the cipher ctx object */
        if (key_init(key_data, key_data_len, (unsigned char *)t2s(), &SecondaryLockingKey)) {
            EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
            EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);
            NSCAssert(FALSE, @"ERROR: initalizing key");
            return T2Error;
        }
    }

    // Generate BackupKey = encrypt(RI Key, SecondaryLockingKey)
    // ------------------------------
    LOGI("INFO: *** Generating and saving to nvm BackupKey ***\n");
    generateMasterOrRemoteKeyAndSave(rIKey_1, &SecondaryLockingKey, KEY_B_K);

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);
    EVP_CIPHER_CTX_cleanup(&SecondaryLockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&SecondaryLockingKey.dContext);

    return T2Success;
}

NSString *getDKUsingP(NSString *p) {
    T2Key aRIKey;
    T2Key *RIKey = &aRIKey;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    // Make sure the pin is correct
    int result = checkP(p);
    if (result != T2Success) {
        return @"";
    }

    // First get the RIKey based in the given pin
    result = getRIKeyUsing(RIKey, p, KEY_M_K);
    if (result == T2Success) {
        // RIKey is now set up
        // Now create the database key by appending the key and iv
        unsigned char *RIKeyAndIv = calloc((unsigned long)(RIKey->keyLength + RIKey->ivLength) + 1, sizeof(unsigned char));
        for (int i = 0; i < RIKey->keyLength; i++) {
            RIKeyAndIv[i] = RIKey->key[i];
        }
        for (int i = 0; i < RIKey->ivLength; i++) {
            RIKeyAndIv[i + RIKey->keyLength] = RIKey->iv[i];
        }
        RIKeyAndIv[RIKey->keyLength + RIKey->ivLength] = 0; // Terminate it with a zero

        char *result = binAsHexString_calloc(RIKeyAndIv, (unsigned int)(RIKey->keyLength + RIKey->ivLength));

        // Note that the format of this string is specific
        // IT tells SQLCipher to use this key directly instead of
        // using it as a password to derrive a key from
        NSString *combinedKey = [NSString stringWithFormat :@"x'%s'", result];
        LOGI("Database key = %s\n", combinedKey.UTF8String);

        free(result);
        free(RIKeyAndIv);
        EVP_CIPHER_CTX_cleanup(&RIKey->eContext);
        EVP_CIPHER_CTX_cleanup(&RIKey->dContext);

        return combinedKey;
    } else {
        return @"";
    }
}

// -----------------------------------------------------------------------------------
#pragma mark - Simulated database routines
// -----------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------
// The remaining routines are used in test. They use one locatin in UserPereferences
// (KEY_D) to simulate a database
// -----------------------------------------------------------------------------------


int putPwdData(NSString *dataToWrite) {
    LOGI("INFO: === WriteDataToDatabase ===\n");

    LOGI("INFO: Writing %s to database\n", dataToWrite.UTF8String);

    // Generate RIKey based on Pin and Master Key
    T2Key RIKey_1;
    getRIKeyUsing(&RIKey_1, initP, KEY_M_K);

    // Now we have the reconstituted RiKey (RIKey_1), encrypt the data and save it to NVM
    LOGI("INFOL: *** encryptedWriteData = encrypt(WriteData, RIKey) ***\n");
    int len1 = (int) dataToWrite.length;

    // Make sure we encrypt the terminating 0 also!
    char * entText = calloc((unsigned long)len1 + 1, sizeof(char));
    strcpy(entText, [dataToWrite UTF8String]);
    entText[len1] = 0;
    len1++;

    unsigned char* encryptedText =  aes_e_calloc(&RIKey_1.eContext, (unsigned char*)entText, &len1);

    free(entText);

    // Convert it to NSMutableData
    NSMutableData *databaseData= [[NSMutableData alloc] init];
    [databaseData appendBytes:encryptedText length:(unsigned long)len1];


    // Save it in NVM
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:databaseData forKey:KEY_D];
    [defaults synchronize];

    free(encryptedText);

    EVP_CIPHER_CTX_cleanup(&RIKey_1.eContext);
    EVP_CIPHER_CTX_cleanup(&RIKey_1.dContext);


    return T2Success;
}


NSString *getPwdData() {

    T2Key RIKey;
    getRIKeyUsing(&RIKey, initP, KEY_M_K);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *databaseData = [defaults objectForKey:KEY_D];
    char *encryptedData = calloc(databaseData.length + 1, sizeof(char));
    memmove(encryptedData, [databaseData bytes], databaseData.length);

    // Decrypt it
    int len = (int) databaseData.length;
    char *plaintext = (char *)aes_d_calloc(&RIKey.dContext, (unsigned char*)databaseData.bytes, &len);
    NSString *tmp2 = [NSString stringWithUTF8String:plaintext];
    free(plaintext);
    EVP_CIPHER_CTX_cleanup(&RIKey.eContext);
    EVP_CIPHER_CTX_cleanup(&RIKey.dContext);
    return tmp2;
}


NSString *getPwdDataEncrypted() {
    // First display the encrypted data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *databaseData = [defaults objectForKey:KEY_D];
    char *encryptedData = calloc(databaseData.length + 1, sizeof(char));
    memmove(encryptedData, [databaseData mutableBytes], databaseData.length);

    encryptedData[databaseData.length] = 0;
    NSString *tmp = [NSString stringWithFormat:@"%s", encryptedData];

    free(encryptedData);
    return tmp;
}

// -----------------------------------------------------------------------------------
#pragma mark - Migration Routines
// -----------------------------------------------------------------------------------
// -----------------------------------------------------------------------------------
// Migration Routines
// -----------------------------------------------------------------------------------

int migratePAndA(NSString *p, NSString *a, int c, int n) {
    unsigned char* salt;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    setAM(c);

    if(c == AMCbc) {
        //Set the salt mode for any decryption and encryption that needs to happen even though we are retrieving the salt
        setSM(SMUnsecure);

        //Retrieve old salt from userdefaults
        NSData * saltMutableData = [defaults objectForKey:KEY_S];
        salt = (unsigned char *)saltMutableData.bytes;
    }
    else {
        salt = (unsigned char*)t2s();
    }

    if(checkPWithS(p, salt) == T2Success && checkAWithS(a, salt) == T2Success) {
        //Save the old master key in order to get the old db password
        NSString* oldPassword = getDKUsingS(p, salt);
        [defaults setObject:oldPassword forKey:KEY_O_M_K];
        [defaults synchronize];

        //Set to the newest Aes and Salt mode
        setAM(n);
        if(n == AMCbc) {
            setSM(SMUnsecure);
        }
        else {
            setSM(SMSecure);
        }

        initializeLogin(p, a);

        return T2Success;
    }
    else {
        return T2Error;
    }
}

NSString* getDKUsingS(NSString* p, unsigned char* s) {
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    getRIKeyWithSUsing(rIKey_1, s, p, KEY_M_K);

    // RIKey is now set up
    // Now create the database key by appending the key and iv
    unsigned char *RIKeyAndIv = calloc((unsigned long)(rIKey_1->keyLength + rIKey_1->ivLength) + 1, sizeof(unsigned char));
    for (int i = 0; i < rIKey_1->keyLength; i++) {
        RIKeyAndIv[i] = rIKey_1->key[i];
    }
    for (int i = 0; i < rIKey_1->ivLength; i++) {
        RIKeyAndIv[i + rIKey_1->keyLength] = rIKey_1->iv[i];
    }
    RIKeyAndIv[rIKey_1->keyLength + rIKey_1->ivLength] = 0; // Terminate it with a zero

    char *result = binAsHexString_calloc(RIKeyAndIv, (unsigned int)(rIKey_1->keyLength + rIKey_1->ivLength));

    // Note that the format of this string is specific
    // IT tells SQLCipher to use this key directly instead of
    // using it as a password to derrive a key from
    NSString *combinedKey = [NSString stringWithFormat :@"x'%s'", result];
    LOGI("Database key = %s\n", combinedKey.UTF8String);

    free(result);
    free(RIKeyAndIv);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);

    return combinedKey;
}

int getRIKeyWithSUsing(T2Key * k, unsigned char* s, NSString * aop, NSString *const type) {
    Boolean retVal = false;
    T2Key LockingKey;

    if ([type isEqualToString:KEY_M_K]) {
        LOGI("INFO: ***  Generate Locking key ***\n");
    }
    else {
        LOGI("INFO: ***  Generate Secondarylocking key ***\n");
    }


    // Generate LockingKey = kdf(PIN)
    // ------------------------------
    unsigned char *key_data;
    int key_data_len = 0;
    key_data = (unsigned char *)aop.UTF8String;
    for(int i = 0; aop.UTF8String[i] != '\0'; i++) {
      key_data_len++;
    }

    /* gen key and iv. init the cipher ctx object */
    if (key_init(key_data, key_data_len, s, &LockingKey)) {
        NSCAssert(FALSE, @"ERROR: initalizing key");
        return T2Error;
    }

    // Recall Masterkey or BackupKey from NVM based on keyType
    // --------------------------
    LOGI("INFO: ***  Recall %@ from NVM ***\n", type);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *masterKey= [defaults objectForKey:type];
    LOGI("INFO: Stored value = %@ ",masterKey);

    //Determine key and iv length off the current aes mode
    int keyLength = EVP_aes_256_cbc_Key_LENGTH;
    int ivLength = EVP_aes_256_cbc_Iv_LENGTH;
    if(AM == AMGcm) {
        keyLength = EVP_aes_256_gcm_Key_LENGTH;
        ivLength = EVP_aes_256_gcm_Iv_LENGTH;
    }

    unsigned char *rawMasterKey = (unsigned char *)masterKey.bytes;
    int len;
    len = (keyLength + ivLength) + 1;

    char *RIKeyAndIv = calloc((keyLength + ivLength) + 1, sizeof(char));
    RIKeyAndIv[keyLength + ivLength] = 0; // Terminate it with a zero

    if ([type isEqualToString:KEY_M_K]) {
        LOGI("INFO: *** Generate RIKey = decrypt(MasterKey, LockingKey) ***\n");
    }
    else {
        LOGI("INFO: *** Generate RIKey = decrypt(BackupKey, SecondaryLockingKey) ***\n");
    }


    RIKeyAndIv = (char *)aes_d_calloc(&LockingKey.dContext, rawMasterKey, &len);

    // We now have the raw data, be must recreate the actual key contect from this
    keyCredentialsFromBytes((unsigned char*) RIKeyAndIv, keyLength, ivLength, k);
    k->ivLength = ivLength;
    k->keyLength = keyLength;


    free(RIKeyAndIv);

    EVP_CIPHER_CTX_cleanup(&LockingKey.eContext);
    EVP_CIPHER_CTX_cleanup(&LockingKey.dContext);

    if (AM == AMGcm) {
        // Setup encryption context
        EVP_CIPHER_CTX_init(&k->eContext);
        int i = EVP_EncryptInit_ex(&k->eContext, EVP_aes_256_gcm(), NULL, NULL, NULL);    // Set up context to use specific cyper type
        if (i != 1) return retVal;

        EVP_CIPHER_CTX_init(&k->dContext);
        i = EVP_DecryptInit_ex(&k->dContext, EVP_aes_256_gcm(), NULL, NULL, NULL);    // Set up context to use specific cyper type
        if (i != 1) return retVal;


        /* Initialise key and IV */
        i = EVP_EncryptInit_ex(&k->eContext, NULL, NULL, k->key, k->iv);
        if (i != 1) return retVal;

        i = EVP_EncryptInit_ex(&k->dContext, NULL, NULL, k->key, k->iv);
        if (i != 1) return retVal;
    }

    return retVal;
}

int checkPWithS(NSString * p, unsigned char* s) {
    int retVal = T2Error;
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    LOGI("INFO: === checkPWithS ===\n");
    LOGI("INFO: *** Generating LockingKey  kdf(%s) ***\n", p.UTF8String);

    // Generate the RIKey based on Pin and Master Key
    getRIKeyWithSUsing(rIKey_1, s, p, KEY_M_K);

    // Read the PIN from NVM and make sure we can decode it properly
    // if not fail login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *encryptedPin = [defaults objectForKey:KEY_D_P];

    NSString *decryptedPIN = dUsingKey(rIKey_1, encryptedPin);

    EVP_CIPHER_CTX_cleanup(&acredential.eContext);
    EVP_CIPHER_CTX_cleanup(&acredential.eContext);

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);

    if ([decryptedPIN isEqualToString:p]) {
        initP = p;
        retVal = T2Success;
    }
    else {
        LOGI("WARNING: PIN does not match");
    }
    return retVal;
}

int checkAWithS(NSString *a, unsigned char* s) {
    int retVal = T2Error;
    T2Key acredential;
    T2Key *rIKey_1 = &acredential;

    NSCAssert((isInd == TRUE), @"INFO: ***  T2Crypto MUST be initialized before use");

    LOGI("INFO: === checkAWithS ===\n");
    LOGI("INFO: *** Generating Secondary LockingKey  kdf(%s) ***\n", a.UTF8String);

    // Generate the RIKey based on Pin and Master Key
    getRIKeyWithSUsing(rIKey_1, s, a, KEY_B_K);

    EVP_CIPHER_CTX_cleanup(&acredential.eContext);
    EVP_CIPHER_CTX_cleanup(&acredential.eContext);

    // Read the CHECK from NVM and make sure we can decode it properly
    // if not fail login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableData *encryptedCheck = [defaults objectForKey:KEY_D_C];
    NSString *decryptedCheck = dUsingKey(rIKey_1, encryptedCheck);

    EVP_CIPHER_CTX_cleanup(&rIKey_1->eContext);
    EVP_CIPHER_CTX_cleanup(&rIKey_1->dContext);
    if ([decryptedCheck isEqualToString:KCHECK]) {
        retVal = T2Success;
    }
    else {
        LOGI("WARNING: answers does not match");
    }
    return retVal;
}

// -----------------------------------------------------------------------------------
#pragma mark - Standalone routiknes (uses internally generated password)
// -----------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------
// Standalone routiknes (uses internally generated password)
// -----------------------------------------------------------------------------------
NSString *eRawP(NSString * t) {
    return eStringRaw(t2p(),t);
}

NSString *dRawP(NSString * t) {
    return dStringRaw(t2p(),t);
}

NSData * eBytesRawP(NSData *b) {
    return eBytesRaw(t2p(), b);
}

NSData * dBytesRawP(NSData *b) {
    return dBytesRaw(t2p(), b);
}

int processBinaryFileP(NSString* i, NSString* o, int op) {
    return processBinaryFile(i, o, op, t2p());
}

// For Unity only
unsigned char * eCharStringP(unsigned char * t, int * l) {
    return eCharString((unsigned char *)t2p().UTF8String, t, l);
}

// For Unity only
unsigned char * eCharString_callocP(unsigned char * t, int * l) {
    return eCharString_calloc((unsigned char *)t2p().UTF8String, t, l);
}

// For Unity only
unsigned char * dCharStringP(unsigned char * t, int * l) {
    return dCharString((unsigned char *)t2p().UTF8String, t, l);
}

// For Unity only
unsigned char * dCharString_callocP(unsigned char * t, int * l) {
    return dCharString((unsigned char *)t2p().UTF8String, t, l);
}




@end
