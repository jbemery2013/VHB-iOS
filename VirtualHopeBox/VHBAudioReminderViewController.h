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

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "VHBAppDelegate.h"
#import "AudioReminder.h"
#import "MBProgressHUD.h"
#import "VHBAudioPlayerView.h"
#import "VHBAudioRecorderView.h"
#import "VHBLogUtils.h"

@protocol VHBAudioReminderTableDelegate <NSObject>

- (void)tableLoaded;
- (void)rowsChanged;

@end

@interface VHBAudioReminderViewController : UIViewController <UIActionSheetDelegate, MPMediaPickerControllerDelegate, NSFetchedResultsControllerDelegate, AVAudioSessionDelegate, VHBAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *helpView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIActionSheet *addMediaActionSheet, *longTapActionSheet, *recordingActionSheet;
@property (strong, nonatomic) MPMediaPickerController *musicPickerController;
@property (strong, nonatomic) MPMediaPickerController *recordingPickerController;

@property (strong, nonatomic) UILongPressGestureRecognizer *longTapGestureRecognizer;
@property (strong, nonatomic) AudioReminder *longTapReminder;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UIImage *musicBadge, *messageBadge;
@property (strong, nonatomic) IBOutlet VHBAudioRecorderView *recorderView;
@property (strong, nonatomic) IBOutlet VHBAudioPlayerView *recordingPlayerView;

@property (strong, nonatomic) NSURL *currentRecordingURL;

@property (weak, nonatomic) id <VHBAudioReminderTableDelegate> delegate;

- (void)reloadData;
- (IBAction)menuClicked:(id)sender;

@end
