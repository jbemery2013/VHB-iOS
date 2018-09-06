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
#import <AVFoundation/AVFoundation.h>
#import "GradientLayer.h"
#import "VHBLogUtils.h"

typedef enum _GuidedMeditationType {
    GuidedMeditationTypeBeach,
    GuidedMeditationTypeForest,
    GuidedMeditationTypeRoad,
} GuidedMeditationType;

@interface GuidedMeditationViewController : UIViewController<AVAudioPlayerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *captionView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSTimer *captionTimer;
@property (strong, nonatomic) NSArray *captions;
@property (strong, nonatomic) NSArray *keyframes;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property GuidedMeditationType meditationType;
@property int keyframe;
@property float timer;
@property BOOL started;
@property BOOL paused;
@end
