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

#import "VHBLogUtils.h"

@implementation VHBLogUtils

static NSMutableDictionary *timedEventDict;

+ (void)clearTimedEvents
{
    [timedEventDict removeAllObjects];
}

+ (void)startTimedEvent:(LogEntryType)type
{
    if (!timedEventDict) {
        timedEventDict = [[NSMutableDictionary alloc] init];
    }
    
    [timedEventDict setValue:[NSDate date] forKey:[NSString stringWithFormat:@"%d", type]];
}

+ (void)endTimedEvent:(LogEntryType)type
{
    NSString *key = [NSString stringWithFormat:@"%d", type];
    NSDate *start = [timedEventDict valueForKey:key];
    
    if (!start) {
        return;
    }
    
    [timedEventDict removeObjectForKey:key];
    int seconds = [[NSDate date] timeIntervalSinceDate:start];
    [self logEventType:type withValue:[NSString stringWithFormat:@"%d", seconds]];
}

+ (void)logEventType:(LogEntryType)type
{
    [VHBLogUtils logEventType:type withValue:nil];
}

+ (void)logEventType:(LogEntryType)type withValue:(NSString *)value
{
    NSString *view;
    NSString *item;
    NSString *action;
    
    switch (type) {
        case LETHomeOpen:
            view = @"Home Page";
            action = @"Open";
            break;
            
        case LETHomeClose:
            view = @"Home Page";
            action = @"Close With Duration";
            break;
            
        case LETRemindOpen:
            view = @"Remind Me";
            action = @"Open";
            break;
            
        case LETRemindClose:
            view = @"Remind Me";
            action = @"Close With Duration";
            break;
            
        case LETRemindAdd:
            view = @"Remind Me";
            item = @"Add Media";
            action = @"Clicked";
            break;
            
        case LETRemindCapture:
            view = @"Remind Me";
            item = @"Capture Media";
            action = @"Clicked";
            break;
            
        case LETRemindRemove:
            view = @"Remind Me";
            item = @"Remove Media";
            action = @"Clicked";
            break;
            
        case LETSudokuOpen:
            view = @"Sudoku";
            action = @"Open";
            break;
            
        case LETSudokuClose:
            view = @"Sudoku";
            action = @"Close With Duration";
            break;
            
        case LETSudokuCompleted:
            view = @"Sudoku";
            item = @"Puzzle";
            action = @"Completed";
            break;
            
        case LETPhotoPuzzleOpen:
            view = @"Photo Puzzle";
            action = @"Open";
            break;
            
        case LETPhotoPuzzleClose:
            view = @"Photo Puzzle";
            action = @"Close With Duration";
            break;
            
        case LETPhotoPuzzleCompleted:
            view = @"Photo Puzzle";
            item = @"Puzzle";
            action = @"Completed";
            break;
            
        case LETWordsearchOpen:
            view = @"Word Search";
            action = @"Open";
            break;
            
        case LETWordsearchClose:
            view = @"Word Search";
            action = @"Close With Duration";
            break;
            
        case LETWordsearchCompleted:
            view = @"Word Search";
            item = @"Puzzle";
            action = @"Completed";
            break;
            
        case LETMahjongOpen:
            view = @"Mahjong";
            action = @"Open";
            break;
            
        case LETMahjongClose:
            view = @"Mahjong";
            action = @"Close With Duration";
            break;
            
        case LETMahjongCompleted:
            view = @"Mahjong";
            item = @"Puzzle";
            action = @"Completed";
            break;
            
        case LETForestImageryPlay:
            view = @"Guided Imagery Forest";
            item = @"Play";
            action = @"Clicked";
            break;
            
        case LETForestImageryClose:
            view = @"Guided Imagery Forest";
            action = @"Close With Duration";
            break;
            
        case LETRoadImageryPlay:
            view = @"Guided Imagery Road";
            item = @"Play";
            action = @"Clicked";
            break;
            
        case LETRoadImageryClose:
            view = @"Guided Imagery Road";
            action = @"Close With Duration";
            break;
            
        case LETBeachImageryPlay:
            view = @"Guided Imagery Beach";
            item = @"Play";
            action = @"Clicked";
            break;
            
        case LETBeachImageryClose:
            view = @"Guided Imagery Beach";
            action = @"Close With Duration";
            break;
            
        case LETBackupCreate:
            view = @"Backup";
            item = @"Create";
            action = @"Clicked";
            break;
            
        case LETBackupRestore:
            view = @"Backup";
            item = @"Restore";
            action = @"Clicked";
            break;
            
        case LETContactsOpen:
            view = @"Support Contacts";
            action = @"Open";
            break;
            
        case LETContactsClose:
            view = @"Support Contacts";
            action = @"Close With Duration";
            break;
            
        case LETContactsAdd:
            view = @"Support Contacts";
            item = @"Add Contact";
            action = @"Clicked";
            break;
            
        case LETContactsRemove:
            view = @"Support Contacts";
            item = @"Removed Contact";
            action = @"Clicked";
            break;
            
        case LETContactsDial:
            view = @"Support Contacts";
            item = @"Dial Contact";
            action = @"Clicked";
            break;
            
        case LETContactsHotline:
            view = @"Support Contacts";
            item = @"Emergency Hotline";
            action = @"Clicked";
            break;
            
        case LETEmergencyHotlineDial:
            view = @"Emergency Hotline";
            item = @"Call";
            action = @"Clicked";
            break;
            
        case LETProgressiveStart:
            view = @"Muscle Relaxation";
            item = @"Tap to Start";
            action = @"Clicked";
            break;
            
        case LETProgressiveClose:
            view = @"Muscle Relaxation";
            action = @"Close With Duration";
            break;
            
        case LETProgressiveCaptionsEnabled:
            view = @"Muscle Relaxation";
            item = @"Enable Captions";
            action = @"Clicked";
            break;
            
        case LETProgressiveCaptionsDisabled:
            view = @"Muscle Relaxation";
            item = @"Disable Captions";
            action = @"Clicked";
            break;
            
        case LETBreathingStart:
            view = @"Controlled Breathing";
            item = @"Tap to Start";
            action = @"Clicked";
            break;
            
        case LETBreathingClose:
            view = @"Controlled Breathing";
            action = @"Close With Duration";
            break;
            
        case LETBreathingSessionDuration:
            view = @"Controlled Breathing";
            item = @"Session Duration";
            action = @"Selected";
            break;
            
        case LETBreathingInhaleDuration:
            view = @"Controlled Breathing";
            item = @"Inhale Duration";
            action = @"Selected";
            break;
            
        case LETBreathingExhaleDuration:
            view = @"Controlled Breathing";
            item = @"Exhale Duration";
            action = @"Selected";
            break;
            
        case LETBreathingHoldDuration:
            view = @"Controlled Breathing";
            item = @"Hold Duration";
            action = @"Selected";
            break;
            
        case LETBreathingRestDuration:
            view = @"Controlled Breathing";
            item = @"Rest Duration";
            action = @"Selected";
            break;
            
        case LETBreathingBackground:
            view = @"Controlled Breathing";
            item = @"Background";
            action = @"Selected";
            break;
            
        case LETBreathingVocalPrompts:
            view = @"Controlled Breathing";
            item = @"Vocal Prompts";
            action = @"Selected";
            break;
            
        case LETBreathingMusic:
            view = @"Controlled Breathing";
            item = @"Music";
            action = @"Selected";
            break;
            
        case LETQuotesOpen:
            view = @"Inspire Me";
            action = @"Open";
            break;
            
        case LETQuotesClose:
            view = @"Inspire Me";
            action = @"Close With Duration";
            break;
            
        case LETQuotesAdd:
            view = @"Inspire Me";
            item = @"Add Quote";
            action = @"Clicked";
            break;
            
        case LETQuotesEdit:
            view = @"Inspire Me";
            item = @"Edit Quote";
            action = @"Clicked";
            break;
            
        case LETQuotesRemove:
            view = @"Inspire Me";
            item = @"Remove Quote";
            action = @"Clicked";
            break;
            
        case LETQuotesSlideshowDelay:
            view = @"Inspire Me";
            item = @"Slideshow Delay";
            action = @"Selected";
            break;
            
        case LETQuotesReminderToggle:
            view = @"Inspire Me";
            item = @"Daily Reminder";
            action = @"Toggle";
            break;
            
        case LETQuotesReminderTime:
            view = @"Inspire Me";
            item = @"Daily Reminder";
            action = @"Selected";
            break;
            
        case LETCardsOpen:
            view = @"Coping Cards";
            action = @"Open";
            break;
            
        case LETCardsClose:
            view = @"Coping Cards";
            action = @"Close With Duration";
            break;
            
        case LETCardsAdd:
            view = @"Coping Cards";
            item = @"Add Card";
            action = @"Clicked";
            break;
            
        case LETCardsEdit:
            view = @"Coping Cards";
            item = @"Edit Card";
            action = @"Clicked";
            break;
            
        case LETCardsRemove:
            view = @"Coping Cards";
            item = @"Delete Card";
            action = @"Clicked";
            break;
            
        case LETPlannerCalendar:
            view = @"Activity Planner";
            item = @"Add to Calendar";
            action = @"Clicked";
            break;
            
        case LETPlannerSendEmail:
            view = @"Activity Planner";
            item = @"Send Email";
            action = @"Clicked";
            break;
            
        case LETPlannerSMS:
            view = @"Activity Planner";
            item = @"Text Messaging";
            action = @"Clicked";
            break;
            
        case LETSettingsFeedback:
            view = @"Settings";
            item = @"Feedback";
            action = @"Clicked";
            break;
            
        case LETSettingsRate:
            view = @"Settings";
            item = @"Rate Application";
            action = @"Clicked";
            break;
            
        case LETAboutOpen:
            view = @"About Us";
            action = @"Open";
            break;
        default:
            NSLog(@"Unknown Event Type: %i", type);
            return;
    }
    
    [ResearchUtility logEvent:view withItem:item withAction:action withValue:value];
}

@end
