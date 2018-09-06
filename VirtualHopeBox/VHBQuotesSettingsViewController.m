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

#import "VHBQuotesSettingsViewController.h"
#import "DefaultsWrapper.h"

#define kPickerAnimationDuration    0.40
#define kDatePickerTag 99

@interface VHBQuotesSettingsViewController () {
    UIPopoverController *timePopover;
}

@end

@implementation VHBQuotesSettingsViewController

@synthesize pickerView;
@synthesize reminderEnabled;
@synthesize pickerCellHeight;
@synthesize pickerShown;
@synthesize pickerToolbar;
@synthesize reminderDate;

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
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:@"picker"];
    self.pickerCellHeight = pickerViewCellToCheck.frame.size.height;
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.reminderDate = decryptDateForKey(@"quote_reminder_time");
    BOOL scheduled = decryptBoolForKey(@"quote_reminder_scheduled");
    
    if (self.reminderDate && scheduled) {
        self.reminderEnabled = YES;
    } else {
        unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit;
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:flags fromDate:[[NSDate date] dateByAddingTimeInterval:(60*60)]];
        self.reminderDate = [calendar dateFromComponents:components];
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Daily Reminder";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.reminderEnabled) {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm aaa"];
        [VHBLogUtils logEventType:LETQuotesReminderTime withValue:[dateFormatter stringFromDate:reminderDate]];
        //[defaults setValue:reminderDate forKey:@"quote_reminder_time"];
        encryptDateForKey(@"quote_reminder_time", reminderDate);
        encryptBoolForKey(@"quote_reminder_scheduled", YES);
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate scheduleQuoteNotification];
    } else {
        //Remove other notification
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
        encryptBoolForKey(@"quote_reminder_scheduled", NO);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 1;
    if (reminderEnabled) {
        count++;
        if (pickerShown) {
            count++;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"switch" forIndexPath:indexPath];
        UISwitch *sw = (UISwitch *) [cell viewWithTag:1];
        [sw setOn:self.reminderEnabled];
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"date" forIndexPath:indexPath];
        [self configureDateCell:cell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"picker" forIndexPath:indexPath];
        [self updateDatePicker];
    }
    
    
    return cell;
}

- (void)updateDatePicker
{
    UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
    if (targetedDatePicker != nil)
    {
        [targetedDatePicker setDate:self.reminderDate];
    }
}

- (void)toggleDatePicker
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:2 inSection:0]];
    if (self.pickerShown)
    {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    self.pickerShown = !self.pickerShown;
    
    [self.tableView endUpdates];
}

- (void)showExternalPicker
{
    // the date picker might already be showing, so don't add it to our view
    if (self.pickerView.superview == nil)
    {
        [self.pickerView setDate:self.reminderDate];
        self.tableView.scrollEnabled = NO;
        
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;
        CGRect toolbarStartFrame = self.pickerToolbar.frame;
        CGRect toolbarEndFrame = self.pickerToolbar.frame;
        
        
        
        // the start position is below the bottom of the visible frame
        toolbarStartFrame.origin.y = self.view.frame.size.height;
        startFrame.origin.y = self.view.frame.size.height + self.pickerToolbar.frame.size.height;
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height - toolbarEndFrame.size.height;
        toolbarEndFrame.origin.y = self.view.frame.size.height - endFrame.size.height - toolbarEndFrame.size.height;
        
        self.pickerToolbar.frame = toolbarStartFrame;
        self.pickerView.frame = startFrame;
        
        [self.view addSubview:self.pickerToolbar];
        [self.view addSubview:self.pickerView];
        self.pickerShown = YES;
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{
            self.pickerView.frame = endFrame;
            self.pickerToolbar.frame = toolbarEndFrame;
        }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)configureDateCell:(UITableViewCell *)cell
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm aaa"];
    NSString *dateString = [dateFormatter stringFromDate:self.reminderDate];
    cell.detailTextLabel.text = dateString;
}

- (IBAction)timeChanged:(id)sender {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    self.reminderDate = pickerView.date;
    [self configureDateCell:cell];
}

- (void)hideExternalPicker
{
    self.tableView.scrollEnabled = YES;
    self.pickerShown = NO;
    
    CGRect pickerFrame = self.pickerView.frame;
    CGRect toolbarFrame = self.pickerToolbar.frame;
    pickerFrame.origin.y = self.view.frame.size.height + self.pickerToolbar.frame.size.height;
    toolbarFrame.origin.y = self.view.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{
        self.pickerView.frame = pickerFrame;
        self.pickerToolbar.frame = toolbarFrame;
    }
                     completion:^(BOOL finished) {
                         [self.pickerView removeFromSuperview];
                         [self.pickerToolbar removeFromSuperview];
                     }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!pickerShown || indexPath.row != 2) {
        [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
    }
}

- (IBAction)pickerDoneAction:(id)sender
{
    if (![self hasEmbededPicker]) {
        [self hideExternalPicker];
    }
    
    UIDatePicker *targetedDatePicker;
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        targetedDatePicker = self.pickerView;
    } else {
        targetedDatePicker = sender;
    }
    
    // deselect the current table cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    self.reminderDate = targetedDatePicker.date;
    NSLog(@"Reminder date is %@", reminderDate);
    [self configureDateCell:cell];
    
    [timePopover dismissPopoverAnimated:true];
}

- (BOOL)hasEmbededPicker
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.tableView beginUpdates];
        NSArray *indexPaths = nil;
        if (self.reminderEnabled && self.pickerShown && [self hasEmbededPicker]) {
            indexPaths = @[[NSIndexPath indexPathForRow:1 inSection:0], [NSIndexPath indexPathForRow:2 inSection:0]];
            
        } else {
            indexPaths = @[[NSIndexPath indexPathForRow:1 inSection:0]];
        }
        
        if (self.reminderEnabled) {
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            self.pickerShown = NO;
            
            if (![self hasEmbededPicker] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self hideExternalPicker];
            }
            [VHBLogUtils logEventType:LETQuotesReminderToggle withValue:@"Off"];
        } else {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [VHBLogUtils logEventType:LETQuotesReminderToggle withValue:@"On"];
        }
        
        self.reminderEnabled = !self.reminderEnabled;
        [((UISwitch *) [[tableView cellForRowAtIndexPath:indexPath]  viewWithTag:1]) setOn:self.reminderEnabled animated:YES];
        
        [self.tableView endUpdates];
    } else if (indexPath.row == 1) {
        if ([self hasEmbededPicker]) {
            [self toggleDatePicker];
        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (!timePopover) {
                
                [pickerView setDate:self.reminderDate];
                
                UIViewController *ctrl = [[UIViewController alloc] init];
                ctrl.view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 320, 300)];
                
                CGRect pickerFrame = self.pickerView.frame;
                pickerFrame.origin.y = self.pickerToolbar.frame.size.height;
                
                self.pickerView.frame = pickerFrame;
                ctrl.preferredContentSize = CGSizeMake(320, 300);
                
                [ctrl.view addSubview:self.pickerToolbar];
                [ctrl.view addSubview:self.pickerView];
                
                timePopover = [[UIPopoverController alloc] initWithContentViewController:ctrl];
                timePopover.delegate = self;
                [timePopover presentPopoverFromRect:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        } else {
            [self showExternalPicker];
        }
        [self updateDatePicker];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
    timePopover = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 2 ? self.pickerCellHeight : tableView.rowHeight;
}

@end
