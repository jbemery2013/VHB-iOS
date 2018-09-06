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

#import "CBViewController.h"
#import "GradientLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "DefaultsWrapper.h"

@interface CBViewController () {
    float sessionDuration, holdDuration, inhaleDuration, exhaleDuration, restDuration, currentDuration;
    int promptGate, countdown;
    int musicResume;
    float barHeight, barTop;
    BOOL sessionEnabled, firstCycle, starting, started, inhaling, paused, pausing, sessionComplete, promptPlaying, backgroundLoaded, backgroundLoading;
}

@end

@implementation CBViewController
@synthesize barView;
@synthesize instructionLabelView;
@synthesize exhaleSegmentView;
@synthesize inhaleSegmentView;
@synthesize backgroundImageView;
@synthesize sessionLabelView;
@synthesize barWrapperView;
@synthesize sessionCompleteLabelView;
@synthesize subInstructionLabelView;
@synthesize contactsButton;
@synthesize settingsButton;
@synthesize managedObjectContext;
@synthesize musicPlayer;
@synthesize promptPlayer;
@synthesize libraryMusicPlayer;
@synthesize overlayView;
@synthesize pauseLabelView;

@synthesize fetchedResultsController;
//@synthesize defaults;
@synthesize assetsLibrary;
@synthesize sessionTimer;
@synthesize startingTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    assetsLibrary = appDelegate.assets;
    managedObjectContext = appDelegate.managedObjectContext;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    if (!TARGET_IPHONE_SIMULATOR) {
        libraryMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    }
    
    [contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:contactsButton, settingsButton, nil] animated:YES];
    
    //defaults = [NSUserDefaults standardUserDefaults];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [self reset];
    
}

- (void)reset
{
    [self updateDurations];
    
    instructionLabelView.outlineColor = [UIColor blackColor];
    instructionLabelView.outlineWidth = 5;
    pauseLabelView.outlineColor = [UIColor blackColor];
    pauseLabelView.outlineWidth = 5;
    sessionCompleteLabelView.outlineColor = [UIColor blackColor];
    sessionCompleteLabelView.outlineWidth = 5;
    sessionLabelView.outlineColor = [UIColor blackColor];
    sessionLabelView.outlineWidth = 5;
    subInstructionLabelView.outlineColor = [UIColor blackColor];
    subInstructionLabelView.outlineWidth = 5;
    
    overlayView.alpha = 0.0;
    pauseLabelView.alpha = 1.0;
    barWrapperView.alpha = 1.0;
    instructionLabelView.alpha = 1.0;
    subInstructionLabelView.alpha = 1.0;
    exhaleSegmentView.alpha = 1.0;
    sessionCompleteLabelView.alpha = 0.0;
    inhaleSegmentView.alpha = 0.0;
    sessionLabelView.alpha = 0.0;
    backgroundImageView.alpha = 0.0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        instructionLabelView.font = [UIFont boldSystemFontOfSize:48];
    } else {
        instructionLabelView.font = [UIFont boldSystemFontOfSize:100];
    }
    
    inhaleSegmentView.lineColor = [UIColor whiteColor];
    inhaleSegmentView.lineMargin = 5;
    [inhaleSegmentView initDuration:inhaleDuration];
    
    exhaleSegmentView.lineColor = [UIColor whiteColor];
    exhaleSegmentView.lineMargin = 5;
    [exhaleSegmentView initDuration:exhaleDuration];
    
    currentDuration = sessionDuration;
    
    [startingTimer invalidate];
    [sessionTimer invalidate];
    
    sessionComplete = NO;
    started = NO;
    starting = NO;
    pausing = NO;
    paused = NO;
    inhaling = NO;
    firstCycle = YES;
    
    if (!TARGET_IPHONE_SIMULATOR) {
        musicResume = 0;
        [musicPlayer stop];
        [libraryMusicPlayer stop];
        [promptPlayer stop];
    }
    
    [barView.layer removeAllAnimations];
    [instructionLabelView.layer removeAllAnimations];
    [inhaleSegmentView.layer removeAllAnimations];
    [exhaleSegmentView.layer removeAllAnimations];
    [backgroundImageView.layer removeAllAnimations];
    
    [self resumeLayer:barView.layer];
    [self resumeLayer:instructionLabelView.layer];
    [self resumeLayer:inhaleSegmentView.layer];
    [self resumeLayer:exhaleSegmentView.layer];
    [self resumeLayer:backgroundImageView.layer];
    
    countdown = 7;
    instructionLabelView.text = @"Ready?";
    instructionLabelView.accessibilityLabel = @"Ready? Double tap to start.";
    
}

- (void)viewWillAppear:(BOOL)animated
{
    backgroundLoaded = NO;
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [super viewWillAppear:animated];
    [self updateDurations];
    
    if (barHeight == 0) {
        barHeight = barView.frame.size.height;
        barTop = barView.frame.origin.y;
    }
    
    CGRect barFrame = barView.frame;
    barFrame.origin.y = barTop;
    barFrame.size.height = barHeight;
    barView.frame = barFrame;

    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];

    [self loadRandomBackground];
    
    if (!decryptBoolForKey(@"cb_settings_prompt_shown")) {
        //[defaults setBool:YES forKey:@"cb_settings_prompt_shown"];
        encryptBoolForKey(@"cb_settings_prompt_shown", YES);
        //[defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Controlled Breathing" message:@"Controlled breathing is a technique that you can use to counteract stress.\n\nTo make this tool more effective, please take a moment to personalize your settings." delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"OK", nil];
        [alert show];
        
    }
}

- (void)updateDurations
{
    inhaleDuration = decryptFloatForKey(@"inhale_duration");
    exhaleDuration = decryptFloatForKey(@"exhale_duration");
    holdDuration = decryptFloatForKey(@"hold_duration");
    restDuration = decryptFloatForKey(@"rest_duration");
    
    sessionEnabled = decryptBoolForKey(@"cb_session_enabled");
    
    sessionDuration = decryptIntForKey(@"session_duration");
    
    if (exhaleSegmentView.duration != exhaleDuration) {
        exhaleSegmentView.duration = exhaleDuration;
    }
    
    if (inhaleSegmentView.duration != inhaleDuration) {
        inhaleSegmentView.duration = inhaleDuration;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, instructionLabelView);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [VHBLogUtils endTimedEvent:LETBreathingClose];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self isMovingFromParentViewController]) {
        NSLog(@"Dismissage");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self reset];
}

- (void)applicationWillBecomeActive:(NSNotification *)note
{
    NSLog(@"Active");
    [self loadRandomBackground];
}

- (void)applicationWillResignActive:(NSNotification *)note
{
    backgroundLoaded = NO;
    [self reset];
    NSLog(@"Resign");
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval paused_time = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = paused_time;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval paused_time = [layer timeOffset];
    layer.speed = 1.0f;
    layer.timeOffset = 0.0f;
    layer.beginTime = 0.0f;
    CFTimeInterval time_since_pause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - paused_time;
    layer.beginTime = time_since_pause;
}

- (void)logStart
{
    [VHBLogUtils logEventType:LETBreathingStart];
    int session = decryptIntForKey(@"session_duration");//[defaults integerForKey:@"session_duration"] / 60;
    if (session > 0) {
        [VHBLogUtils logEventType:LETBreathingSessionDuration withValue:[NSString stringWithFormat:@"%d", session]];
    } else {
        [VHBLogUtils logEventType:LETBreathingSessionDuration withValue:@"Disabled"];
    }
    
    
    [VHBLogUtils logEventType:LETBreathingInhaleDuration withValue:[NSString stringWithFormat:@"%.1d", decryptFloatForKey(@"inhale_duration")]];
    [VHBLogUtils logEventType:LETBreathingExhaleDuration withValue:[NSString stringWithFormat:@"%.1d", decryptFloatForKey(@"exhale_duration")]];
    
    float hold = decryptFloatForKey(@"hold_duration");
    if (hold > 0.01) {
        [VHBLogUtils logEventType:LETBreathingHoldDuration withValue:[NSString stringWithFormat:@"%.01f", hold]];
    } else {
        [VHBLogUtils logEventType:LETBreathingHoldDuration withValue:@"Disabled"];
    }
    
    float rest = decryptFloatForKey(@"rest_duration");
    if (rest > 0.01) {
        [VHBLogUtils logEventType:LETBreathingRestDuration withValue:[NSString stringWithFormat:@"%.01f", rest]];
    } else {
        [VHBLogUtils logEventType:LETBreathingRestDuration withValue:@"Disabled"];
    }
    
    
    kBackgroundType bgType = decryptIntForKey(@"background_type");
    [VHBLogUtils logEventType:LETBreathingBackground withValue:[CBBackgroundType nameForBackgroundType:bgType]];
    
    BOOL prompts = decryptBoolForKey(@"vocal_prompts");
    [VHBLogUtils logEventType:LETBreathingVocalPrompts withValue:prompts ? @"On" : @"Off"];
    
    kMusicType mType = decryptIntForKey(@"music_type");
    [VHBLogUtils logEventType:LETBreathingMusic withValue:[CBMusicType nameForMusicType:mType]];
    [VHBLogUtils startTimedEvent:LETBreathingClose];
}

- (void)loadReminder
{
    int count = (int)self.fetchedResultsController.fetchedObjects.count;
    if (count > 0) {
        VisualReminder *reminder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:arc4random() % count inSection:0]];
        [assetsLibrary assetForURL:[NSURL URLWithString:dRaw(encodeKey, reminder.assetPath)] resultBlock:^(ALAsset *asset) {
            if (asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                
                UIImageOrientation orientation = UIImageOrientationUp;
                NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
                if (orientationValue != nil) {
                    orientation = [orientationValue intValue];
                }
                
                CGImageRef ref = [rep fullResolutionImage];
                if (ref) {
                    UIImage *img = [UIImage imageWithCGImage:ref scale:1 orientation:orientation];
                    [self reminderLoaded:img];
                }
            }
        } failureBlock:^(NSError *myerror) {
            NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
        }];
    }
}

- (void)reminderLoaded:(UIImage *)img
{
    backgroundImageView.image = img;
//    float top = (self.view.frame.size.height - img.size.height) / 2.0;
    //NSLog(@"%@", [NSValue valueWithCGSize:img.size]);
    backgroundImageView.frame = CGRectMake(0, 0, img.size.width, self.view.frame.size.height);
    
    if ((started || starting) && !paused) {
        [self animateBackground];
    } else {
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            backgroundImageView.alpha = 1.0;
        } completion:nil];
    }
    backgroundLoading = NO;
    backgroundLoaded = YES;
}

- (void)loadRandomBackground
{
    backgroundLoading = YES;
    if (decryptIntForKey(@"background_type") == kMyPictures) {
        [self loadReminder];
    } else {
        kBackgroundType bgType = decryptIntForKey(@"background_type");
        NSString *prefix = [CBBackgroundType fileNamePrefixForBackgroundType:bgType];
        int images = [CBBackgroundType imageCountForBackgroundType:bgType];
    
        int rand = (arc4random() % images) + 1;
        NSString *name = [NSString stringWithFormat:@"%@%i", prefix, rand];
    
        UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"jpg"]];
        [self reminderLoaded:img];
    }
}

- (void)changeBackground
{
    if (sessionComplete) {
        return;
    }
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [self loadRandomBackground];
    }];
}

- (void)animateBackground
{
    CGRect frame = backgroundImageView.frame;
    int left = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 420 : 768;
    frame.origin.x = left - frame.size.width;
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        backgroundImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:45 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            backgroundImageView.frame = frame;
        } completion:^(BOOL finished) {
            if (finished) {
                [self changeBackground];
            }
        }];
    }];
}

- (void)pause
{
    if (paused || pausing) {
        return;
    }
    pausing = YES;
    inhaling = false;
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [sessionTimer invalidate];
    [startingTimer invalidate];
    
    if (!TARGET_IPHONE_SIMULATOR) {
        musicResume = musicPlayer.currentTime;
        [musicPlayer stop];
        [libraryMusicPlayer stop];
        [promptPlayer stop];
    }
    
    [self pauseLayer:barView.layer];
    [self pauseLayer:instructionLabelView.layer];
    [self pauseLayer:inhaleSegmentView.layer];
    [self pauseLayer:exhaleSegmentView.layer];
    [self pauseLayer:backgroundImageView.layer];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        overlayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        paused = YES;
        pausing = NO;
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Session Paused. Double tap to resume.");
    }];
    [VHBLogUtils endTimedEvent:LETBreathingClose];
}

- (void)resume
{
    if (!paused) {
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        paused = NO;
        pausing = NO;
    }];
    
    [self resumeLayer:barView.layer];
    [self resumeLayer:instructionLabelView.layer];
    [self resumeLayer:inhaleSegmentView.layer];
    [self resumeLayer:exhaleSegmentView.layer];
    [self resumeLayer:backgroundImageView.layer];
    
    sessionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSessionTimer) userInfo:nil repeats:YES];
    [self resumeMusic];
    
    [self logStart];
}

- (IBAction)settingsClicked:(id)sender
{
    if (!started) {
        [self performSegueWithIdentifier:@"settings" sender:self];
    } else {
        [self pause];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"End Session" message:@"Changing settings will end the current session." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"settings" sender:self];
    }
    
}

- (void)start
{
    [self reset];
    
    starting = YES;
    [UIView animateWithDuration:2 animations:^{
        subInstructionLabelView.alpha = 0;
    }];
    
    [self startMusic];
    
    if (backgroundLoaded) {
        [self animateBackground];
    } else {
        [self changeBackground];
    }
    [self updateCountdown];
}

- (void)updateCountdown
{
    if (!starting) {
        return;
    }
    
    countdown--;
    if (countdown <= 0) {
        return;
    }
    
    switch (countdown) {
        case 6:
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Starting in 4 seconds");
            instructionLabelView.text = @"Alright.";
            break;
        case 5:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                instructionLabelView.font = [UIFont boldSystemFontOfSize:32];
            } else {
                instructionLabelView.font = [UIFont boldSystemFontOfSize:60];
            }
            instructionLabelView.text = @"Take a deep breath!";
            break;
        case 4:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                instructionLabelView.font = [UIFont boldSystemFontOfSize:48];
            } else {
                instructionLabelView.font = [UIFont boldSystemFontOfSize:100];
            }
            instructionLabelView.text = @"3";
            break;
        case 3:
            instructionLabelView.text = @"2";
            break;
        case 2:
            instructionLabelView.text = @"1";
            break;
        case 1:
            instructionLabelView.text = @"Exhale";
            starting = NO;
            started = YES;
            [self logStart];
            [self startCycle];
            break;
        default:
            break;
    }
    startingTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(updateCountdown) userInfo:nil repeats:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (pausing) {
        return;
    }
    
    if (started) {
        if (paused) {
            [self resume];
        } else {
            [self pause];
        }
    } else if (!starting) {
        [self start];
    }
}

- (void)updateSessionTimer
{
    if (!sessionEnabled) {
        return;
    }
    
    currentDuration--;
    if (currentDuration < 1.0) {
        sessionComplete = YES;
        [sessionTimer invalidate];
        [VHBLogUtils endTimedEvent:LETBreathingClose];
    }
    
    int minutes = floor(currentDuration / 60.0);
    int seconds = (int)currentDuration % 60;
    sessionLabelView.text = [NSString stringWithFormat:@"%.02i:%.02i", minutes, seconds];
    sessionLabelView.accessibilityLabel = [NSString stringWithFormat:@"%i minutes %i seconds left to complete exercise", minutes, seconds];
}

- (void)resumeMusic
{
    [musicPlayer setCurrentTime:musicResume];
    [musicPlayer play];
}

- (void)startMusic
{
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    if (paused) {
        return;
    }
    
    kMusicType type = decryptIntForKey(@"music_type");//[defaults integerForKey:@"music_type"];
    NSURL *file;
    
    switch (type) {
        case kNone:
            return;
        case kRandom:
            // Random from indexes 3-7
            file = [CBMusicType pathForMusicType:arc4random() % 5 + 3];
            break;
        case kMyMusic:
            [self startLibraryPlaylist];
            return;
        default:
            file = [CBMusicType pathForMusicType:type];
            break;
    }
    
    [musicPlayer stop];
    musicResume = 0;
    NSError *error;
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return;
    }

    [musicPlayer setDelegate:self];
    [musicPlayer prepareToPlay];
    [musicPlayer setNumberOfLoops:0];
    [musicPlayer play];
}

- (void)startLibraryPlaylist
{
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CBSong" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *artistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:artistDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    
	NSError *error = nil;
	if (![fetch performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    NSMutableArray *songs = [[NSMutableArray alloc] init];
    for (CBSong *song in [fetch fetchedObjects]) {
        NSLog(@"%@", song.title);
        uint64_t mpID = strtoull([song.persistentID UTF8String], NULL, 0);
        MPMediaPredicate *idPredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithUnsignedLongLong:mpID] forProperty:MPMediaItemPropertyPersistentID comparisonType:MPMediaPredicateComparisonEqualTo];
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        [query addFilterPredicate:idPredicate];
        if (query.items.count > 0) {
            [songs addObject:[query.items objectAtIndex:0]];
        }
    }
    
    if (songs.count == 0) {
        return;
    }
    
    MPMediaItemCollection *collection = [MPMediaItemCollection collectionWithItems:songs];
    [libraryMusicPlayer setQueueWithItemCollection:collection];
    [libraryMusicPlayer setShuffleMode:MPMusicShuffleModeSongs];
    [libraryMusicPlayer setRepeatMode:MPMusicRepeatModeAll];
    [libraryMusicPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == musicPlayer) {
        [self startMusic];
    } else if (player == promptPlayer) {
    }
}

- (void)startCycle
{
    
    if (paused || !started) {
        return;
    }
    
    NSLog(@"Cycle Started");
    
    if (sessionComplete) {
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            barWrapperView.alpha = 0;
            instructionLabelView.alpha = 0;
            sessionLabelView.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                sessionCompleteLabelView.alpha = 1.0;
            } completion:^(BOOL finished) {
                UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, sessionCompleteLabelView);
            }];
        }];
        return;
    }
    
    if (firstCycle) {
        if (sessionDuration > 0) {
            currentDuration = sessionDuration;
            [self updateSessionTimer];
            [UIView animateWithDuration:1 animations:^{
                sessionLabelView.alpha = 1.0;
            }];
            sessionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSessionTimer) userInfo:nil repeats:YES];
        }
        

    }
    
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    
    if (!firstCycle) {
        [self holdStart];
    } else {
        [self exhaleStart];
    }
    [UIView animateWithDuration:exhaleDuration delay:(firstCycle ? 0.0 : holdDuration) options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        CGRect barFrame = barView.frame;
        barFrame.origin.y = barHeight + barTop;
        barFrame.size.height = 2;
        barView.frame = barFrame;
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        
        [UIView animateWithDuration:inhaleDuration delay:restDuration options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            CGRect barFrame = barView.frame;
            barFrame.origin.y = barTop;
            barFrame.size.height = barHeight;
            barView.frame = barFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                return;
            }
            
            [self startCycle];
        }];
    }];
    firstCycle = NO;
}

- (void)restStart
{
    if (![self restEnabled]) {
        [self inhaleStart];
        return;
    }
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Rest");
    
    NSLog(@"%@ %f", @"Rest Started - ", restDuration);
    // Slowly fades out the rest message using 80% of the duration
    [UIView animateWithDuration:restDuration*0.8 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        instructionLabelView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        instructionLabelView.text = @"Inhale";
        // Rapidly fades in the upcoming inhale message using 20% of the duration
        [UIView animateWithDuration:restDuration*0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            instructionLabelView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (!finished) {
                return;
            }
            [self restComplete];
            [self inhaleStart];
        }];
    }];
    [self requestVocalPrompt:kMiscPrompt];
}

- (void)restComplete
{
    NSLog(@"%@", @"Rest Complete");
}

- (void)holdStart
{
    if (holdDuration < .01) {
        [self exhaleStart];
        return;
    }
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Hold");
    
    NSLog(@"%@ %f", @"Hold Started - ", holdDuration);
    [UIView animateWithDuration:holdDuration*0.8 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        instructionLabelView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        instructionLabelView.text = @"Exhale";
        [UIView animateWithDuration:holdDuration*0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            instructionLabelView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (!finished) {
                return;
            }
            [self holdComplete];
            [self exhaleStart];
        }];
    }];
    [self requestVocalPrompt:kMiscPrompt];
}

- (void)holdComplete
{
    NSLog(@"%@", @"Hold Complete");
}

- (BOOL)restEnabled
{
    return restDuration >= 0.1;
}

- (BOOL)holdEnabled
{
    return holdDuration >= 0.1;
}

- (void)exhaleStart
{
    NSLog(@"%@ %f", @"Exhale Started - ", exhaleDuration);
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Exhale");
    
    inhaling = NO;
    NSString *nextLabel = @"Rest";
    if (![self restEnabled]) {
        nextLabel = @"Inhale";
    }
    
    
    [UIView animateWithDuration:exhaleDuration*0.8 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        instructionLabelView.alpha = 0.0;
        exhaleSegmentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        instructionLabelView.text = nextLabel;
        [UIView animateWithDuration:exhaleDuration*0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                instructionLabelView.alpha = 1.0;
                inhaleSegmentView.alpha = 1.0;
            } completion:^(BOOL finished) {
                if (!finished) {
                    return;
                }
                [self exhaleComplete];
            }];
    }];
    [self requestVocalPrompt:kExhalePrompt];
}

- (void)exhaleComplete
{
    NSLog(@"%@", @"Exhale Complete");
    if ([self restEnabled]) {
        [self restStart];
    } else {
        [self inhaleStart];
    }
}

- (void)inhaleStart
{
    NSLog(@"%@ %f", @"Inhale Started - ", inhaleDuration);
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Inhale");
    
    inhaling = YES;
    NSString *nextLabel = @"Hold";
    if (![self holdEnabled]) {
        nextLabel = @"Exhale";
    }
    
    [UIView animateWithDuration:inhaleDuration*0.8 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        instructionLabelView.alpha = 0.0;
        inhaleSegmentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (!finished) {
            return;
        }
        instructionLabelView.text = nextLabel;
        [UIView animateWithDuration:inhaleDuration*0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            instructionLabelView.alpha = 1.0;
            exhaleSegmentView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (!finished) {
                return;
            }
            [self inhaleComplete];
        }];
    }];
    [self requestVocalPrompt:kInhalePrompt];
}

- (void)inhaleComplete
{
    NSLog(@"%@", @"Inhale Complete");
}

- (void)viewDidUnload
{
    [self setBarView:nil];
    [self setInstructionLabelView:nil];
    [self setExhaleSegmentView:nil];
    [self setInhaleSegmentView:nil];
    [self setBackgroundImageView:nil];
    
    [self setDefaults:nil];
    [self setFetchedResultsController:nil];
    [self setAssetsLibrary:nil];
    [self setSessionTimer:nil];
    
    [self setMusicPlayer:nil];
    [self setPromptPlayer:nil];
    [self setLibraryMusicPlayer:nil];

    [self setSessionLabelView:nil];
    [self setBarWrapperView:nil];
    [self setSessionCompleteLabelView:nil];
    [self setContactsButton:nil];
    [self setSettingsButton:nil];
    [self setSubInstructionLabelView:nil];
    
    [self setOverlayView:nil];
    [self setPauseLabelView:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)requestVocalPrompt:(kVocalPromptType)type
{
    if (TARGET_IPHONE_SIMULATOR) {
        return;
    }
    
    if (paused) {
        return;
    }
    
    promptGate++;
    
    int gate = UIAccessibilityIsVoiceOverRunning() ? 4 : 5;
    
    if (!decryptBoolForKey(@"vocal_prompts") || promptGate % gate != 0) {
        return;
    }
    
    promptGate = 0;
    
    NSString *filePrefix;
    int fileCount;
    
    switch (type) {
        case kInhalePrompt:
            filePrefix = @"breathing_inhale_";
            fileCount = 4;
            break;
        case kExhalePrompt:
            filePrefix = @"breathing_exhale_";
            fileCount = 4;
            break;
        case kMiscPrompt:
            filePrefix = @"breathing_misc_";
            fileCount = 8;
            break;
        default:
            break;
    }
    
    [promptPlayer stop];
    
    int rand = (arc4random() % fileCount) + 1;
    NSString *file = [NSString stringWithFormat:@"%@%i", filePrefix, rand];
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:file ofType:@"mp3"]]; 
    NSError *error;
    
    promptPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    [promptPlayer setDelegate:self];
    [promptPlayer prepareToPlay];
    [promptPlayer setNumberOfLoops:0];
    [promptPlayer play];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    //NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetType == %@", @"IMAGE"];
    [fetchRequest setPredicate:predicate];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    //[fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];

    fetchedResultsController = aFetchedResultsController;
    
    return fetchedResultsController;
}


- (IBAction)plusClicked:(id)sender {
    if (inhaling) {
        inhaleDuration += 0.2;
        inhaleSegmentView.duration = inhaleDuration;
    } else {
        exhaleDuration += 0.2;
        exhaleSegmentView.duration = exhaleDuration;
    }
    
    //[defaults setFloat:inhaleDuration forKey:@"inhale_duration"];
    encryptFloatForKey(@"inhale_duration", inhaleDuration);
    //[defaults setFloat:exhaleDuration forKey:@"exhale_duration"];
    encryptFloatForKey(@"exhale_duration", exhaleDuration);
    //[defaults synchronize];
}

- (IBAction)minusClicked:(id)sender {
    if (inhaling) {
        inhaleDuration -= 0.2;
        inhaleSegmentView.duration = inhaleDuration;
    } else {
        exhaleDuration -= 0.2;
        exhaleSegmentView.duration = exhaleDuration;
    }
    
    //[defaults setFloat:inhaleDuration forKey:@"inhale_duration"];
    encryptFloatForKey(@"inhale_duration", inhaleDuration);
    //[defaults setFloat:exhaleDuration forKey:@"exhale_duration"];
    encryptFloatForKey(@"exhale_duration", exhaleDuration);
    //[defaults synchronize];
}
@end
