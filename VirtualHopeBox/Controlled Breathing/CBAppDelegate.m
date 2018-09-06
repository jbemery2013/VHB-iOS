//
//  ExampleSourcFile.m
//  VirtualHopeBox
//

/*
*
* VirtualHopeBox 
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
* Government Agency Original Software Designation: VirtualHopeBox 
* Government Agency Original Software Title: VirtualHopeBox 
* User Registration Requested. Please send email
* with your contact information to: robert.kayl2@us.army.mil
* Government Agency Point of Contact for Original Software: robert.kayl2@us.army.mil
*
*/

#import "CBAppDelegate.h"
#import "CBMusicType.h"
#import "CBBackgroundType.h"
#import "DefaultsWrapper.h"

@implementation CBAppDelegate

+ (void)initDataWithContext:(NSManagedObjectContext *)context defaults:(NSUserDefaults *)defaults;
{
    if (!decryptBoolForKey(@"cb_initialized")) {
        //[defaults setFloat:6.0 forKey:@"inhale_duration"];
        //[defaults setFloat:6.0 forKey:@"exhale_duration"];
        //[defaults setFloat:0 forKey:@"hold_duration"];
        //[defaults setFloat:0 forKey:@"rest_duration"];
        //[defaults setFloat:0 forKey:@"session_duration"];
        
        //[defaults setBool:YES forKey:@"vocal_prompts"];
        //[defaults setInteger:kRainforest forKey:@"background_type"];
        //[defaults setInteger:kRandom forKey:@"music_type"];
        
        //[defaults setBool:YES forKey:@"cb_initialized"];
        
        //[defaults setValue:[NSNumber numberWithInt:1] forKey:@"cb_version"];
        
        encryptFloatForKey(@"cb_initialized", 6.0);
        encryptFloatForKey(@"inhale_duration", 6.0);
        encryptFloatForKey(@"exhale_duration", 6.0);
        encryptFloatForKey(@"hold_duration", 0);
        encryptFloatForKey(@"rest_duration", 0);
        encryptFloatForKey(@"session_duration", 0);
        encryptBoolForKey(@"vocal_prompts", YES);
        encryptFloatForKey(@"background_type", kRainforest);
        encryptFloatForKey(@"music_type", kRandom);
        encryptBoolForKey(@"cb_initialized", YES);
        encryptIntForKey(@"cb_version", 1);
    }
}

+ (NSManagedObjectModel *)getObjectModels
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CBModel" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

@end
