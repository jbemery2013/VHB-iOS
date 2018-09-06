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

#import <Foundation/Foundation.h>
#import "VHBLogUtils.h"
#import "LogEntry.h"
#import "ResearchUtility.h"
#import "VHBAppDelegate.h"

@interface VHBLogUtils : NSObject

typedef enum _LogEntryType {
    LETHomeOpen = 1,
    LETHomeClose,
    LETRemindOpen,
    LETRemindClose,
    LETRemindAdd,
    LETRemindCapture,
    LETRemindRemove,
    LETSudokuOpen,
    LETSudokuClose,
    LETSudokuCompleted,
    LETPhotoPuzzleOpen,
    LETPhotoPuzzleClose,
    LETPhotoPuzzleCompleted,
    LETWordsearchOpen,
    LETWordsearchClose,
    LETWordsearchCompleted,
    LETMahjongOpen,
    LETMahjongClose,
    LETMahjongCompleted,
    LETForestImageryPlay,
    LETForestImageryClose,
    LETRoadImageryPlay,
    LETRoadImageryClose,
    LETBeachImageryPlay,
    LETBeachImageryClose,
    LETBackupCreate,
    LETBackupRestore,
    LETContactsOpen,
    LETContactsClose,
    LETContactsAdd,
    LETContactsRemove,
    LETContactsDial,
    LETContactsHotline,
    LETEmergencyHotlineDial,
    LETProgressiveStart,
    LETProgressiveClose,
    LETProgressiveCaptionsEnabled,
    LETProgressiveCaptionsDisabled,
    LETBreathingStart,
    LETBreathingClose,
    LETBreathingSessionDuration,
    LETBreathingInhaleDuration,
    LETBreathingExhaleDuration,
    LETBreathingHoldDuration,
    LETBreathingRestDuration,
    LETBreathingBackground,
    LETBreathingVocalPrompts,
    LETBreathingMusic,
    LETQuotesOpen,
    LETQuotesClose,
    LETQuotesAdd,
    LETQuotesEdit,
    LETQuotesRemove,
    LETQuotesSlideshowDelay,
    LETQuotesReminderToggle,
    LETQuotesReminderTime,
    LETCardsOpen,
    LETCardsClose,
    LETCardsAdd,
    LETCardsEdit,
    LETCardsRemove,
    LETPlannerCalendar,
    LETPlannerSendEmail,
    LETPlannerSMS,
    LETSettingsFeedback,
    LETSettingsRate,
    LETAboutOpen
} LogEntryType;

+ (void)startTimedEvent:(LogEntryType)type;

+ (void)endTimedEvent:(LogEntryType)type;

+ (void)logEventType:(LogEntryType)type;

+ (void)logEventType:(LogEntryType)type withValue:(NSString *)value;

+ (void)clearTimedEvents;

@end
