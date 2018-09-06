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

#import "SudokuAppDelegate.h"
#import "SudokuPuzzle.h"
#import "DefaultsWrapper.h"

@implementation SudokuAppDelegate
+ (void)initDataWithContext:(NSManagedObjectContext *)context defaults:(NSUserDefaults *)defaultsold
{
    if (!decryptBoolForKey(@"sudoku_initialized")) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"sudoku_puzzles" ofType:@"txt"];
        NSString *puzzleFile = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
        NSMutableArray *lines = [[NSMutableArray alloc] initWithArray:[puzzleFile componentsSeparatedByString:@"\n"]];
        
        NSNumber *difficulty = 0;
        int order = 0;
        SudokuPuzzle *puzzle;
        for (NSString *line in lines) {
            unichar firstChar = [line characterAtIndex:0];
            if ([line length] == 1) {
                difficulty = [NSNumber numberWithInt:(firstChar - 48)];
                continue;
            }
            
            if (puzzle == nil) {
                puzzle = [NSEntityDescription insertNewObjectForEntityForName:@"SudokuPuzzle" inManagedObjectContext:context];
                puzzle.difficulty = difficulty;
                puzzle.default_state = line;
                puzzle.complete = 0;
                puzzle.order = [NSNumber numberWithInt:order];
                order++;
            } else {
                puzzle.completed_state = line;
                
                
                puzzle = nil;
            }
        }
        
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
//        NSError *error = nil;
//        [context save:&error];
        
        //[defaults setBool:YES forKey:@"sudoku_initialized"];
        encryptBoolForKey(@"sudoku_initialized", YES);
       //[defaults setValue:[NSNumber numberWithInt:1] forKey:@"sudoku_version"];
        encryptIntForKey(@"sudoku_version", 1);
    }
}

+ (NSManagedObjectModel *)getObjectModels
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SudokuModel" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

@end
