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

#import "SudokuCell.h"

@implementation SudokuCell

@synthesize marks, locked, solution;

- (id)init
{
    self = [super init];
    if (self != nil) {
        marks = [[NSMutableSet alloc] init];
    }
    return self;
}

- (BOOL) isCorrect
{
    if (marks.count > 1 || marks.count == 0) {
        return YES;
    }
    
    return [solution compare:[marks anyObject]] == NSOrderedSame;
}

- (BOOL) isEmpty
{
    return marks.count == 0;
}

- (void)clearMarks
{
    [marks removeAllObjects];
}

- (void)invertMarks
{
    for (int i = 1; i <= 9; i++) {
        [self toggleMark:i];
    }
}

- (BOOL)toggleMark:(int)value
{
    NSNumber *number = [NSNumber numberWithInt:value];
    if ([marks containsObject:number]) {
        [marks removeObject:number];
        return FALSE;
    } else {
        [marks addObject:number];
        return TRUE;
    }
}

- (NSString *)description
{
    NSMutableString *line = [[NSMutableString alloc] init];
    if ([self isEmpty]) {
        [line appendString:@"."];
    } else {
        [line appendString:@"["];
        for (NSNumber *number in marks) {
            [line appendFormat:@"%@", number];
        }
        [line appendString:@"]"];
    }
    return line;
}

@end
