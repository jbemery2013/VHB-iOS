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

#import "VHBAudioRecorderView.h"
#import <QuartzCore/QuartzCore.h>

@interface VHBAudioRecorderView () {
    NSTimer *recordTimer;
    int recordDuration;
}

@end

@implementation VHBAudioRecorderView

@synthesize stopButton, recordButton;
@synthesize timerLabel;
@synthesize recording = _recording;
@synthesize currentRecordingURL;
@synthesize recorder;
@synthesize delegate;

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"VHBAudioRecorder" owner:self options:nil] objectAtIndex:0]];
        [self configure];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:[[[NSBundle mainBundle] loadNibNamed:@"VHBAudioRecorder" owner:self options:nil] objectAtIndex:0]];
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
    
    recordDuration = 0;
     
    _recording = NO;
}

- (void)timerTick
{
    recordDuration++;
    int minutes = floor(recordDuration / 60.0);
    int seconds = (int)recordDuration % 60;
    timerLabel.text = [NSString stringWithFormat:@"%.02i:%.02i", minutes, seconds];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)recordClicked:(id)sender {
    _recording = !_recording;
    [recordButton setImage:(_recording ? [UIImage imageNamed:@"pause.png"] : [UIImage imageNamed:@"record.png"]) forState:UIControlStateNormal];
    recordButton.accessibilityLabel = _recording ? @"Pause" : @"Record";
    recordButton.accessibilityHint = _recording ? @"Pauses recording." : @"Begins recording a message.";
    
    if (_recording) {
        if (!recorder) {            
            NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
             [NSNumber numberWithFloat: 44100.0], AVSampleRateKey,
             [NSNumber numberWithInt: kAudioFormatAppleIMA4], AVFormatIDKey,
             [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
             [NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey,
             nil];
            
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            [fmt setDateFormat:@"yyyyMMddHHmmss"];
            NSString *tempDir = NSTemporaryDirectory();
            NSString *soundFilePath = [tempDir stringByAppendingString: [NSString stringWithFormat:@"vhb_%@.caf", [fmt stringFromDate:[NSDate date]]]];
            
            NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
            currentRecordingURL = newURL;
            
            recorder = [[AVAudioRecorder alloc] initWithURL: currentRecordingURL settings: recordSettings error: nil];
            recorder.delegate = self;
            [recorder prepareToRecord];
        }
        
        [recorder record];
        
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerTick) userInfo:nil repeats:YES];
    } else {
        [recordTimer invalidate];
        [recorder pause];
    }
}

- (IBAction)stopClicked:(id)sender {
    [recordTimer invalidate];
    
    if (recorder) {
        [recorder stop];
        _recording = NO;
    }
    
    recorder = nil;
    recorder.delegate = nil;
    recordDuration = 0;
    timerLabel.text = @"00:00";
    [recordButton setImage:[UIImage imageNamed:@"record.png"] forState:UIControlStateNormal];
    [self removeFromSuperview];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"Audio Recorded Successfully");
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setDateFormat:@"yyyyMMddHHmmss"];
    NSString *name = [NSString stringWithFormat:@"/vhb_%@.caf", [fmt stringFromDate:[NSDate date]]];
    NSString *docsDir = (NSString *)[dirPaths objectAtIndex:0];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:[docsDir stringByAppendingString:name]];
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtURL:currentRecordingURL toURL:url error:&error];
    if (!error) {
        [[NSFileManager defaultManager] removeItemAtURL:currentRecordingURL error:nil];
    }
    [fmt setDateFormat:@"'Recorded on' MMM dd, yyyy 'at' HH:mm"];
    
    [delegate audioRecorderDidFinishRecording:url title:[fmt stringFromDate:[NSDate date]]];
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"Decode Error occurred %@", error);
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred: %@", error);
}

@end
