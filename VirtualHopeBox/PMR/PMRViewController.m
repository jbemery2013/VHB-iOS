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

#import "PMRViewController.h"
#import "GradientLayer.h"
#import "MBProgressHUD.h"
#import "DefaultsWrapper.h"

@interface PMRViewController () {
    kBodyPart highlightedPart;
    float focusDuration;
    float unfocusDuration;
    float captionShowDuration;
    float captionHideDuration;
    BOOL paused;
    float timer;
}

@end

@implementation PMRViewController
@synthesize highlightImageView;
@synthesize bodyImageView;
@synthesize bodyContainerView;
@synthesize resumeButton;
@synthesize captionContainerView;
@synthesize audioPlayer;
@synthesize captionButton;
@synthesize captionLabelView;
@synthesize contactButton;
@synthesize captionButtonEnabledColor;
@synthesize captionButtonDisabledColor;
@synthesize keyframes;
@synthesize captions;
@synthesize playbackTimer;
//@synthesize defaults;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:contactButton, captionButton, nil] animated:YES];
    
    focusDuration = 8;
    unfocusDuration = 5;
    
    captionShowDuration = .5;
    captionHideDuration = .5;
    
    //defaults = [NSUserDefaults standardUserDefaults];
    
    keyframes = [NSArray arrayWithObjects:
                 [[PMRKeyFrame alloc] initWithBodyPart:kArms startTime:62 endTime:102],
                 [[PMRKeyFrame alloc] initWithBodyPart:kHead startTime:115 endTime:175],
                 [[PMRKeyFrame alloc] initWithBodyPart:kShoulders startTime:184 endTime:236],
                 [[PMRKeyFrame alloc] initWithBodyPart:kStomach startTime:245 endTime:282],
                 [[PMRKeyFrame alloc] initWithBodyPart:kButt startTime:297 endTime:337],
                 [[PMRKeyFrame alloc] initWithBodyPart:kFeet startTime:357 endTime:411],
                 [[PMRKeyFrame alloc] initWithBodyPart:kBody startTime:458 endTime:535],
                 nil];
    
    captions = [NSMutableArray arrayWithObjects:
                [[PMRCaptionKeyFrame alloc] initWithString:@"Please note that if you have injuries such as back pain or a knee injury, you should avoid tensing muscles that might affect that injury." startTime:1 endTime:9],
                [[PMRCaptionKeyFrame alloc] initWithString:@"To begin, close  your eyes, and take a deep breath into your belly." startTime:10 endTime:13],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Then exhale with a sigh." startTime:14 endTime:16],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Again, take a deep breath, and imagine clean air going down your throat, and filling your lungs, and then exhale with a sigh." startTime:17 endTime:26],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Take another deep breath, and, as you release it, think the word \"Relax\", silently to yourself." startTime:27 endTime:34],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Allow your breath to be slow and rhythmic, inhaling and exhaling at a pace that is comfortable for you." startTime:35 endTime:41],
                [[PMRCaptionKeyFrame alloc] initWithString:@"As you continue to breathe, continue to say the word \"Relax\" to yourself, slowly and calmly, each time you breathe out." startTime:42 endTime:51],
                [[PMRCaptionKeyFrame alloc] initWithString:@"As you do this, imagine that the tension throughout your body begins to melt away." startTime:52 endTime:57],
                [[PMRCaptionKeyFrame alloc] initWithString:@"To begin, clench both of your fists, and bend your elbows, drawing your forearms and hands up towards your shoulders, tightening your biceps to do so." startTime:59 endTime:68],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Hold the muscles in your hands and arms tight, and notice the sensations of pulling, discomfort, and tightness." startTime:69 endTime:76],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Hold the tension, while you take a deep breath into your belly, and then slowly exhale, as you release the muscles of your hands and arms." startTime:77 endTime:85],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Let your hands and fingers relax completely, and let your arms become limp at your side or in your lap." startTime:86 endTime:92],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel the sensation of relaxation, as the tension drains away from your arms and hands, and allow the muscles to become looser and looser." startTime:93 endTime:101],
                [[PMRCaptionKeyFrame alloc] initWithString:@"You may notice that they feel lighter and warmer." startTime:102 endTime:106],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Breathing in slowly, and out, thinking the word \"Relax\" each time you breathe out." startTime:107 endTime:113],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Now bring your attention to your face, and tighten your forehead, the muscles around your eyes and your jaw, by squeezing your eyes tight, clenching your jaw, and wrinkling your forehead and nose." startTime:115 endTime:128],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel the wrinkling and pulling sensations across the forehead and the top of your head." startTime:129 endTime:134],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel the tightness around your eyes and cheeks, and the tension in your jaw." startTime:135 endTime:138],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Hold that tension, and take a deep breath into your belly, and then slowly exhale, as you let your face relax completely." startTime:139 endTime:149],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel the muscles in your forehead becoming smooth and limp, the muscles of your cheeks and eyes softening, your jaw relaxing, let your lips part slightly, and let your jaw hang loose." startTime:150 endTime:164],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Notice the tension melting away; feel your muscles becoming softer, more relaxed, and feel the warmth and lightness that replaces the tension that was there before." startTime:166 endTime:175],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Contine to breathe slowly and gently, thinking the word \"relax\" each time you exhale." startTime:177 endTime:184],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Tighten your shoulders by raising them up as if you were going to touch them to your ears, tensing without straining. " startTime:188 endTime:193],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel the tension in your shoulders radiating down into your back and up into your neck and the top of your back. Hold that. Notice those sensations and take a deep breathe into your belly, and then slowly exhale as you relax your shoulders. " startTime:195 endTime:211],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Let your shoulders droop down and let your neck relax completely, feeling very relaxed" startTime:211 endTime:217],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Notice the contrast between the tightness you felt and the relaxation you feel now. " startTime:218 endTime:223],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Let your head relax, as if there's nothing holding it, except the support behind it. Feel the sense of relaxation around your neck and shoulders as you let the tension drain away" startTime:224 endTime:235],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Continue to breathe slowly and deeply." startTime:236 endTime:239],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Now bring your attention to your stomach." startTime:242 endTime:245],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Tighten the muscles of your stomach by pulling your belly in towards your spine tightly." startTime:245 endTime:251],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Hold that pose." startTime:252 endTime:253],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel the sensation of the tension. Hold it while you are taking a deep breath, and then slowly exhale as you relax your muscles." startTime:255 endTime:263],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Imagine a wave of relaxtion spreading through your belly. Allow the muscles of your stomach to be soft and relaxed, letting go more and more." startTime:264 endTime:274],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Notice the difference the tension you felt, and the relaxation you feel now. Let any remaining tension melt away, continuing to breathe gently in and out, feeling yourself become calmer and more relaxed." startTime:275 endTime:291],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Now tighten your buttocks by squeezing them together and at the same time, squeeze the muscles of your thighs. You can lift your feet up to help tense your leg muscles. Notice the sensations of tightness, pulling and constriction." startTime:293 endTime:310],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Hold on to that tension, and focus on it, and take a deep breath. Then slowly exhale as you relax your buttocks and thighs." startTime:312 endTime:319],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Allow your muscles to relax completely, and to let any tension drain away, melting away." startTime:320 endTime:327],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Feel how the muscles of your hips and legs feel different now than they did when you were clenching them." startTime:329 endTime:334],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Really notice the difference. Continue to let go further and further, experiencing an even deeper relaxation, breathing in and out, slowly and gently, in and out." startTime:336 endTime:350],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Now tighten the muscles of your calves and your feet as you flex your feet, pulling your toes towards you." startTime:353 endTime:359],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Flex these muscles carefully to avoid a cramp." startTime:360 endTime:363],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Continue to flex your feet, feeling the muscles of your calves, feet and toes tighten and pull. Hold the tension for another second and take a deep breath. And now, slowly, exhale, release. " startTime:364 endTime:378],
                [[PMRCaptionKeyFrame alloc] initWithString:@"As your muscles relax, notice how the sensations in your calves and feet change, perhaps feeling softer, or lighter. Really notice how the sensations of tension are different from the sensations your are now experiencing." startTime:380 endTime:398],
                [[PMRCaptionKeyFrame alloc] initWithString:@"With each breath, allow more tension to drain from your calves, relaxing more and more deeply." startTime:399 endTime:405],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Continue to breath slowly, thinking the word \"Relax\" each time you exhale, continuing to let any remaining tension drain away, breathing in and out, in and out." startTime:406 endTime:421],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Relax, relax." startTime:423 endTime:425],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Now that your whole body is feeling relaxed and comfortable, feel that sense of warmth and calmness spread over your whole body, continuing to breath naturally, smoothly and steadily, letting the breath in and out, slowly and regularly, thinking the word \"Relax\", every time you breath out, breathing in and out, in and out. " startTime:427 endTime:457],
                [[PMRCaptionKeyFrame alloc] initWithString:@"As you continue to breathe, imagine a wave of relaxation slowly spreading throughout your body. " startTime:459 endTime:465],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Starting at your head and gradually penetrating all of your muscles, all of the cells in your body, all the way down to your toes" startTime:466 endTime:475],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Allow yourself to relax completely, continuing to breathe slowly and smoothly, sinking into that feeling of relaxation and noticing how it feels so that you will be able to access it and recreate it later on your own." startTime:476 endTime:492],
                [[PMRCaptionKeyFrame alloc] initWithString:@"In a moment, I'm going to count from 5 to 1. As I do, you will gradually feel more and more alert. When I get to 3, open your eyes, and when I get to 1, you will feel alert and refreshed and ready for the rest of your day." startTime:493 endTime:511],
                [[PMRCaptionKeyFrame alloc] initWithString:@"5, 4, beginning to shift your body, feeling a bit more awake now, 3, opening your eyes, 2, a bit more awake now, 1." startTime:512 endTime:527],
                [[PMRCaptionKeyFrame alloc] initWithString:@"Now you are feeling refreshed and alert, relaxed and ready for whatever is next. " startTime:528 endTime:535],
                nil];
    
    captionContainerView.layer.cornerRadius = 8.0;
    captionContainerView.layer.masksToBounds = YES;
    [captionContainerView setNeedsDisplay];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        captionButtonEnabledColor = [UIColor colorWithRed:.7 green:0 blue:0 alpha:.5];
        captionButtonDisabledColor = nil;
    } else {
        captionButtonEnabledColor = [UIColor whiteColor];
        captionButtonDisabledColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    
    captionButton.tintColor = decryptBoolForKey(@"pmr_captions") ? captionButtonEnabledColor : captionButtonDisabledColor;
    
    [contactButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    captionButton.accessibilityLabel = decryptBoolForKey(@"pmr_captions") ? @"Captions: Enabled" : @"Captions: Disabled";
    captionButton.accessibilityHint = @"Toggles captions.";
    
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"pmr" ofType:@"mp3"]];    
	NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
	audioPlayer.numberOfLoops = 0;
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self pause];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    [super viewWillDisappear:animated];
}

- (void)updateTimer
{
    timer += 0.5;
    
    if (timer >= 536) {
        [playbackTimer invalidate];
        playbackTimer = nil;
        [VHBLogUtils endTimedEvent:LETProgressiveClose];
        return;
    }
    
    for (PMRKeyFrame *keyframe in keyframes) {
        if (timer < keyframe.focusTime || timer > keyframe.unfocusTime + unfocusDuration) {
            continue;
        }
        
        if (timer >= keyframe.focusTime && timer < keyframe.focusTime + focusDuration) {
            // Focus Animating
            [self focusBodyPart:keyframe.bodyPart duration:(keyframe.focusTime + focusDuration - timer)];
            break;
        } else if (timer >= keyframe.focusTime + focusDuration && timer < keyframe.unfocusTime) {
            // Fully Focused
            [self focusBodyPart:keyframe.bodyPart duration:0];
            break;
        } else if (timer >= keyframe.unfocusTime && timer < keyframe.unfocusTime + unfocusDuration) {
            // Unfocus Animating
            [self unfocusBodyPart:(keyframe.unfocusTime + unfocusDuration - timer)];
            break;
        }
    }
    
    
    if (decryptBoolForKey(@"pmr_captions")) {
        for (PMRCaptionKeyFrame *keyframe in captions) {
            if (timer < keyframe.startTime || timer > keyframe.endTime + captionHideDuration) {
                continue;
            }
            
            if (timer >= keyframe.startTime && timer < keyframe.startTime + captionShowDuration) {
                // Showing
                [self showCaption:keyframe.text duration:captionShowDuration];
                break;
            } else if (timer >= keyframe.startTime + captionShowDuration && timer < keyframe.endTime) {
                // Shown
                [self showCaption:keyframe.text duration:0];
                break;
            } else if (timer >= keyframe.endTime && timer < keyframe.endTime + captionHideDuration) {
                // Hiding
                [self hideCaption:captionHideDuration];
                break;
            }
        }
    }
    
    paused = NO;
}

- (void)pause
{
    paused = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        resumeButton.alpha = 1.0;
    }];
    resumeButton.accessibilityLabel = @"Resume";
    resumeButton.accessibilityHint = @"Resumes the session.";
    
    [playbackTimer invalidate];
    playbackTimer = nil;
    
    float alpha = [highlightImageView.layer.presentationLayer opacity];
    CGAffineTransform transform = [bodyContainerView.layer.presentationLayer affineTransform];
    
    [highlightImageView.layer removeAllAnimations];
    [bodyContainerView.layer removeAllAnimations];
    
    highlightImageView.alpha = alpha;
    bodyContainerView.transform = transform;
    
    [audioPlayer pause];
    [VHBLogUtils endTimedEvent:LETProgressiveClose];
}

- (void)resume
{
    playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [self updateTimer];
    [audioPlayer setCurrentTime:timer];
    [audioPlayer play];
    [VHBLogUtils logEventType:LETProgressiveStart];
    [VHBLogUtils startTimedEvent:LETProgressiveClose];
}

- (void)viewDidUnload
{
    [self setHighlightImageView:nil];
    [self setBodyImageView:nil];
    [self setBodyContainerView:nil];
    [self setResumeButton:nil];
    [self setCaptionContainerView:nil];
    [self setCaptionLabelView:nil];
    [self setAudioPlayer:nil];
    [self setContactButton:nil];
    [self setCaptionButtonEnabledColor:nil];
    [self setCaptionButtonDisabledColor:nil];
    [self setKeyframes:nil];
    [self setCaptions:nil];
    [self setPlaybackTimer:nil];
    //[self setDefaults:nil];
    [self setCaptionButton:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (playbackTimer) {
        [self pause];
    }
}

- (void)showCaption:(NSString *)text duration:(float)duration {
    if (!paused && !(captionContainerView.alpha <= 0)) {
        return;
    }
    
    NSLog(@"%@ - %@", @"Showing Caption", text);
    
    
    CGSize newSize = [VHBViewUtils boundingRectForString:text withSize:CGSizeMake(self.view.frame.size.width - 60, 999) font:captionLabelView.font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    
    captionLabelView.text = text;
    
    int top = self.view.frame.size.height - newSize.height - 30;
    
    captionContainerView.frame = CGRectMake(20, top, self.view.frame.size.width - 40, newSize.height + 15);
    NSLog(@"%@", [NSValue valueWithCGRect:captionContainerView.frame]);
    captionLabelView.frame = CGRectMake(10, 7, self.view.frame.size.width - 60, newSize.height);
    ;
    NSLog(@"%@", [NSValue valueWithCGRect:captionLabelView.frame]);
    
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
        captionContainerView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hideCaption:(float)duration {
    if (!paused && captionContainerView.alpha <= 0) {
        return;
    }
    
    NSLog(@"%@", @"Hiding Caption");
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
        captionContainerView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)focusBodyPart:(kBodyPart)part duration:(float)duration {
    if (!paused && highlightedPart != kNone) {
        return;
    }
    
    NSLog(@"%@ - %.02f", @"Focusing", duration);
    
    highlightImageView.image = [self bodyPartImage:part];
    highlightedPart = part;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
        
        if (part != kBody) {
            float scale = [self bodyPartScale:part];
            CGPoint center =  [self bodyPartCenter:part];
            
            bodyContainerView.transform = CGAffineTransformConcat(CGAffineTransformMakeTranslation(bodyContainerView.center.x - center.x, bodyContainerView.center.y - center.y), CGAffineTransformMakeScale(scale, scale));
        }
        highlightImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

- (void)unfocusBodyPart:(float)duration {
    if (!paused && highlightedPart == kNone) {
        return;
    }
    
    NSLog(@"%@ - %.02f", @"Unfocusing", duration);
    
    highlightedPart = kNone;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionAllowUserInteraction animations:^{
        bodyContainerView.transform = CGAffineTransformIdentity;
        highlightImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

- (UIImage *)bodyPartImage:(kBodyPart)part {
    NSString *name;
    switch (part) {
        case kArms:
            name = @"arms_highlight";
            break;
        case kBody:
            name = @"body_highlight";
            break;
        case kButt:
            name = @"butt_highlight";
            break;
        case kFeet:
            name = @"feet_highlight";
            break;
        case kHead:
            name = @"head_highlight";
            break;
        case kShoulders:
            name = @"shoulders_highlight";
            break;
        case kStomach:
            name = @"stomach_highlight";
            break;
        default:
            return nil;
    }
    
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]];
}

- (float)bodyPartScale:(kBodyPart)part {
    float scale = 1.0;
    switch (part) {
        case kArms:
            scale = 1.5;
            break;
        case kButt:
            scale = 2;
            break;
        case kFeet:
            scale = 2;
            break;
        case kHead:
            scale = 2.5;
            break;
        case kShoulders:
            scale = 2;
            break;
        case kStomach:
            scale = 2.5;
            break;
        default:
            break;
    }
    
    return scale;
}

- (CGPoint)bodyPartCenter:(kBodyPart)part {
    CGPoint center = self.bodyImageView.center;
    switch (part) {
        case kButt:
            center.y += (center.y * .2);
            break;
        case kArms:
            center.y -= (center.y * 0.05);
            break;
        case kFeet:
            center.y = center.y * 1.8;
            break;
        case kHead:
            center.y -= (center.y * 0.6);
            break;
        case kShoulders:
            center.y -= (center.y * 0.4);
            break;
        case kStomach:
            center.y -= (center.y * 0.05);
            break;
        default:
            break;
    }
    
    return center;
}

- (IBAction)captionClicked:(id)sender {
    BOOL showCaps = !decryptBoolForKey(@"pmr_captions");
    
    if (showCaps) {
        [VHBLogUtils logEventType:LETProgressiveCaptionsEnabled];
    } else {
        [VHBLogUtils logEventType:LETProgressiveCaptionsDisabled];
    }
    
    captionButton.tintColor = showCaps ? captionButtonEnabledColor : captionButtonDisabledColor;
    //[defaults setBool:showCaps forKey:@"pmr_captions"];
    encryptBoolForKey(@"pmr_captions", showCaps);
    //[defaults synchronize];
    
    if (!showCaps) {
        [self hideCaption:captionHideDuration];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = showCaps ? @"Captions Enabled" : @"Captions Disabled";
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
    
    captionButton.accessibilityLabel = showCaps ? @"Captions: Enabled" : @"Captions: Disabled";
}

- (IBAction)resumeClicked:(id)sender {    
    if (!UIAccessibilityIsVoiceOverRunning()) {
        [UIView animateWithDuration:0.5 animations:^{
            resumeButton.alpha = 0.0;
        }];
        [self resume];
    } else {
        if (paused) {
            resumeButton.accessibilityLabel = @"Pause";
            resumeButton.accessibilityHint = @"Pauses the session.";
            [self resume];
        } else {
            [self pause];
        }
        
    }
    
}
@end
