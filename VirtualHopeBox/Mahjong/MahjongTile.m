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

#import "MahjongTile.h"

@implementation MahjongTile

@synthesize visible, matchValue, matchSubValue;

- (id)init
{
    self = [super init];
    if (self) {
        matchValue = 41;
    }
    return self;
}

- (int)matchValue
{
    return matchValue;
}

- (int)imageId
{
    // Flowers and Seasons have special matching rules.
    if (matchValue == 33) {
        return matchValue + matchSubValue;
    } else if (matchValue == 34) {
        return matchValue + matchSubValue + 3;
    } else {
        return matchValue;
    }
}

- (NSString *)name
{
    switch ([self imageId]) {
        case 0:
            return @"One of Circles";
        case 1:
            return @"Two of Circles";
        case 2:
            return @"Three of Circles";
        case 3:
            return @"Four of Circles";
        case 4:
            return @"Five of Circles";
        case 5:
            return @"Six of Circles";
        case 6:
            return @"Seven of Circles";
        case 7:
            return @"Eight of Circles";
        case 8:
            return @"Nine of Circles";
        case 9:
            return @"North Wind";
        case 10:
            return @"West Wind";
        case 11:
            return @"South Wind";
        case 12:
            return @"East Wind";
        case 13:
            return @"Red Dragon";
        case 14:
            return @"Green Dragon";
        case 15:
            return @"One of Characters";
        case 16:
            return @"Two of Characters";
        case 17:
            return @"Three of Characters";
        case 18:
            return @"Four of Characters";
        case 19:
            return @"Five of Characters";
        case 20:
            return @"Six of Characters";
        case 21:
            return @"Seven of Characters";
        case 22:
            return @"Eight of Characters";
        case 23:
            return @"Nine of Characters";
        case 24:
            return @"One of Bamboo";
        case 25:
            return @"Two of Bamboo";
        case 26:
            return @"Three of Bamboo";
        case 27:
            return @"Four of Bamboo";
        case 28:
            return @"Five of Bamboo";
        case 29:
            return @"Six of Bamboo";
        case 30:
            return @"Seven of Bamboo";
        case 31:
            return @"Eight of Bamboo";
        case 32:
            return @"Nine of Bamboo";
        case 33:
            return @"Spring";
        case 34:
            return @"Summer";
        case 35:
            return @"Autumn";
        case 36:
            return @"Winter";
        case 37:
            return @"Plum";
        case 38:
            return @"Orchid";
        case 39:
            return @"Chrysanthemum";
        case 40:
            return @"Bamboo";
    }
    
    return @"Empty";
}

@end
