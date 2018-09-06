﻿//
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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CBDurationSegmentView.h"
#import "CBBackgroundType.h"
#import "CBMusicType.h"
#import "VHBAppDelegate.h"
#import "NSOutlinedLabel.h"
#import "VisualReminder.h"
#import "CBSong.h"
#import "VHBLogUtils.h"

typedef enum {
    kInhalePrompt,
    kExhalePrompt,
    kMiscPrompt
} kVocalPromptType;

@interface CBViewController : UIViewController <AVAudioPlayerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *barView;
@property (strong, nonatomic) IBOutlet NSOutlinedLabel *instructionLabelView;
@property (strong, nonatomic) IBOutlet CBDurationSegmentView *exhaleSegmentView;
@property (strong, nonatomic) IBOutlet CBDurationSegmentView *inhaleSegmentView;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet NSOutlinedLabel *sessionLabelView;
@property (strong, nonatomic) IBOutlet UIView *barWrapperView;
@property (strong, nonatomic) IBOutlet NSOutlinedLabel *sessionCompleteLabelView;
@property (strong, nonatomic) IBOutlet NSOutlinedLabel *subInstructionLabelView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *contactsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (strong, nonatomic) IBOutlet NSOutlinedLabel *pauseLabelView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSTimer *sessionTimer;
@property (strong, nonatomic) NSTimer *startingTimer;

@property (weak, nonatomic) MPMusicPlayerController *libraryMusicPlayer;
@property (strong, nonatomic) AVAudioPlayer *musicPlayer;
@property (strong, nonatomic) AVAudioPlayer *promptPlayer;

@property (weak, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)plusClicked:(id)sender;
- (IBAction)minusClicked:(id)sender;


@end
