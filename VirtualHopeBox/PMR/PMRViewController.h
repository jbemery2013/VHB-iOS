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
#import <AVFoundation/AVFoundation.h>
#import "PMRKeyFrame.h"
#import "PMRCaptionKeyFrame.h"
#import "VHBLogUtils.h"
#import "VHBViewUtils.h"

@interface PMRViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *highlightImageView;
@property (strong, nonatomic) IBOutlet UIImageView *bodyImageView;
@property (strong, nonatomic) IBOutlet UIView *bodyContainerView;
@property (strong, nonatomic) IBOutlet UIButton *resumeButton;
@property (strong, nonatomic) IBOutlet UIView *captionContainerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *captionButton;
@property (strong, nonatomic) IBOutlet UILabel *captionLabelView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *contactButton;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) UIColor *captionButtonEnabledColor;
@property (strong, nonatomic) UIColor *captionButtonDisabledColor;
@property (strong, nonatomic) NSArray *keyframes;
@property (strong, nonatomic) NSMutableArray *captions;
@property (strong, nonatomic) NSTimer *playbackTimer;
//@property (strong, nonatomic) NSUserDefaults *defaults;

- (IBAction)captionClicked:(id)sender;
- (IBAction)resumeClicked:(id)sender;

@end
