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

#import "APCreateEventViewController.h"

#define kPickerAnimationDuration    0.40
#define kDatePickerTag              99



@interface APCreateEventViewController () {
    BOOL smsEnabled, mailEnabled, pickerShown, externalPickerShown;
    UIImage *disclosure;
    UIPopoverController *popover, *datePopover;
}

@end

@implementation APCreateEventViewController

@synthesize peoplePicker;
@synthesize longPressRecognizer;
@synthesize longPressActionSheet;
@synthesize selectedInvitee;
@synthesize contactsButton;
@synthesize pickerToolbar;
@synthesize doneButton;
@synthesize activity;

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
    
    disclosure = [UIImage imageNamed:@"disclosure.png"];
    
    activity = [[APActivity alloc] init];
    
    longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCaptured:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
    
    longPressActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Invite" otherButtonTitles: nil];
    
    [contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    [doneButton setAccessibilityHint:NSLocalizedString(@"Sends invitations.", @"")];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:contactsButton, doneButton, nil]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"APActivityCell" bundle:nil] forCellReuseIdentifier:@"ActivityCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"APDateCell" bundle:nil] forCellReuseIdentifier:@"DateCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"APInviteCell" bundle:nil] forCellReuseIdentifier:@"InviteCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"APInviteeCell" bundle:nil] forCellReuseIdentifier:@"InviteeCell"];
    
    self.pickerView.minimumDate = [NSDate date];
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:@"PickerCell"];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
    
    mailEnabled = YES;//[MFMailComposeViewController canSendMail];
    smsEnabled = YES;//[MFMessageComposeViewController canSendText];
}

- (void)toggleDatePicker
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:2 inSection:0]];
    if (pickerShown)
    {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    pickerShown = !pickerShown;
    
    [self.tableView endUpdates];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    disclosure = nil;
    contactsButton = nil;
    doneButton = nil;
    peoplePicker = nil;
    activity = nil;
    longPressActionSheet = nil;
    longPressRecognizer = nil;
    selectedInvitee = nil;
}

- (void)longPressCaptured:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"%@",NSStringFromCGPoint([[gestureRecognizer valueForKey:@"_startPointScreen"] CGPointValue]));
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:point];
        
        NSMutableArray *invitees;
        if (path.section == 1 && smsEnabled) {
            invitees = activity.phoneInvitees;
        } else if (path.section > 0) {
            invitees = activity.emailInvitees;
        }
        
        if (invitees.count == 0) {
            return;
        }
        APInvitee *invitee = [invitees objectAtIndex:path.row];
        longPressActionSheet.title = invitee.contact;
        selectedInvitee = path;
        [longPressActionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSMutableArray *invitees = (smsEnabled && selectedInvitee.section == 1) ? activity.phoneInvitees : activity.emailInvitees;
        [invitees removeObjectAtIndex:selectedInvitee.row];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:selectedInvitee] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (!lastName) {
        lastName = @"";
    }
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    APInvitee *invitee = [[APInvitee alloc] init];
    invitee.name = name;
    
    if (property == kABPersonEmailProperty) {
        ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiEmails); i++) {
            if(identifier == ABMultiValueGetIdentifierAtIndex (multiEmails, i)) {
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                
                invitee.contact = (__bridge_transfer NSString *) emailRef;
                if (![activity.emailInvitees containsObject:invitee]) {
                    [activity.emailInvitees addObject:invitee];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:activity.emailInvitees.count - 1 inSection:(smsEnabled ? 2 : 1)]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
        CFRelease(multiEmails);
    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef multiPhone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhone); i++) {
            if(identifier == ABMultiValueGetIdentifierAtIndex (multiPhone, i)) {
                CFStringRef phoneRef = ABMultiValueCopyValueAtIndex(multiPhone, i);
                
                invitee.contact = (__bridge_transfer NSString *) phoneRef;
                if (![activity.phoneInvitees containsObject:invitee]) {
                    [activity.phoneInvitees addObject:invitee];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:activity.phoneInvitees.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
        CFRelease(multiPhone);
    }
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(nonnull ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (!lastName) {
        lastName = @"";
    }
    NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    APInvitee *invitee = [[APInvitee alloc] init];
    invitee.name = name;
    
    if (property == kABPersonEmailProperty) {
        ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiEmails); i++) {
            if(identifier == ABMultiValueGetIdentifierAtIndex (multiEmails, i)) {
                CFStringRef emailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                
                invitee.contact = (__bridge_transfer NSString *) emailRef;
                if (![activity.emailInvitees containsObject:invitee]) {
                    [activity.emailInvitees addObject:invitee];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:activity.emailInvitees.count - 1 inSection:(smsEnabled ? 2 : 1)]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
        CFRelease(multiEmails);
    } else if (property == kABPersonPhoneProperty) {
        ABMultiValueRef multiPhone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for(CFIndex i = 0; i < ABMultiValueGetCount(multiPhone); i++) {
            if(identifier == ABMultiValueGetIdentifierAtIndex (multiPhone, i)) {
                CFStringRef phoneRef = ABMultiValueCopyValueAtIndex(multiPhone, i);
                
                invitee.contact = (__bridge_transfer NSString *) phoneRef;
                if (![activity.phoneInvitees containsObject:invitee]) {
                    [activity.phoneInvitees addObject:invitee];
                    [self.tableView beginUpdates];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:activity.phoneInvitees.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
        CFRelease(multiPhone);
    }
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section > 0 && indexPath.row != [tableView numberOfRowsInSection:indexPath.section-1];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 1 && smsEnabled) {
            [activity.phoneInvitees removeObjectAtIndex:indexPath.row];
        } else if (indexPath.section > 0) {
            [activity.emailInvitees removeObjectAtIndex:indexPath.row];
        }
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateEmbededDatePicker
{
    UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
    if (targetedDatePicker != nil)
    {
        [targetedDatePicker setDate:self.activity.startDate];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!pickerShown || (indexPath.row != 2 && indexPath.section != 0)) {
        [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
    }
}


- (void)showExternalPicker
{
    [self.pickerView setDate:self.activity.startDate];
    self.tableView.scrollEnabled = NO;
    
    if (self.pickerView.superview == nil)
    {
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;
        CGRect toolbarStartFrame = self.pickerToolbar.frame;
        CGRect toolbarEndFrame = self.pickerToolbar.frame;
        
        toolbarStartFrame.origin.y = self.view.frame.size.height;
        startFrame.origin.y = self.view.frame.size.height + self.pickerToolbar.frame.size.height;
        
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height - toolbarEndFrame.size.height;
        toolbarEndFrame.origin.y = self.view.frame.size.height - endFrame.size.height - toolbarEndFrame.size.height;
        
        self.pickerToolbar.frame = toolbarStartFrame;
        self.pickerView.frame = startFrame;
        
        [self.view addSubview:self.pickerToolbar];
        [self.view addSubview:self.pickerView];
        externalPickerShown = YES;
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{
            self.pickerView.frame = endFrame;
            self.pickerToolbar.frame = toolbarEndFrame;
        }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)toggleExternalDatePicker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (!datePopover) {
            UIViewController *ctrl = [[UIViewController alloc] init];
            ctrl.view = [[UIView alloc] initWithFrame:self.pickerView.frame];
            ctrl.contentSizeForViewInPopover = self.pickerView.frame.size;
            [ctrl.view addSubview:self.pickerView];
            datePopover = [[UIPopoverController alloc] initWithContentViewController:ctrl];
            
            datePopover.delegate = self;
            [datePopover presentPopoverFromRect:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        if (externalPickerShown) {
            [self hideExternalPicker];
        } else {
            [self showExternalPicker];
        }
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
    datePopover = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = 1;
    if (smsEnabled) {
        count++;
    }
    if (mailEnabled) {
        count++;
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Activity Details";
    } else if (section == 1 && smsEnabled) {
        return @"Text Message Invitees";
    } else if (section == 2 || (section == 1 && !smsEnabled)) {
        return @"Email Invitees";
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return pickerShown ? 4 : 3;
        case 1:
            if (smsEnabled) {
                return activity.phoneInvitees.count;
            } else {
                return activity.emailInvitees.count;
            }
        case 2:
            return activity.emailInvitees.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"APActivityCell" owner:nil options:nil] objectAtIndex:0];
                }
                [self configureIdeaCell:cell];
            } else if (indexPath.row == 1) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"DateCell"];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"APDateCell" owner:nil options:nil] objectAtIndex:0];
                }
                [self configureDateCell:cell];
            } else if (pickerShown && indexPath.row == 2) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"PickerCell"];
                UIDatePicker *picker = (UIDatePicker *)[cell viewWithTag:kDatePickerTag];
                picker.minimumDate = [NSDate date];
            } else if ((!pickerShown && indexPath.row == 2) || indexPath.row == 3) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell"];
                if (!cell) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"APInviteCell" owner:nil options:nil] objectAtIndex:0];
                }
            }
            break;
        case 1:
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"InviteeCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"APInviteeCell" owner:nil options:nil] objectAtIndex:0];
            }
            [self configureInviteeCell:cell atIndexPath:indexPath];
            break;
            break;
    }
    
    if (indexPath.section != 0 || indexPath.row != 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:disclosure];
    }
    
    return cell;
}

- (IBAction)dateChanged:(id)sender {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    self.activity.startDate = self.pickerView.date;
    [self configureDateCell:cell];
}

- (IBAction)pickerDoneAction:(id)sender
{
    if (![self hasEmbededPicker]) {
        [self hideExternalPicker];
    }

    UIDatePicker *targetedDatePicker = [self hasEmbededPicker] ? sender : self.pickerView;
    
    // deselect the current table cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    self.activity.startDate = targetedDatePicker.date;
    [self configureDateCell:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 && pickerShown && indexPath.row == 2 ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

- (void)configureDateCell:(UITableViewCell *)cell
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d h:mm aaa"];
    NSString *dateString = [dateFormatter stringFromDate:activity.startDate];
    cell.detailTextLabel.text = dateString;
}

- (void)configureInviteeCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *invitees;
    if (indexPath.section == 1 && smsEnabled) {
        invitees = activity.phoneInvitees;
    } else {
        invitees = activity.emailInvitees;
    }
    
    APInvitee *invitee = [invitees objectAtIndex:indexPath.row];
    cell.textLabel.text = invitee.name;
    cell.detailTextLabel.text = invitee.contact;
}

- (void)hideExternalPicker
{
    self.tableView.scrollEnabled = YES;
    externalPickerShown = NO;
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"changeIdea"]) {
        APSelectActivityViewController *destination = segue.destinationViewController;
        destination.delegate = self;
    } else if ([segue.identifier isEqualToString:@"activityComplete"]) {
        APCompletedViewController *destination = segue.destinationViewController;
        destination.activity = activity;
    }
}

- (void)configureIdeaCell:(UITableViewCell *)cell
{
    cell.detailTextLabel.text = activity.idea ? dRaw(encodeKey, activity.idea.name) : @"None";
}


- (void)ideaChanged:(ActivityIdea *)idea
{
    activity.idea = idea;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)hasEmbededPicker
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"changeIdea" sender:self];
        } else if (indexPath.row == 1) {
            if ([self hasEmbededPicker]) {
                [self toggleDatePicker];
            } else {
                [self toggleExternalDatePicker];
            }
            [self updateEmbededDatePicker];
        } else if ((!pickerShown && indexPath.row == 2) || indexPath.row == 3) {
            peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
            peoplePicker.peoplePickerDelegate = self;
            peoplePicker.delegate = nil;
            
            NSMutableArray *properties = [[NSMutableArray alloc] init];
            
            if (smsEnabled) {
                [properties addObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
            }
            
            if (mailEnabled) {
                [properties addObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
            }
            
            [peoplePicker setDisplayedProperties:properties];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                popover = [[UIPopoverController alloc] initWithContentViewController:peoplePicker];
                [popover presentPopoverFromRect:[tableView cellForRowAtIndexPath:indexPath].frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self presentViewController:peoplePicker animated:YES completion:nil];
            }
            
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)doneClicked:(id)sender {
    [self performSegueWithIdentifier:@"activityComplete" sender:self];
}
@end
