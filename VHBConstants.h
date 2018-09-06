//
//  VHBConstants.h
//  VirtualHopeBox
//
//  Created by Martin Chibwe on 4/18/17.
//  Copyright © 2017 The Geneva Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>


//FIPS encode key
extern NSString * const kUserDefaultsKeyDareImplemented;
    extern NSString * const kUserDefaultsKeyDareBase;

//User Defaults
extern NSString * const userDefaults_resetHelpPrompts;
extern NSString * const userDefaults_resetHelpUserDefault;
extern NSString * const userDefaults_checkoxIsSelected;
extern NSString * const userDefaults_eula_accepted;
extern NSString * const userDefaults_repromptPreVAS;
extern NSString * const userDefaults_repromptPostVAS;

extern NSString * const userDefaults_USE_RESEARCHSTUDY;
extern NSString * const userDefaults_PARTICIPANTNUMBER;
extern NSString * const userDefaults_DEFAULTS_STUDYEMAIL;
extern NSString * const userDefaults_ENROLLMENTPASSWORD;
extern NSString * const userDefaults_SEND_PASSWORD;

//
extern NSString * const cFirstTime;
extern NSString * const cSTUDY;
@interface VHBConstants : NSObject

@end
