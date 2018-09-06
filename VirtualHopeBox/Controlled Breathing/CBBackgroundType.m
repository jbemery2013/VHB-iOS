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

#import "CBBackgroundType.h"

NSString* const kBackgroundTypeName[] = {
    [kRainforest] = @"Rainforests",
    [kBeaches] = @"Beaches: Courtesy of NOAA",
    [kMyPictures] = @"My Pictures",
};

@implementation CBBackgroundType

+ (NSString *)nameForBackgroundType:(kBackgroundType)type
{
    return kBackgroundTypeName[type];
}

+ (int)imageCountForBackgroundType:(kBackgroundType)type
{
    switch (type) {
        case kRainforest:
            return 8;
            break;
        case kBeaches:
            return 12;
        default:
            return 0;
    }
}

+ (NSString *)fileNamePrefixForBackgroundType:(kBackgroundType)type
{
    switch (type) {
        case kRainforest:
            return @"rainforest";
            break;
        case kBeaches:
            return @"beach";
        default:
            return nil;
    }
}

@end
