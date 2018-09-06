//
//  VHBConstants.m
//  VirtualHopeBox
//
//  Created by Martin Chibwe on 4/18/17.
//  Copyright © 2017 The Geneva Foundation. All rights reserved.
//

#import "VHBConstants.h"

NSString * const kUserDefaultsKeyDareImplemented = @"com.vpd.B2R.DareImplemented";
//NSString * const kUserDefaultsKeyDareBase = @"com.vpd.B2R.DareBase";

#pragma mark - NSUserDefaults
NSString * const userDefaults_resetHelpPrompts = @"resetHelpPrompts";
NSString * const userDefaults_resetHelpUserDefault = @"resetHelpUserDefault";
NSString * const userDefaults_checkoxIsSelected = @"checkoxIsSelected";

//EULA Accepted?
NSString * const userDefaults_eula_accepted = @"eula_accepted";

//Does DB Stress values need to be clear?
NSString * const userDefaults_repromptPreVAS = @"repromptPreVAS";
NSString * const userDefaults_repromptPostVAS = @"repromptPostVAS";

NSString * const userDefaults_USE_RESEARCHSTUDY = @"DEFAULTS_USE_RESEARCHSTUDY";
NSString * const userDefaults_PARTICIPANTNUMBER = @"DEFAULTS_PARTICIPANTNUMBER";
NSString * const userDefaults_DEFAULTS_STUDYEMAIL = @"DEFAULTS_STUDYEMAIL";
NSString * const userDefaults_ENROLLMENTPASSWORD = @"DEFAULTS_ENROLLMENTPASSWORD";
NSString * const userDefaults_SEND_PASSWORD = @"DEFAULTS_SEND_PASSWORD";

#pragma mark - Used in Database
NSString * const cFirstTime = @"firstTime";

#pragma mark - Research Study
NSString * const cSTUDY = @"STUDY";

@implementation VHBConstants

@end
