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

#import "APCompletedViewController.h"

@interface APCompletedViewController () {
    BOOL mailEnabled, smsEnabled;
    UIImage *disclosure, *checkmark;
}

@end

@implementation APCompletedViewController

@synthesize messageTextView;
@synthesize contactsButton;
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
    [contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    checkmark = [UIImage imageNamed:@"card_check"];
    disclosure = [UIImage imageNamed:@"disclosure.png"];
    messageTextView.text = [self getInviteMessage];
    mailEnabled = activity.emailInvitees.count > 0;// && [MFMailComposeViewController canSendMail];
    smsEnabled = activity.phoneInvitees.count > 0;// && [MFMessageComposeViewController canSendText];
}

- (void)viewDidUnload
{
    checkmark = nil;
    disclosure = nil;
    [self setMessageTextView:nil];
    [self setContactsButton:nil];
    [super viewDidUnload];
    [self setActivity:nil];
}

- (BOOL)hasInvitees
{
    return mailEnabled || smsEnabled;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self hasInvitees]) {
        return [super tableView:tableView titleForHeaderInSection:section];
    } else {
        return [super tableView:tableView titleForHeaderInSection:1];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self hasInvitees]) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:1]];    
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self hasInvitees]) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInvitees] && section == 0) {
        return 1;
    } else {
        int count = 1;
        count += mailEnabled ? 1 : 0;
        count += smsEnabled ? 1 : 0;
        return count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if ([self hasInvitees]) {
        if (indexPath.section == 1 && indexPath.row == 1) {
            if (!mailEnabled) {
                cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
            }
        }
        
        if (!cell) {
            cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
            if (indexPath.section == 0 && indexPath.row == 0) {
                UITextView *view = (UITextView *)[cell viewWithTag:1];
                view.delegate = self;
                view.text = messageTextView.text;
            }
        }
    } else {
        cell = [super tableView:tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:disclosure];
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:checkmark];
    }
    
    return cell;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {  
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (NSString *)getInviteMessage
{
    int inviteeCount = (int)(activity.emailInvitees.count + activity.phoneInvitees.count);
    APInvitee *soloInvite;
    if (inviteeCount == 1 && activity.emailInvitees.count == 1) {
        soloInvite = [activity.emailInvitees objectAtIndex:0];
    } else if (inviteeCount == 1 && activity.phoneInvitees.count == 1) {
        soloInvite = [activity.phoneInvitees objectAtIndex:0];
    }
    NSString *msg = soloInvite ? [NSString stringWithFormat:@"Hey %@, ", [[soloInvite.name componentsSeparatedByString:@" "] objectAtIndex:0]] : @"Hey all, ";
    
    NSString *verb = activity.idea.verb ? [NSString stringWithFormat:@"%@ ", dRaw(encodeKey, activity.idea.verb)] : @"";
    
    NSString *idea = activity.idea ? [dRaw(encodeKey, activity.idea.name) lowercaseString] : @"meet up";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM d 'at' hh:mm aaa"];

    if (activity.idea && !activity.idea.verb) {
        // User created, needs to be more generic
        msg = [NSString stringWithFormat: @"%@%@ with me on %@?", msg, idea, [formatter stringFromDate:activity.startDate]];
    } else {
        msg = [NSString stringWithFormat: @"%@would you like to %@%@ with me on %@?", msg, verb, idea, [formatter stringFromDate:activity.startDate]];
    }
    
    return msg;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(mailEnabled ? 2 : 1) inSection:1]];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:checkmark];
        cell.accessoryView.frame = CGRectMake(0, 0, 20, 25);
        [VHBLogUtils logEventType:LETPlannerCalendar];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)createEvent
{
    EKEventStore *eventDB = [[EKEventStore alloc] init];
    [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if(granted) {
            
            EKEvent *myEvent = [EKEvent eventWithEventStore:eventDB];
            myEvent.title = activity.idea ? dRaw(encodeKey, activity.idea.name) : @"Meet-Up";
            NSMutableString *notes = [[NSMutableString alloc] init];
            [notes appendString:myEvent.title];
            NSMutableSet *nameSet = [[NSMutableSet alloc] init];
            for (APInvitee *invite in activity.phoneInvitees) {
                [nameSet addObject:invite.name];
            }
            for (APInvitee *invite in activity.emailInvitees) {
                [nameSet addObject:invite.name];
            }
            if ([self hasInvitees]) {
                [notes appendString:@" with "];
                [notes appendString:[[nameSet allObjects] componentsJoinedByString:@", "]];
            }
            myEvent.notes = notes;
            myEvent.startDate = activity.startDate;
            // 30 min
            myEvent.endDate = [[NSDate alloc] initWithTimeInterval:60*30 sinceDate:activity.startDate];
            myEvent.allDay = NO;
            
            EKEventEditViewController *editEventController = [[EKEventEditViewController alloc] init];
            editEventController.eventStore = eventDB;
            editEventController.editViewDelegate = self;
            editEventController.event = myEvent;
            
            if ([eventDB respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                [eventDB requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                    if (granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentViewController:editEventController animated:YES completion:nil];
                        });
                    }
                }];
            } else {
                [self presentViewController:editEventController animated:YES completion:nil];
            }
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Calendars Access Denied"
                                        message:@"Creating a calendar event requires access to your calendar.\n\n Please enable Calendar access in Settings / VirtualHopeBox / Calendars"
                                       delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles:nil] show];
        }
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    if (action == EKEventEditViewActionSaved) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self hasInvitees] ? 1 : 0]];

        cell.accessoryView = [[UIImageView alloc] initWithImage:checkmark];
        cell.accessoryView.frame = CGRectMake(0, 0, 20, 25);
        [VHBLogUtils logEventType:LETPlannerCalendar];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:checkmark];
        cell.accessoryView.frame = CGRectMake(0, 0, 20, 25);
        [VHBLogUtils logEventType:LETPlannerSendEmail];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}


- (void)createSMS
{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *composeView = [[MFMessageComposeViewController alloc] init];
        composeView.messageComposeDelegate = self;
        composeView.body = messageTextView.text;
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        for (APInvitee *invitee in activity.phoneInvitees) {
            [recipients addObject:invitee.contact];
        }
        composeView.recipients = recipients;
        [self presentViewController:composeView animated:YES completion:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Unable to message the invitees"
                                    message:@"Your device appears to be unable to create text messages"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
    }
}

- (void)createMail
{
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeView = [[MFMailComposeViewController alloc] init];
        [composeView setMailComposeDelegate:self];
        [composeView setSubject:(activity.idea ? dRaw(encodeKey, activity.idea.name) : @"Meet-Up")];
        [composeView setMessageBody:messageTextView.text isHTML:NO];
        NSMutableArray *emails = [[NSMutableArray alloc] init];
        for (APInvitee *invite in activity.emailInvitees) {
            [emails addObject:invite.contact];
        }
        [composeView setToRecipients:emails];
        [self presentViewController:composeView animated:YES completion:nil];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Unable to email the invitees"
                                    message:@"Your device appears to be unable to create emails"
                                   delegate:nil
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self hasInvitees]) {
        if (indexPath.section == 0) {
            return;
        } else {
            switch (indexPath.row) {
                case 0:
                    // Calendar
                    [self createEvent];
                    break;
                case 1:
                    // Email or possibly SMS
                    if (mailEnabled) {
                        //Email
                        [self createMail];
                    } else {
                        // SMS
                        [self createSMS];
                    }
                    break;
                case 2:
                    // SMS
                    [self createSMS];
                    break;
                default:
                    break;
            }
        }
    } else {
        // If there are no invites only the calendar option exists
        [self createEvent];
    }
}

@end
