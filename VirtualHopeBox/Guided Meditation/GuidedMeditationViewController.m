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

#import "GuidedMeditationViewController.h"

@interface GuidedMeditationViewController () {

}

@end

@implementation GuidedMeditationViewController

@synthesize playButton;
@synthesize captionView;
@synthesize imageView;
@synthesize started;
@synthesize paused;
@synthesize captionTimer;
@synthesize meditationType;
@synthesize captions;
@synthesize keyframes;
@synthesize timer;
@synthesize audioPlayer;
@synthesize keyframe;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)initCaptions
{
    switch (meditationType) {
        case GuidedMeditationTypeBeach:
            keyframes = @[@1, @9, @14, @20, @24, @30, @41, @43, @46, @51, @62, @66, @74, @90, @96, @106, @117, @126, @132, @140, @150, @162, @173, @178, @188, @200, @207, @218, @236, @252, @261, @273, @289];
            captions = @[@"First, remove distractions - let others know not to bother you.",
                         @"Make yourself comfortable, so that your thoughts are on the image and nothing else.",
                         @"Sit, or lie down, in a quiet, comfortable place.",
                         @"Then, mentally scan your body for tense muscles.",
                         @"If you find a muscle that's tense, or clenched, relax it.",
                         @"During the imagery exercise, involve all of your senses in the image: sight, sound, smell, touch, and taste.",
                         @"Get completely focused.",
                         @"The more focused you are, the better.",
                         @"Close your eyes, or lower your gaze.",
                         @"In your mind's eye, you see yourself descending down a long, narrow, wooden stairway, toward a beautiful, inviting beach.",
                         @"Your bare feet feel the rough, weathered step",
                         @"And with each step, you feel more and more tension gently melting away from your body.",
                         @"As you continue down the stairway, you notice the ocean is a deep shade of blue, with the fine, white crests of the waves sweeping towards the shore.",
                         @"You reach the end of the stairway, and step down, sinking into the warmth.",
                         @"As you soak in the warmth of the sun, a soothing sensation of relaxation gently melts through your entire body.",
                         @"The gentle sounds of the water lapping up onto the beach calm your mind, and allow you to feel even more relaxed.",
                         @"You begin walking slowly towards the edge of the water, and feel the warm sun on your face and shoulders.",
                         @"The salty smell of the ocean air invigorates you, and you take in a deep breath.",
                         @"Breathe slowly out, and feel more relaxed and refreshed.",
                         @"Finally, you reach the water's edge, and you gladly invite the little surges to flow over your toes and ankles.",
                         @"You watch the surges glide smoothly towards you, gently sweeping around your feet, and the trails of ocean water that flows slowly back out again.",
                         @"The cool water feels soft and comforting, as you enjoy a few moments, allowing yourself to gaze out on the far-reaching horizon.",
                         @"Overhead, you notice two birds gracefully soaring high above the ocean.",
                         @"And you can hear their soft cries becoming faint as they glide away.",
                         @"All of these sights, sounds, and sensations allow you to relax and let go, more and more.",
                         @"After a few moments, you begin slowly strolling down the beach, at the water's edge.",
                         @"You feel a warm, gentle breeze, pressing lightly against your back, and, with every step, you feel yourself relaxing, more and more.",
                         @"As you walk down the beach, you notice the details of sights and sounds around you, and the soothing sensations of the sun, the gentle breeze, and the sand below your feet.",
                         @"As you continue your leisurely walk down the beach, you notice a colorful beach chair, resting in a nice, peaceful spot, where the powdery, soft sand lies undisturbed.",
                         @"You approach this comfortable-looking beach chair, then you sit down, lie back, and settle in.",
                         @"You take in a long, deep breath, breathe slowly out, and feel even more relaxed and comfortable, resting in your chair.",
                         @"For a few moments more, let yourself enjoy the sights and sounds of this beautiful day on the beach.",
                         @"When you're ready, gently bring your attention back to the room, still letting yourself feel relaxed and comfortable, sitting where you are."];
            break;
        case GuidedMeditationTypeRoad:
            keyframes = @[@1, @8, @13, @22, @26, @36, @38, @44, @55, @59, @63, @75, @79, @81, @87, @97, @100, @104, @109, @121, @124, @133, @138, @146, @155, @167, @180, @184, @206, @214];
            captions = @[@"First, remove distractions - let others know not to bother you.",
                         @"Make yourself comfortable, so that your thoughts are on the image and nothing else.",
                         @"Sit, or lie down, in a quiet, comfortable place, then, mentally scan your body for tense muscles.",
                         @"If you find a muscle is tense, or clenched, relax it.",
                         @"During the imagery exercise, involve all of your senses in the image: sight, sound, smell, touch, and taste",
                         @"Get completely focused.",
                         @"The more focused you are, the better.",
                         @"Imagine yourself walking along an old country road. The sun is warm on your back, the birds are singing, the air is calm and fragrant.",
                         @"After a few steps, you come across an old gate.",
                         @"The gate creaks as you open it and go through.",
                         @"You find yourself in an overgrown garden, flowers growing where they have seeded themselves, vines climbing over a fallen tree, green grass, and shade trees.",
                         @"Breathe deeply, smelling the flowers.",
                         @"Listen to the birds and insects.",
                         @"Feel the gentle breeze, warm against your skin.",
                         @"You walk leisurely up a gentle slope behind the garden, and come to a wooded area, where the trees become denser",
                         @"The sun is filtered through the leaves.",
                         @"The air feels mild, and a bit cooler.",
                         @"You become aware of the sound of a nearby brook.",
                         @"You breathe deeply of the cool and fragrant air several times, and with each breath, you feel more relaxed.",
                         @"Soon, you come upon the brook.",
                         @"It's clear and clean as it tumbles over the rocks and some fallen logs.",
                         @"You follow the path along the brook for a ways",
                         @"The path takes you out into a sunlit clearing where you discover a small and picturesque waterfall.",
                         @"There's a rainbow in the mist.",
                         @"You find a comfortable place to sit for awhile, a perfect spot where you can feel completely relaxed.",
                         @"You feel good, as you allow yourself to just enjoy the warmth and solitude of this peaceful place.",
                         @"It's now time to return.",
                         @"You walk back down the path, through the cool trees, out into the sun-drenched overgrown garden, one last smell of the flowers, and out the creaky gate.",
                         @"You leave this secret retreat, for now, and return down the country road",
                         @"Then, back to the room, slowly open your eyes, and remember, you can visit this place whenever you wish."];
            break;
        case GuidedMeditationTypeForest:
            keyframes = @[@1, @8, @14, @20, @24, @32, @44, @46, @52, @57, @64, @75, @86, @98, @110, @120, @136, @147, @151, @158, @163, @177, @187, @197, @203, @211, @226, @242, @256, @266, @278];
            captions = @[@"First, remove all distractions - let others know not to bother you.",
                         @"Make yourself comfortable, so that your thoughts are on the image and nothing else.",
                         @"Sit, or lie down, in a quiet, comfortable place.",
                         @"Mentally scan your body for tense muscles.",
                         @"If you find a muscle is tense, or clenched, relax it.",
                         @"During the imagery exercise, involve all of your senses in the image: sight, sound, smell, touch, and taste.",
                         @"Get completely focused.",
                         @"The more focused you are, the better.",
                         @"Close your eyes, or lower your gaze.",
                         @"Imagine that you are walking down a path, into a lush forest.",
                         @"As you walk along the path, you completely take in the sights, sounds, smells, and feel of the place.",
                         @"All around you are trees, grasses, mossy ground cover, and fragrant flowers.",
                         @"You hear the soothing sounds of birds chirping, and the wind as it gently blows through the treetops.",
                         @"You smell the rich dampness of the forest floor, the smells of moist vegetation and new growth.",
                         @"Through gaps in the treetops, you see the sun high in the cloudless blue sky.",
                         @"The sun is dispersed through the canopy of the treetops and filters down onto the forest floor, creating intricate patterns of light and shadow.",
                         @"With each breath you take in this place, you feel a deep sense of peace and relaxation.",
                         @"You soon come to a clearing.",
                         @"There are several flat rocks in the clearing surrounded by a soft moss.",
                         @"A small stream runs along the rocks.",
                         @"You lie back on one of the rocks, or on the cushiony moss, and put your feet into the cool water.",
                         @"You feel the warm sun and a gentle, light breeze through your hair and across your skin.",
                         @"The sparkling clear water rushes around the multi-colored rocks, making little whirlpools and eddies.",
                         @"You put your hand into the water and lift a handful to your lips.",
                         @"The water is cool and refreshing.",
                         @"You close your eyes and listen to the water trickling around the rocks. You bathe in the warm sun, and feel as though you're floating, relaxing deeper and deeper.",
                         @"You let yourself sink further into relaxation while continuing to be aware of the sights, smells, sounds, and feel of the forest around you.",
                         @"You allow yourself to let go of any concerns or worries, and to feel completely refreshed and rejuvenated in this place.",
                         @"When you're ready, imagine that you slowly get up and leave the clearing.",
                         @"As you walk back down the path through the forest, fully take in this place, and realize that you may return whenever you wish by the same path.",
                         @"Each time you enter this place, you will feel relaxed and at peace."];
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initCaptions];
    
    keyframe = -1;
    timer = 0;
    
    NSURL *url;
    switch (meditationType) {
        case GuidedMeditationTypeBeach:
            url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"mp3_imagerybeach" ofType:@"mp3"]];
            break;
        case GuidedMeditationTypeForest:
            url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"mp3_imageryforest" ofType:@"mp3"]];
            break;
        case GuidedMeditationTypeRoad:
            url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"mp3_imagerycountryroad" ofType:@"mp3"]];
            break;
    }
    NSError *error;
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer setVolume:1.0];
    if (error) {
        NSLog(@"%@", error);
    } else {
        audioPlayer.delegate = self;
        audioPlayer.numberOfLoops = 0;
        [audioPlayer prepareToPlay];
    }
}

- (LogEntryType)playLogEntryType
{
    switch (meditationType) {
        case GuidedMeditationTypeBeach:
            return LETBeachImageryPlay;
        case GuidedMeditationTypeForest:
            return LETForestImageryPlay;
        case GuidedMeditationTypeRoad:
            return LETRoadImageryPlay;
    }
    return 0;
}

- (LogEntryType)closeLogEntryType
{
    switch (meditationType) {
        case GuidedMeditationTypeBeach:
            return LETBeachImageryClose;
        case GuidedMeditationTypeForest:
            return LETForestImageryClose;
        case GuidedMeditationTypeRoad:
            return LETRoadImageryClose;
    }
    return 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    UIImage *img;
    switch (meditationType) {
        case GuidedMeditationTypeBeach:
            img = [UIImage imageNamed:@"guidedimagerybeach.png"];
            break;
        case GuidedMeditationTypeForest:
            img = [UIImage imageNamed:@"guidedimageryforest.png"];
            break;
        case GuidedMeditationTypeRoad:
            img = [UIImage imageNamed:@"guidedimageryroad.png"];
            break;
    }
    [imageView setImage:img];
    [self setCaption:@"You are about to be led through a relaxation exercise focused on visualizing something pleasant. This exercise takes about 4 minutes. It has accompanying audio so you will have to find a quiet place or put on your headphones now."];
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, captionView);
}

- (IBAction)playClicked:(id)sender {
    if (!started) {
        [self play];
    } else {
        if (paused) {
            [self play];
        } else {
            [self pause];
        }
    }
}

- (void)pause
{
    NSLog(@"Pause");
    if (paused) {
        return;
    }
    
    paused = YES;
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.accessibilityLabel = @"Play";
    playButton.accessibilityHint = @"Double tap to resume the session";
    [captionTimer invalidate];
    captionTimer = nil;
    [audioPlayer pause];
    [VHBLogUtils endTimedEvent:[self closeLogEntryType]];
}

- (void)stop
{
    NSLog(@"Stop");
    if (!started) {
        return;
    }
    
    started = NO;
    paused = NO;
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    playButton.accessibilityLabel = @"Play";
    playButton.accessibilityHint = @"Double tap to start the session";
    timer = 0;
    keyframe = -1;
    [captionTimer invalidate];
    captionTimer = nil;
    [audioPlayer stop];
    [audioPlayer setCurrentTime:0];
    [audioPlayer prepareToPlay];
    [VHBLogUtils endTimedEvent:[self closeLogEntryType]];
}

- (void)play
{
    NSLog(@"Play");
    if (started && !paused) {
        return;
    }
    
    started = YES;
    paused = NO;
    [playButton setTitle:@"Pause" forState:UIControlStateNormal];
    playButton.accessibilityLabel = @"Pause";
    playButton.accessibilityHint = @"Double tap to pause the session";
    
    captionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
    [self updateTimer];
    [audioPlayer setCurrentTime:timer];
    [audioPlayer play];
    
    [VHBLogUtils logEventType:[self playLogEntryType]];
    [VHBLogUtils startTimedEvent:[self closeLogEntryType]];
}

- (void)updateTimer
{
    if (audioPlayer) {
        timer = audioPlayer.currentTime;
    } else {
        timer += 0.5;
    }
    
    if (keyframe >= (int)keyframes.count-1) {
        [captionTimer invalidate];
        return;
    }
    
    int nextFrame = keyframe+1;
    BOOL updateFrame = NO;
    while (true) {
        if (nextFrame < (int)keyframes.count) {
            int nextStart = (int)[((NSNumber *)[keyframes objectAtIndex:nextFrame]) integerValue];
            if ((int)timer >= nextStart) {
                updateFrame = YES;
                keyframe = nextFrame;
                nextFrame = nextFrame+1;
            } else {
                break;
            }
        } else {
            break;
        }
    }
    
    if (updateFrame) {
        NSLog(@"New Frame: %d", keyframe);
        [self setCaption:[captions objectAtIndex:keyframe]];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stop];
}

- (void)setCaption:(NSString *)text
{
    self.captionView.text = text;
    CGRect frame = captionView.frame;
//    CGSize bound = [self.captionView sizeThatFits:CGSizeMake(self.captionView.frame.size.width, CGFLOAT_MAX)];
    frame.origin.y = imageView.frame.origin.y + imageView.frame.size.height + 10;
//    frame.size.height = bound.height + 5;
    NSLog(@"Caption Frame %@", NSStringFromCGRect(frame));
    captionView.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
