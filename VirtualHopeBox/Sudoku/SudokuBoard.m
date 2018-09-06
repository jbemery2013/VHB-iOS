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

#import "SudokuBoard.h"
#import "SudokuCell.h"
#import <CoreData/CoreData.h>

@interface SudokuBoard ()

@property (readwrite) SudokuPuzzle *puzzle;

@end

@implementation SudokuBoard

@synthesize puzzle, cells;

- (id)init
{
    self = [super init];
    if (self != nil) {
        cells = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)loadPuzzle:(SudokuPuzzle *)obj
{
    [self setPuzzle:obj];
    [self initBoard];
}

- (void)initBoard
{
    [cells removeAllObjects];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterNoStyle];
    
    for (int i = 0; i < puzzle.completed_state.length; i++) {
        SudokuCell *cell = [[SudokuCell alloc] init];
        [cells addObject:cell];
        
        NSString *val = [puzzle.completed_state substringWithRange:NSMakeRange(i, 1)];
        NSString *defVal = [puzzle.default_state substringWithRange:NSMakeRange(i, 1)];
        
        if (puzzle.complete.intValue > 0 || ![defVal isEqualToString:@"."]) {
            cell.locked = YES;
        }
        
        cell.solution = [formatter numberFromString:val];
    }
    
    
    int currentPosition = 0;
    SudokuCell *cell;
    for (int i = 0; i < puzzle.current_state.length; i++) {
        NSString *val = [puzzle.current_state substringWithRange:NSMakeRange(i, 1)];

        if ([val isEqualToString:@"["]) {
            cell = (SudokuCell *) [cells objectAtIndex:currentPosition];
        } else if ([val isEqualToString:@"]"]) {
            cell = nil;
            currentPosition++;
        } else if (cell != nil) {
            [cell.marks addObject:[formatter numberFromString:val]];
        } else {
            currentPosition++;
        }
    }
    
    //NSLog(@"\n%@", self);
}

- (BOOL)isComplete
{
    for (SudokuCell *cell in cells) {
        if (cell.locked) {
            continue;
        } else if ([cell isEmpty] || [cell.marks count] > 1) {
            return NO;
        }
        
        NSNumber *num = (NSNumber *) [cell.marks anyObject];
        if (num.intValue != cell.solution.intValue) {
            return NO;
        }
    }

    return YES;
}

- (NSString *)description
{
    NSMutableString *line = [[NSMutableString alloc] init];
    
    int count = 0;
    for (SudokuCell *cell in cells) {
        if (cell.locked) {
            [line appendFormat:@"%i", cell.solution.intValue];
        } else {
            [line appendString:@"0"];
        }
        
        if (count % 9 == 8) {
            [line appendString:@"\n"];
        }
        count++;
    }
    return line;
}

@end
