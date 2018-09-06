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
#import <QuartzCore/QuartzCore.h>
#import "NSOutlinedLabel.h"
#import <CoreData/CoreData.h>
#import "VisualReminder.h"
#import "VHBAppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "VHBQuotesPageViewController.h"

@interface VHBHomeViewController : UIViewController <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contactButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBarItem;
@property (weak, nonatomic) IBOutlet UIImageView *reminderOneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *reminderTwoImageView;
@property (weak, nonatomic) IBOutlet NSOutlinedLabel *remindLabel;
@property (weak, nonatomic) IBOutlet UIView *reminderWrapperView;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (weak, nonatomic) IBOutlet UIButton *distractButton;
@property (weak, nonatomic) IBOutlet UIButton *inspireButton;
@property (weak, nonatomic) IBOutlet UIButton *relaxButton;
@property (weak, nonatomic) IBOutlet UIButton *copingButton;
@property (weak, nonatomic) IBOutlet NSOutlinedLabel *distractLabel;
@property (weak, nonatomic) IBOutlet NSOutlinedLabel *relaxLabel;
@property (weak, nonatomic) IBOutlet NSOutlinedLabel *inspireLabel;
@property (weak, nonatomic) IBOutlet NSOutlinedLabel *copingLabel;


@property (strong, nonatomic) NSTimer *reminderTimer;
@end
