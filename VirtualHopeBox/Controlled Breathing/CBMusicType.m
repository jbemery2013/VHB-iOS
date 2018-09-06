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

#import "CBMusicType.h"

NSString* const kMusicTypeName[] = {
    [kNone] = @"No Music",
    [kMyMusic] = @"My Music",
    [kRandom] = @"Random",
    [kAmbientEvenings] = @"Ambient Evenings",
    [kEvoSolution] = @"Evo Solution",
    [kOceanMist] = @"Ocean Mist",
    [kWaningMoments] = @"Waning Moments",
    [kWatermark] = @"Watermark"
};

@implementation CBMusicType

+ (NSString *)nameForMusicType:(kMusicType)type
{
    return kMusicTypeName[type];
}

+ (NSURL *)pathForMusicType:(kMusicType)type
{    
    switch (type) {
        case kAmbientEvenings:
            return [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"ambientevenings" ofType:@"mp3"]];
        case kEvoSolution:
            return [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"evosolution" ofType:@"mp3"]];
        case kOceanMist:
            return [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"oceanmist" ofType:@"mp3"]];
        case kWaningMoments:
            return [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"waningmoments" ofType:@"mp3"]];
        case kWatermark:
            return [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"watermark" ofType:@"mp3"]];
        default:
            return nil;
    }
}

@end
