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

#import "ImageSwapPuzzle.h"
#import "ImageSwapTile.h"

@interface ImageSwapPuzzle () {
    float tileWidth;
    float tileHeight;
}

@end

@implementation ImageSwapPuzzle

@synthesize tiles;
@synthesize rows;
@synthesize columns;

- (id)initWithRows:(int)rowsVal columns:(int)columnsVal
{
    self = [super init];
    if (self) {
        rows = rowsVal;
        columns = columnsVal;
        
        tiles = [[NSMutableArray alloc] init];
        for (int index = 0; index < (rows * columns); index++) {
            ImageSwapTile *tile = [[ImageSwapTile alloc] init];
            tile.currentPosition = index;
            tile.solvedPosition = index;
            [tiles addObject:tile];
        }
    }
    return self;
}

- (BOOL)isComplete
{
    for (ImageSwapTile *tile in tiles) {
        if (tile.currentPosition != tile.solvedPosition) {
            return NO;
        }
    }
    return YES;
}

@end
