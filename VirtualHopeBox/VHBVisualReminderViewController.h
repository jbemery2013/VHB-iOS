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
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "VHBAppDelegate.h"
#import "VisualReminder.h"
#import "VHBReminderView.h"
#import "MBProgressHUD.h"
#import "VHBYouTubeViewController.h"
#import "VHBYouTubePlayController.h"
#import "VHBLogUtils.h"
#import "QBImagePickerController.h"

@protocol UIImageLoadedDelegate <NSObject>
@optional
-(void)imageLoaded:(UIImage *)img;
@end

@interface VHBVisualReminderViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate, QBImagePickerControllerDelegate, UIImageLoadedDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, VHBYouTubeDelegate>

@property (strong, nonatomic) IBOutlet UIView *helpView;
@property (weak, nonatomic) IBOutlet UIScrollView *galleryScrollView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (strong, nonatomic) UISwipeGestureRecognizer *rightSwipeRecognizer;

@property (strong, nonatomic) UIActionSheet *longTapActionSheet, *addMediaActionSheet, *photoActionSheet, *videoActionSheet;
@property (strong, nonatomic) VHBReminderView *selectedView;
@property (strong, nonatomic) QBImagePickerController *imagePickerController, *videoPickerController;
@property (strong, nonatomic) UIImagePickerController *photoCaptureController, *videoCaptureController;
@property (strong, nonatomic) NSMutableDictionary *assetViewDict;


@property (strong, nonatomic) UIPopoverController *popoverController;

typedef void (^ALAssetsLibraryAssetForURLResultBlock)(ALAsset *asset);
typedef void (^ALAssetsLibraryAccessFailureBlock)(NSError *error);

- (IBAction)menuClicked:(id)sender;
- (IBAction)playClicked:(id)sender;

@end