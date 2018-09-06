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

#import "CBChangeDurationViewController.h"
#import "DefaultsWrapper.h"

@interface CBChangeDurationViewController () {
    float duration;
    NSTimer *timer;
}

@end

@implementation CBChangeDurationViewController

@synthesize smallDisableButton, smallDoneButton, smallRevertButton;
@synthesize mediumDisableButton, mediumDoneButton, mediumHoldButton, mediumRevertButton;
@synthesize largeHoldButton;
@synthesize durationLabel;
@synthesize instructionsLabel;
@synthesize titleLabel;
@synthesize durationType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)title
{
    switch (durationType) {
        case CBDurationTypeInhale:
            return @"Inhale";
        case CBDurationTypeExhale:
            return @"Exhale";
        case CBDurationTypeHold:
            return @"Hold";
        case CBDurationTypeRest:
            return @"Rest";
    }
    
    return nil;
}

- (NSString *)instructions
{
    switch (durationType) {
        case CBDurationTypeInhale:
            return @"Let the air out of your lungs. Push as much air out as you can by tightening your stomach. Then, while inhaling, press and hold the button down. Try to make this a slow deep breath by pushing your stomach out. Release the button only when you begin to exhale.";
        case CBDurationTypeExhale:
            return @"Take a deep breath, pushing out your stomach and gathering as much air as you can into your lunghs. When you begin to exhale, press and hold the button down. Try to make this a slow long exhale by pushing your stomach out. Release the button only when you begin to inhale.";
        case CBDurationTypeHold:
            return @"Take a deep breath, pushing out your stomach andgathering as much air as you can in your lungs. When you have fully inhaled, press and hold the button down. Hold the inhale for as long as it remains comfortable. Release the button only when you start to exhale.\n\nHold is an optional feature and can be disabled.";
        case CBDurationTypeRest:
            return @"Let the air out of your lungs. Push as much air out as you can by tightening your stomach. Then, press and hold the button down. Relax without inhaling for as long as it remains comfortable. Release the button only when you start to inhale.\n\nRest is an optional feature and can be disabled.";
    }
    
    return nil;
}

- (NSString *)defaultKey
{
    switch (durationType) {
        case CBDurationTypeInhale:
            return @"inhale_duration";
        case CBDurationTypeExhale:
            return @"exhale_duration";
        case CBDurationTypeHold:
            return @"hold_duration";
        case CBDurationTypeRest:
            return @"rest_duration";
    }
}

- (float)currentDuration
{
    //NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    return decryptFloatForKey([self defaultKey]);
}

- (float)minimumDuration
{
    float min = 0;
    switch (durationType) {
        case CBDurationTypeInhale:
            min = 3.0;
            break;
        case CBDurationTypeExhale:
            min = 3.0;
            break;
        case CBDurationTypeHold:
            min = 1.0;
            break;
        case CBDurationTypeRest:
            min = 1.0;
            break;
    }
    
    return min;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateButtons];
    
    titleLabel.text = [NSString stringWithFormat:@"%@ Duration", [self title]];
    instructionsLabel.text = [self instructions];
    durationLabel.text = [NSString stringWithFormat:@"%.1f s", [self currentDuration]];
    durationLabel.accessibilityLabel = [NSString stringWithFormat:@"%.1f seconds", [self currentDuration]];
}

- (void) updateDuration
{
    duration += 0.1;
    durationLabel.text = [NSString stringWithFormat:@"%.1f s", duration];
}

- (IBAction)holdStarted:(id)sender {
    duration = 0;
    durationLabel.text = @"0.0 s";
    timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateDuration) userInfo:nil repeats:YES];
}

- (void)updateButtons
{
    smallDisableButton.alpha = 0;
    smallDoneButton.alpha = 0;
    smallRevertButton.alpha = 0;
    mediumDisableButton.alpha = 0;
    mediumDoneButton.alpha = 0;
    mediumHoldButton.alpha = 0;
    mediumRevertButton.alpha = 0;
    largeHoldButton.alpha = 0;

    if (duration < 0.01) {
        switch (durationType) {
            case CBDurationTypeInhale:
            case CBDurationTypeExhale:
                largeHoldButton.alpha = 1;
                largeHoldButton.alpha = 1;
                break;
            case CBDurationTypeHold:
            case CBDurationTypeRest:
                if ([self currentDuration] < 0.01) {
                    largeHoldButton.alpha = 1;
                } else {
                    mediumDisableButton.alpha = 1;
                    mediumHoldButton.alpha = 1;
                }
                break;
        }
    } else {
        switch (durationType) {
            case CBDurationTypeInhale:
            case CBDurationTypeExhale:
                mediumDoneButton.alpha = 1;
                mediumRevertButton.alpha = 1;
                break;
            case CBDurationTypeHold:
            case CBDurationTypeRest:
                if ([self currentDuration] < 0.01) {
                    mediumDoneButton.alpha = 1;
                    mediumRevertButton.alpha = 1;
                } else {
                    smallDisableButton.alpha = 1;
                    smallDoneButton.alpha = 1;
                    smallRevertButton.alpha = 1;
                }
                break;
        }
    }
}

- (IBAction)disable:(id)sender {
    encryptFloatForKey([self defaultKey], 0);
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)done:(id)sender {
    //NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    encryptFloatForKey([self defaultKey], duration);
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)revert:(id)sender {
    duration = 0;
    durationLabel.text = [NSString stringWithFormat:@"%.01f s", [self currentDuration]];
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [NSString stringWithFormat:@"Duration reverted."]);
    [self updateButtons];
}

- (IBAction)holdReleased:(id)sender {
    [timer invalidate];
    
    duration = MAX(duration, [self minimumDuration]);
    durationLabel.text = [NSString stringWithFormat:@"%.01f s", duration];
    durationLabel.accessibilityLabel = [NSString stringWithFormat:@"%.1f seconds", [self currentDuration]];
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, [NSString stringWithFormat:@"New %@ Duration: %.01f seconds. Use the buttons near the bottom of the screen to revert or save.", [self title], duration]);
    
    [self updateButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
