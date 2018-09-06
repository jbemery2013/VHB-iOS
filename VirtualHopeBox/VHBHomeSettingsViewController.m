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
#import "VHBHomeSettingsViewController.h"
#import "GradientLayer.h"
#import "DefaultsWrapper.h"


@interface VHBHomeSettingsViewController () {
    
}

@end

@implementation VHBHomeSettingsViewController
@synthesize loggingSwitch;
@synthesize enrolled;

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
    
    enrolled = [ResearchUtility isEnrolled];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)clearUserDefaults
{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    //Set inhale and exhale back to 6 secs for breathing exercise
    initT2Crypto();
    encryptFloatForKey(@"inhale_duration", 6.0);
    encryptFloatForKey(@"exhale_duration", 6.0);
}

- (void)sendFeedback
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"VHB Feedback"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:[NSArray arrayWithObject:@"usarmy.ncr.medcom-usamrmc-dcoe.mbx.t2-central@mail.mil"]];
        [self presentViewController:mail animated:YES completion:nil];
        [VHBLogUtils logEventType:LETSettingsFeedback];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"about"]) {
        [VHBLogUtils logEventType:LETAboutOpen];
    }
}

- (void)rateApp
{
#define YOUR_APP_STORE_ID 825099621 // Change this one to your app ID
    
    static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d?at=10l6dK";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d&at=10l6dK";
    
    NSURL *url;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        url = [NSURL URLWithString:[NSString stringWithFormat:iOS7AppStoreURLFormat, YOUR_APP_STORE_ID]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:iOSAppStoreURLFormat, YOUR_APP_STORE_ID]];
    }
    NSLog(@"Open URL: %@", url);
    [[UIApplication sharedApplication] openURL:url];
    [VHBLogUtils logEventType:LETSettingsRate];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self disenroll];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}

- (void)promptDisenroll
{
    NSString *msgText = [NSString stringWithFormat:@"This action will permanently delete your current usage log, and disenroll you from the study.\n\nWould you like to continue?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disenroll" message:msgText delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.delegate = self;
    [alert show];
}

- (void)disenroll
{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *participantNumber = decryptStringForKey(@"DEFAULTS_PARTICIPANTNUMBER");
    
    if (!participantNumber) {
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"VirtualHopeBox_Participant_%@.csv", participantNumber];
    NSString *finalPath = [NSString stringWithFormat:@"%@/%@",documentsDir, fileName];
    
    NSError *error;
    if ([manager removeItemAtPath:finalPath error:&error]) {
        
    } else {
        NSLog(@"Unable to delete study log: %@", [error localizedDescription]);
    }
    
    eSaveValueForKey(encodeKey, @"", @"DEFAULTS_USE_RESEARCHSTUDY");
    eSaveValueForKey(encodeKey, @"", @"DEFAULTS_PARTICIPANTNUMBER");
    eSaveValueForKey(encodeKey, @"", @"DEFAULTS_STUDYEMAIL");
//    [defaults synchronize];
    
    NSString *msgText = [NSString stringWithFormat:@"You have been disenrolled from the Research Study. Your log data has been deleted."];
    UIAlertView *alertBarInfo = [[UIAlertView alloc] initWithTitle:@"Disenrolled" message:msgText delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alertBarInfo show];
    
    enrolled = NO;
    [self.tableView reloadData];
}

- (void)sendStudyLog
{
    if ([MFMailComposeViewController canSendMail]) {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *participantNumber = decryptStringForKey(@"DEFAULTS_PARTICIPANTNUMBER");
        NSString *studyEmail = decryptStringForKey(@"DEFAULTS_STUDYEMAIL");
        
        if (!participantNumber) {
            return;
        }
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        NSString *fileName = [NSString stringWithFormat:@"VirtualHopeBox_Participant_%@.csv", participantNumber];
        NSString *finalPath = [NSString stringWithFormat:@"%@/%@",documentsDir, fileName];
        
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Virtual Hope Box Study Log - Participant %@", participantNumber]];
        [mail setMessageBody:@"See attached \"Virtual Hope Box\" Study Data." isHTML:NO];
        [mail setToRecipients:@[studyEmail]];
        [mail addAttachmentData:[NSData dataWithContentsOfFile:finalPath] mimeType:@"text/csv" fileName:fileName];
        [self presentViewController:mail animated:YES completion:nil];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return enrolled ? 2 : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self clearUserDefaults];
                    break;
                case 1:
                    [self sendFeedback];
                    break;
                case 2:
                    [self rateApp];
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self sendStudyLog];
                    break;
                case 1:
                    [self promptDisenroll];
                    break;
            }
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        //        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        //        NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
        //        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        //        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LogEntry" inManagedObjectContext:managedObjectContext];
        //        [fetchRequest setEntity:entity];
        //
        //        [fetchRequest setFetchBatchSize:100];
        //
        //        NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
        //        NSArray *sortDescriptors = [NSArray arrayWithObjects:orderSortDescriptor, nil];
        //
        //        [fetchRequest setSortDescriptors:sortDescriptors];
        //
        //        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
        //
        //        NSError *error = nil;
        //        if (![fetchedResultsController performFetch:&error]) {
        //            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //            abort();
        //        }
        //
        //        NSString *dir = NSTemporaryDirectory();
        //        NSString *file = [NSString stringWithFormat:@"%@/vhb_log.csv", dir];
        //        NSMutableString *csv = [[NSMutableString alloc] init];
        //        for (LogEntry *entry in fetchedResultsController.fetchedObjects) {
        //            [csv appendFormat:@"%@, %@, %@\n", entry.dateCreated, entry.type, entry.data];
        //        }
        //
        //        [csv writeToFile:file atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
        //
        //        NSLog(@"docs: %@", [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil]);
        //
        //        if ([MFMailComposeViewController canSendMail]) {
        //            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        //            mail.mailComposeDelegate = self;
        //            [mail setSubject:@"VHB Log Attached"];
        //            [mail setMessageBody:@"Attached is a VHB Log CSV" isHTML:NO];
        //            [mail setToRecipients:[NSArray arrayWithObject:@"hopeboxstudy@gmail.com"]];
        //            [mail addAttachmentData:[NSData dataWithContentsOfFile:file] mimeType:@"text/csv" fileName:@"vhb_log.csv"];
        //            [self presentModalViewController:mail animated:YES];
        //        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
