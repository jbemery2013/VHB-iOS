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

#import "CBSettingsViewController.h"
#import "DefaultsWrapper.h"

@interface CBSettingsViewController () {
    //NSUserDefaults *defaults;
    BOOL sessionEnabled, embededPickerShown;
    UIPopoverController *popover;
}

@end

@implementation CBSettingsViewController
@synthesize musicTypeLabel;
@synthesize vocalPromptsSwitch;
@synthesize sessionSwitch;
@synthesize backgroundTypeLabel;
@synthesize embeddedPickerView;
@synthesize externalPickerView;
@synthesize pickerToolbar;
@synthesize vocalPromptsCell;
@synthesize inhaleCell, exhaleCell, holdCell, restCell, sessionCell, unlimitedCell;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //defaults = [NSUserDefaults standardUserDefaults];
    
    vocalPromptsSwitch.on = decryptBoolForKey(@"vocal_prompts");
    [vocalPromptsSwitch addTarget:self action:@selector(vocalPromptsToggled:) forControlEvents:UIControlEventValueChanged];
    
    backgroundTypeLabel.text = [CBBackgroundType nameForBackgroundType:decryptIntForKey(@"background_type")];
    
    musicTypeLabel.text = [CBMusicType nameForMusicType:decryptIntForKey(@"music_type")];
    
    sessionEnabled = decryptBoolForKey(@"cb_session_enabled");
    embeddedPickerView.dataSource = self;
    embeddedPickerView.delegate = self;
    externalPickerView.dataSource = self;
    externalPickerView.delegate = self;
    embededPickerShown = NO;
    if (sessionEnabled) {
        int mins = decryptIntForKey(@"session_duration") / 60;
        [embeddedPickerView selectRow:mins-1 inComponent:0 animated:NO];
        [externalPickerView selectRow:mins-1 inComponent:0 animated:NO];
        sessionCell.detailTextLabel.text = [self pickerView:externalPickerView titleForRow:mins-1 forComponent:0];
    }
    
    sessionSwitch.on = !sessionEnabled;
}

- (BOOL)hasEmbededPicker
{
    return UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshDurations];
}

- (void)refreshDurations {
    float dur = decryptFloatForKey(@"inhale_duration");
    inhaleCell.detailTextLabel.text = [NSString stringWithFormat:@"%.01f s", dur];
    inhaleCell.accessibilityLabel = [NSString stringWithFormat:@"Inhale Duration: %.01f seconds", dur];
    
    dur = decryptFloatForKey(@"exhale_duration");
    exhaleCell.detailTextLabel.text = [NSString stringWithFormat:@"%.01f s", dur];
    exhaleCell.accessibilityLabel = [NSString stringWithFormat:@"Exhale Duration: %.01f seconds", dur];
    
    dur = decryptFloatForKey(@"hold_duration");
    if (dur > 0.01) {
        holdCell.detailTextLabel.text = [NSString stringWithFormat:@"%.01f s", dur];
        holdCell.accessibilityLabel = [NSString stringWithFormat:@"Hold Duration: %.01f seconds", dur];
    } else {
        holdCell.detailTextLabel.text = @"Disabled";
        holdCell.accessibilityLabel = @"Hold Duration: Disabled";
    }
    
    dur = decryptFloatForKey(@"rest_duration");
    if (dur > 0.01) {
        restCell.detailTextLabel.text = [NSString stringWithFormat:@"%.01f s", dur];
        restCell.accessibilityLabel = [NSString stringWithFormat:@"Rest Duration: %.01f seconds", dur];
    } else {
        restCell.detailTextLabel.text = @"Disabled";
        restCell.accessibilityLabel = @"Rest Duration: Disabled";
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3 && indexPath.row == 0) {
        encryptBoolForKey(@"vocal_prompts", !vocalPromptsSwitch.on);
        //[defaults setBool:!vocalPromptsSwitch.on forKey:@"vocal_prompts"];
        [vocalPromptsSwitch setOn:!vocalPromptsSwitch.on animated:YES];
        
        vocalPromptsCell.accessibilityLabel = [NSString stringWithFormat:@"Vocal Prompts: %@", vocalPromptsSwitch.on ? @"On" : @"Off"];
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        [self.tableView beginUpdates];
        if (sessionEnabled) {
            if (embededPickerShown) {
                embededPickerShown = NO;
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [self hideExternalPicker];
            
            sessionEnabled = NO;
            sessionSwitch.on = YES;
            //[defaults setBool:NO forKey:@"cb_session_enabled"];
            encryptBoolForKey(@"cb_session_enabled", NO);
            //[defaults removeObjectForKey:@"session_duration"];
            encryptIntForKey(@"session_duration", 5*60);
            //[defaults synchronize];
            
        } else {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            sessionEnabled = YES;
            sessionSwitch.on = NO;\
            sessionCell.detailTextLabel.text = @"5 Minutes";
            //[defaults setBool:YES forKey:@"cb_session_enabled"];
            encryptBoolForKey(@"cb_session_enabled", YES);
            //[defaults setInteger:(5*60) forKey:@"session_duration"];
            encryptIntForKey(@"session_duration", 5*60);
            [embeddedPickerView selectRow:4 inComponent:0 animated:NO];
            [externalPickerView selectRow:4 inComponent:0 animated:NO];
            //[defaults synchronize];
        }
        [self.tableView endUpdates];
        
        unlimitedCell.accessibilityLabel = [NSString stringWithFormat:@"Unlimited Session Duration: %@", sessionEnabled ? @"Off" : @"On"];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIViewController *ctrl = [[UIViewController alloc] init];
            ctrl.view = [[UIView alloc] initWithFrame:externalPickerView.frame];
            ctrl.contentSizeForViewInPopover = self.externalPickerView.frame.size;
            [ctrl.view addSubview:self.externalPickerView];
            if (!popover) {
                popover = [[UIPopoverController alloc] initWithContentViewController:ctrl];
        
                popover.delegate = self;
                [popover presentPopoverFromRect:self.sessionCell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        } else if (![self hasEmbededPicker]) {
            if (self.externalPickerView.superview == nil) {
                [self showExternalPicker];
            }
        } else {
            [self.tableView beginUpdates];
            if (embededPickerShown) {
                embededPickerShown = NO;
                [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                embededPickerShown = YES;
                [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            [self.tableView endUpdates];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    popover = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([musicTypeLabel.text isEqualToString:@"My Music"]) {
        return 5;
    } else {
        return 4;
    }
}

- (void)showExternalPicker
{
    // the date picker might already be showing, so don't add it to our view
    if (self.externalPickerView.superview == nil)
    {
        self.tableView.scrollEnabled = NO;
        
        CGRect startFrame = self.externalPickerView.frame;
        CGRect endFrame = self.externalPickerView.frame;
        CGRect toolbarStartFrame = self.pickerToolbar.frame;
        CGRect toolbarEndFrame = self.pickerToolbar.frame;
        
        // the start position is below the bottom of the visible frame
        toolbarStartFrame.origin.y = self.view.frame.size.height;
        startFrame.origin.y = self.view.frame.size.height + self.pickerToolbar.frame.size.height;
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height - toolbarEndFrame.size.height;
        toolbarEndFrame.origin.y = self.view.frame.size.height - endFrame.size.height - toolbarEndFrame.size.height;
        
        self.pickerToolbar.frame = toolbarStartFrame;
        self.externalPickerView.frame = startFrame;
        
        [self.view addSubview:self.pickerToolbar];
        [self.view addSubview:self.externalPickerView];
        [UIView animateWithDuration:.4 animations: ^{
            self.externalPickerView.frame = endFrame;
            self.pickerToolbar.frame = toolbarEndFrame;
        } completion:nil];
    }
}

- (void)hideExternalPicker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || externalPickerView.superview == nil) {
        return;
    }
    
    self.tableView.scrollEnabled = YES;
    
    CGRect pickerFrame = self.externalPickerView.frame;
    CGRect toolbarFrame = self.pickerToolbar.frame;
    pickerFrame.origin.y = self.view.frame.size.height + self.pickerToolbar.frame.size.height;
    toolbarFrame.origin.y = self.view.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:.4 animations: ^{
        self.externalPickerView.frame = pickerFrame;
        self.pickerToolbar.frame = toolbarFrame;
    } completion:^(BOOL finished) {
        [self.externalPickerView removeFromSuperview];
        [self.pickerToolbar removeFromSuperview];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        int rows = 1;
        if (sessionEnabled) {
            rows++;
            if ([self hasEmbededPicker] && embededPickerShown) {
                rows++;
            }
        }
        return rows;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return row == 0 ? @"1 Minute" : [NSString stringWithFormat:@"%ld Minutes", row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.externalPickerView && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Done button handles this
        return;
    }
    
    //NSLog(@"Session Set: %d min.", row+1);
    sessionCell.detailTextLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    //[defaults setInteger:((row+1) * 60) forKey:@"session_duration"];
    encryptIntForKey(@"session_duration", (int)((row+1) * 60));
    //[defaults synchronize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            UISwitch *sw = (UISwitch *)[cell viewWithTag:1];
            cell.accessibilityLabel = [NSString stringWithFormat:@"Vocal Prompts: %@", sw.on ? @"On" : @"Off"];
            cell.accessibilityHint = @"Double tap to toggle.";
        } else {
            cell.accessibilityLabel = [NSString stringWithFormat:@"Music: %@", cell.detailTextLabel.text];
            cell.accessibilityHint = @"Double tap to change.";
        }
        
    } else if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.accessibilityLabel = [NSString stringWithFormat:@"Unlimited Session Duration: %@", sessionEnabled ? @"Off" : @"On"];
            cell.accessibilityHint = @"Double tap to toggle.";
        }
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImage *disclosure = [UIImage imageNamed:@"disclosure.png"];
        cell.accessoryView = [[UIImageView alloc] initWithImage:disclosure];
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"changeMusic"]) {
        ((CBChangeMusicViewController *) segue.destinationViewController).delegate = self;
    } else if ([segue.identifier isEqualToString:@"changeBackground"]) {
        ((CBChangeBackgroundViewController *) segue.destinationViewController).delegate = self;
    } else {
        CBChangeDurationViewController *ctrl = (CBChangeDurationViewController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"inhale"]) {
            ctrl.durationType = CBDurationTypeInhale;
        } else if ([segue.identifier isEqualToString:@"exhale"]) {
            ctrl.durationType = CBDurationTypeExhale;
        } else if ([segue.identifier isEqualToString:@"rest"]) {
            ctrl.durationType = CBDurationTypeRest;
        } else if ([segue.identifier isEqualToString:@"hold"]) {
            ctrl.durationType = CBDurationTypeHold;
        }
    }
}

- (IBAction)pickerDoneAction:(id)sender {
    int row = (int)[self.externalPickerView selectedRowInComponent:0];
    sessionCell.detailTextLabel.text = [self pickerView:self.externalPickerView titleForRow:row forComponent:0];
    //[defaults setInteger:((row +1) * 60) forKey:@"session_duration"];
    encryptIntForKey(@"session_duration", ((row +1) * 60));
    //[defaults synchronize];
    [self hideExternalPicker];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)musicChanged:(kMusicType)musicType
{
    musicTypeLabel.text = [CBMusicType nameForMusicType:musicType];
    [self.tableView reloadData];
    
    //[defaults setInteger:musicType forKey:@"music_type"];
    encryptIntForKey(@"music_type", musicType);
    //[defaults synchronize];
}

- (void)backgroundChanged:(kBackgroundType)type
{
    backgroundTypeLabel.text = [CBBackgroundType nameForBackgroundType:type];
    
    //[defaults setInteger:type forKey:@"background_type"];
    encryptIntForKey(@"background_type", type);
    //[defaults synchronize];
}

- (void)vocalPromptsToggled:(id)sender
{
    //[defaults setBool:vocalPromptsSwitch.on forKey:@"vocal_prompts"];
    encryptBoolForKey(@"vocal_prompts", vocalPromptsSwitch.on);
    //[defaults synchronize];
}

@end
