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

#import "MahjongAppDelegate.h"
#import "MahjongPuzzle.h"
#import "MahjongLayout.h"
#import "DefaultsWrapper.h"

@implementation MahjongAppDelegate
+ (void)initDataWithContext:(NSManagedObjectContext *)context defaults:(NSUserDefaults *)defaultsold
{
    if (!decryptBoolForKey(@"mahjong_initialized")) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"mahjong_puzzles" ofType:@"txt"];
        NSString *puzzleFile = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
        NSMutableArray *lines = [[NSMutableArray alloc] initWithArray:[puzzleFile componentsSeparatedByString:@"\n"]];
        
        MahjongPuzzle *puzzle;
        MahjongLayout *layout;
//        NSError *error;
        NSMutableDictionary *counts = [[NSMutableDictionary alloc] init];
        
        for (NSString *line in lines) {
            if ([line hasPrefix:@"LAYOUT"]) {
                layout = [NSEntityDescription insertNewObjectForEntityForName:@"MahjongLayout" inManagedObjectContext:context];
                
                int firstPipe = (int)[line rangeOfString:@"|" options:NSCaseInsensitiveSearch range:NSMakeRange(7, [line length] - 7)].location;
                NSString *tiles = [line substringFromIndex :firstPipe+1];
                NSString *title = [line substringWithRange :NSMakeRange(7, firstPipe-7)];
                
                layout.title = title;
                layout.layout = tiles;
            } else {
                puzzle = [NSEntityDescription insertNewObjectForEntityForName:@"MahjongPuzzle" inManagedObjectContext:context];
                
                int firstPipe = (int)[line rangeOfString:@"|"].location;
                
                NSString *title = [line substringToIndex :firstPipe];
                layout = [MahjongAppDelegate selectLayoutWithTitle:title context:context];
                if (layout == nil) {
                    continue;
                }
                
                unichar difficulty = [line characterAtIndex:firstPipe+1];
                NSString *tiles = [line substringFromIndex:firstPipe+3];
                puzzle.layout = layout;
                puzzle.difficulty = [NSNumber numberWithInt:(difficulty - 48)];
                puzzle.default_state = tiles;
                
                int count = 0;
                NSString *key = [NSString stringWithFormat:@"%@%i", title, difficulty];
                if ([counts objectForKey:key]) {
                    count = [[counts objectForKey:key] intValue];
                }
                [counts setObject:[NSNumber numberWithInt:count+1] forKey:key];
                puzzle.order = [NSNumber numberWithInt:count];
                
                
            }
        }
        
        
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
//        [context save:&error];
        
        //[defaults setObject:@"Slats" forKey:@"mahjong_background"];
        encryptStringForKey(@"mahjong_background", @"Slats");
        encryptBoolForKey(@"mahjong_initialized", YES);
        encryptIntForKey(@"mahjong_version", 1);
    }
}

+ (NSManagedObjectModel *)getObjectModels
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MahjongModel" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

+ (MahjongLayout *)selectLayoutWithTitle:(NSString *)title context:(NSManagedObjectContext *)context
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"MahjongLayout" inManagedObjectContext:context];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"title ==[c] %@", title]];
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array != nil && [array count] > 0) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}


@end
