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

#import "VHBAudioPlayerView.h"

@interface VHBAudioPlayerView () {
    NSURL *currentAudio;
    int playDuration;
    AVAudioPlayer *player;
    NSTimer *timer;
}

@end

@implementation VHBAudioPlayerView
@synthesize playButton;
@synthesize stopButton;
@synthesize songSlider;
@synthesize timerLabel;
@synthesize titleLabel;
@synthesize playing = _playing;

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"VHBAudioPlayer" owner:self options:nil] objectAtIndex:0]];
        [self configure];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configure];
    }
    return self;
}

- (void)configure 
{
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.timerLabel.layer.cornerRadius = 5;
    self.timerLabel.layer.borderColor = [UIColor blackColor].CGColor;
    self.timerLabel.layer.borderWidth = 1;
    
    [songSlider setContinuous:NO];
    [songSlider sendActionsForControlEvents:UIControlEventValueChanged];
    [songSlider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderChanged
{
    if (!player) {
        return;
    }
    
    player.currentTime = songSlider.value;
    [self timerTick];
}

- (void)loadAudioWithURL:(NSURL *)url title:(NSString *)title
{
    NSString *theFileName = [[url lastPathComponent] stringByDeletingPathExtension];
    theFileName = [theFileName stringByAppendingString:@".caf"];
    NSURL *urlReturned = [self applicationDocumentDirectory];
    NSURL *urlFinal = [urlReturned URLByAppendingPathComponent:theFileName];

    NSError *error;
    titleLabel.text = title;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFinal error:&error];
    playDuration = player.duration;
    [songSlider setMaximumValue:player.duration];
    [songSlider setValue:0];
    player.delegate = self;
    [self timerTick];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    _playing = NO;
    [self updatePlayStatus];
}

- (NSURL *)applicationDocumentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentPath = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:documentPath];
    return url;
}

- (void)timerTick
{
    playDuration = player.duration - player.currentTime;
    int minutes = floor(playDuration / 60.0);
    int seconds = (int)playDuration % 60;
    timerLabel.text = [NSString stringWithFormat:@"%.02i:%.02i", minutes, seconds];
    [songSlider setValue:player.currentTime];
}

- (IBAction)playClicked:(id)sender {
    if (!player) {
        return;
    }
    
    _playing = !_playing;
    
    NSString *notification = _playing ? @"Recording started." : @"Recording paused.";
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notification);

    [self updatePlayStatus];
}

- (void)updatePlayStatus
{
    [playButton setImage:(_playing ? [UIImage imageNamed:@"pause.png"] : [UIImage imageNamed:@"play_button.png"]) forState:UIControlStateNormal];
    playButton.accessibilityLabel = _playing ? @"Pause" : @"Play";
    
    if (_playing) {
        [player play];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    } else {
        [player pause];
        [timer invalidate];
    }
}

- (IBAction)stopClicked:(id)sender {
    [timer invalidate];
    titleLabel.text = @"";
    player = nil;
    [self removeFromSuperview];
    timerLabel.text = @"00:00";
    [songSlider setValue:0];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Recording complete.");
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)plyr
{
    [player pause];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    _playing = NO;
    [self updatePlayStatus];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)plyr
{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self updatePlayStatus];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)plyr error:(NSError *)error
{
    NSLog(@"%@", error);
    _playing = NO;
    [self updatePlayStatus];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)plyr successfully:(BOOL)flag
{
    _playing = NO;
    [self updatePlayStatus];
    plyr.currentTime = 0;
    [self timerTick];
}
@end
