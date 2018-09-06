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

#import "VHBContactsViewController.h"
#import "GradientLayer.h"

@interface VHBContactsViewController () {
    ABAddressBookRef addressBook;
    MFMailComposeViewController *composeView;
    UIPopoverController *popoverController;
    NSURL *selectedNumber;
    BOOL hasPhone, hasEmail;
}

@end

@implementation VHBContactsViewController
@synthesize addButton;

@synthesize longTapContact;
@synthesize longTapRecognizer;
@synthesize longTapSheet;
@synthesize peoplePickerController;
@synthesize personViewController;
@synthesize hotlineNames, hotlineNumbers, hotlineAccessibilityNames;
@synthesize managedObjectContext;
@synthesize helpView;
@synthesize tableView;
@synthesize fetchedResultsController = _fetchedResultsController;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    hasPhone = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:+11111"]];
    hasEmail = [MFMailComposeViewController canSendMail];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;

    addButton.accessibilityHint = @"Add a support contact.";
    
    peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerController.peoplePickerDelegate = self;
    
    addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    longTapSheet = [[UIActionSheet alloc] initWithTitle:@"Contact" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Contact" otherButtonTitles: nil];
    longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapCaptured:)];
    [self.tableView addGestureRecognizer:longTapRecognizer];
    
    hotlineNames = [[NSArray alloc] initWithObjects:@"911", @"Veterans Crisis Line (EN)", @"Veterans Crisis Line (SP)", @"DCoE Outreach Center", nil];
    hotlineNumbers = [[NSArray alloc] initWithObjects:[NSURL URLWithString:@"tel://911"], [NSURL URLWithString:@"tel://1-800-273-8255"], [NSURL URLWithString:@"tel://1-888-628-9454"], [NSURL URLWithString:@"tel://1-866-966-1020"], nil];
    hotlineAccessibilityNames = @[@"9,1,1", @"Veterans Crisis Line: English", @"Veterans Crisis Line: Spanish", @"Deecoe Outreach Center"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VHBContactCell" bundle:nil] forCellReuseIdentifier:@"contactCell"];
    
    [self loadContacts];
    
    [self updateHelpVisibility:NO];
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tv titleForHeaderInSection:section].length == 0) {
        return 20;
    }
    return 44;
}

- (void)updateHelpVisibility:(BOOL)animated
{
    float duration = 0;
    if (animated) {
        duration = .3;
    }
    
    if (_fetchedResultsController.fetchedObjects.count > 0) {
        self.tableView.userInteractionEnabled = YES;
        [UIView animateWithDuration:duration animations:^{
            self.tableView.alpha = 1;
            self.helpView.alpha = 0;
        }];
    } else if (_fetchedResultsController.fetchedObjects.count == 0) {
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:duration animations:^{
            self.tableView.alpha = 0;
            self.helpView.alpha = 1;
        }];
    }
}

- (IBAction)okClicked:(id)sender {
    self.tableView.userInteractionEnabled = YES;
    [UIView animateWithDuration:.4 animations:^{
        self.tableView.alpha = 1;
        self.helpView.alpha = 0;
    }];
}

- (void)loadContacts
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    CFRelease(addressBook);
    popoverController = nil;
    peoplePickerController = nil;
    personViewController = nil;
    hotlineNumbers = nil;
    hotlineNames = nil;
    longTapContact = nil;
    longTapRecognizer = nil;
    longTapSheet = nil;
    selectedNumber = nil;
    
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];

    [self setAddButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [self loadContacts];
    [self updateHelpVisibility:NO];
    
    [VHBLogUtils logEventType:LETContactsOpen];
    [VHBLogUtils startTimedEvent:LETContactsClose];
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tv.frame.size.width, 40)];
    
    UILabel *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, tv.frame.size.width - 40, 40)];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, tv.frame.size.width - 100, 40)];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor colorWithWhite:.2 alpha:1];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview: label];
    return view;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self dismissPeoplePicker];
    [self dismissMail];
    self.fetchedResultsController.delegate = nil;  
    self.fetchedResultsController = nil;
    
    [VHBLogUtils endTimedEvent:LETContactsClose];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) dismissPeoplePicker
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        /* iOS 8 Bug Fix #2805 - Mel Manzano 11/5/14 */
        // Added 'isBeingPresented' check required by iOS 8
        if (![self.peoplePickerController isBeingPresented]) {
            [peoplePickerController dismissViewControllerAnimated:YES completion:nil];
        }
    } else {
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void) dismissMail
{
    [composeView dismissViewControllerAnimated:YES completion:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SupportContact" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];

    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"contactType" cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{  
    NSUInteger shiftedSectionIndex = sectionIndex + 1;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:shiftedSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:shiftedSectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tv = self.tableView;
    
    NSIndexPath *shiftedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
    NSIndexPath *newShiftedPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section+1];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newShiftedPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:shiftedPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:shiftedPath] atIndexPath:shiftedPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:shiftedPath] withRowAnimation:UITableViewRowAnimationFade];
            [tv insertRowsAtIndexPaths:[NSArray arrayWithObject:newShiftedPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
    
    [self updateHelpVisibility:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]];
        
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
//        [managedObjectContext save:nil];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_fetchedResultsController sections].count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // Return the number of rows in the section.
    if (section == 0) {
        return hotlineNames.count;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section-1];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && !hasPhone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = [hotlineNames objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:.6 alpha:1];
        cell.detailTextLabel.text = [[(NSURL *)[hotlineNumbers objectAtIndex:indexPath.row] absoluteString] substringFromIndex:6];
        cell.accessibilityLabel = [hotlineAccessibilityNames objectAtIndex:indexPath.row];
        cell.accessibilityHint = @"Double tap to call or view number.";
        return cell;
    }
    
    static NSString *cellIdentifier = @"contactCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VHBContactCell" owner:nil options:nil] objectAtIndex:0];
    }
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{ 
    if (section == 0) {
        return @"Emergency Hotlines";
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section-1];
    return [sectionInfo name];
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (!hasPhone && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [tv deselectRowAtIndexPath:indexPath animated:YES];
            return;
        } else if (!hasPhone) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[hotlineNames objectAtIndex:indexPath.row] message:[[(NSURL *)[hotlineNumbers objectAtIndex:indexPath.row] absoluteString] substringFromIndex:6] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [tv deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contacting Support" message:[NSString stringWithFormat:@"You are about to leave the Virtual Hope Box application to make a call to '%@'.", [hotlineNames objectAtIndex:indexPath.row]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            selectedNumber = [hotlineNumbers objectAtIndex:indexPath.row];
            [VHBLogUtils logEventType:LETEmergencyHotlineDial withValue:[hotlineNames objectAtIndex:indexPath.row]];
            [alert show];
        }
    } else {
        NSIndexPath *shiftedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        SupportContact *contact = [_fetchedResultsController objectAtIndexPath:shiftedPath];
        ABRecordRef contactRef = [self getPersonForSupportContact:contact];
        personViewController = [[ABPersonViewController alloc] init];
        personViewController.allowsEditing = NO;
        personViewController.addressBook = addressBook;
        personViewController.displayedProperties = @[[NSNumber numberWithInt:kABPersonPhoneProperty], [NSNumber numberWithInt:kABPersonEmailProperty]];
        personViewController.personViewDelegate = self;
        personViewController.displayedPerson = contactRef;
        [self.navigationController pushViewController:personViewController animated:YES];
        [VHBLogUtils logEventType:LETContactsDial];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"OK"]) {
        [[UIApplication sharedApplication] openURL:selectedNumber];
    } else {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }

}

- (ABRecordRef)getPersonForSupportContact:(SupportContact *)contact
{
    NSString *recordId = contact.abRecordID;
    NSInteger numId = recordId.integerValue;
    ABRecordRef contactRef = ABAddressBookGetPersonWithRecordID(addressBook, (int)numId);
    NSLog(@"contactRef: %@", contactRef);

    if (!contactRef) {
        NSArray *matchingPeople =(__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(addressBook,(__bridge  CFStringRef)[NSString stringWithFormat:@"%@ %@", dRaw(encodeKey, contact.firstName), (contact.lastName != nil ? dRaw(encodeKey, contact.lastName) : @"")]);
        if (matchingPeople && matchingPeople.count > 0) {
            ABRecordRef person = (__bridge ABRecordRef)[matchingPeople objectAtIndex:0];
            contact.firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);    
            contact.lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSInteger recordID = ABRecordGetRecordID(person);
            
            /* iOS 8 Bug Fix #2805 - Mel Manzano 11/6/14 */
            // Fixed recordID type warning
            contact.abRecordID = [NSString stringWithFormat:@"%li", (long)recordID];
            
            //encrypt contact first and last name
            contact.firstName = eRaw(encodeKey, contact.firstName);
            if (contact.lastName != nil) {
                contact.lastName = eRaw(encodeKey, contact.lastName);
            }
        } else {
            [self.managedObjectContext deleteObject:contact];
        }
        
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
//        [self.managedObjectContext save:nil];
    }

    return contactRef;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        cell.textLabel.text = [hotlineNames objectAtIndex:indexPath.row];
        cell.accessibilityLabel = [hotlineAccessibilityNames objectAtIndex:indexPath.row];
    } else {
        
        NSIndexPath *shiftedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        SupportContact *contact = [_fetchedResultsController objectAtIndexPath:shiftedPath];
        NSLog(@"contact: %@", contact);
        
        ABRecordRef contactRef = [self getPersonForSupportContact:contact];
        if (contactRef) {
            cell.textLabel.text = (__bridge_transfer NSString *) ABRecordCopyCompositeName(contactRef);
        }
    }
    
    cell.accessibilityHint = @"Double tap to contact or view number.";
}

- (IBAction)addButtonClicked:(id)sender {
    
    /* iOS 8 Bug Fix #2805 - Mel Manzano 11/6/14 */
    // Check Authorization
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        // Denied - Show Alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UnAuthorized" message:@"This application does not have permissions to access your contact list.  Please change your permissions in Settings to add a contact." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        // Authorized - Open Contacts
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:peoplePickerController animated:YES completion:nil];
        } else {
            if (!popoverController) {
                popoverController = [[UIPopoverController alloc] initWithContentViewController:peoplePickerController];
            }
            [popoverController presentPopoverFromBarButtonItem:addButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    else
    {
        // Not determined - Request Authorization - Open Contacts if granted
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error)
        {
            if (!granted)
            {
                // Return if permission not granted
                return;
            }
            
            // Permission granted
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentViewController:peoplePickerController animated:YES completion:nil];
            } else {
                if (!popoverController) {
                    popoverController = [[UIPopoverController alloc] initWithContentViewController:peoplePickerController];
                }
                [popoverController presentPopoverFromBarButtonItem:addButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        });
    }
}

// iOS versions before 8.0
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    NSInteger recordId = ABRecordGetRecordID(person);
    /* iOS 8 Bug Fix #2805 - Mel Manzano 11/6/14 */
    // Fixed recordID type warning
    NSString *recordIdString = [NSString stringWithFormat:@"%li", (long)recordId];
    for (SupportContact *other in self.fetchedResultsController.fetchedObjects) {
        if ([other.abRecordID isEqualToString:recordIdString]) {
            [self dismissPeoplePicker];
        }
    }
    
    SupportContact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"SupportContact" inManagedObjectContext:managedObjectContext];
    
    
    NSString *contactFirst = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *contactLast =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSLog(@"contactFirst: %@", contactFirst);
    NSLog(@"contactLast: %@",contactLast);
    
    contact.abRecordID = recordIdString;
    contact.firstName = eRaw(encodeKey, contactFirst);
    if (contactLast != nil) {
        contact.lastName = eRaw(encodeKey, contactLast);
    }
    contact.dateCreated = [NSDate date];
    contact.contactType = @"Support Contacts";
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    [managedObjectContext save:nil];
    [VHBLogUtils logEventType:LETContactsAdd];
    [self dismissPeoplePicker];
    
    return NO;
}


/* iOS 8 Bug Fix #2805 - Mel Manzano 11/5/14 */
// iOS 8+
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{

    NSInteger recordId = ABRecordGetRecordID(person);
    /* iOS 8 Bug Fix #2805 - Mel Manzano 11/6/14 */
    // Fixed recordID type warning
    NSString *recordIdString = [NSString stringWithFormat:@"%li", (long)recordId];
    for (SupportContact *other in self.fetchedResultsController.fetchedObjects) {
        if ([other.abRecordID isEqualToString:recordIdString]) {
            [self dismissPeoplePicker];
        }
    }
    
    SupportContact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"SupportContact" inManagedObjectContext:managedObjectContext];
    
    
    NSString *contactFirst = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *contactLast =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSLog(@"contactFirst: %@", contactFirst);
    NSLog(@"contactLast: %@",contactLast);

    contact.abRecordID = recordIdString;
    contact.firstName = eRaw(encodeKey, contactFirst);
    if (contactLast != nil) {
        contact.lastName = eRaw(encodeKey, contactLast);
    }
    contact.dateCreated = [NSDate date];
    contact.contactType = @"Support Contacts";
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    [managedObjectContext save:nil];
    [VHBLogUtils logEventType:LETContactsAdd];
    [self dismissPeoplePicker];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissPeoplePicker];
}

- (BOOL) personViewController:(ABPersonViewController*)personView shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    if (property == kABPersonPhoneProperty) {
        if (!hasPhone) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Phone Unavailable" message:@"This device does not support making phone calls." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        NSString *phone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(multi, identifierForValue);
        CFRelease(multi);
        
        if (phone) {
            NSString *cleanedString = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
            NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
            [[UIApplication sharedApplication] openURL:telURL];
        }
    } else if (property == kABPersonEmailProperty) {
        if (!hasEmail) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Unavailable" message:@"Unable to send mail. No accounts configured." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        NSString *email = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(multi, identifierForValue);
        CFRelease(multi);
        
        if (email) {
            composeView = [[MFMailComposeViewController alloc] init];
            [composeView setMailComposeDelegate:self];
            [composeView setToRecipients:[NSArray arrayWithObject:email]];
            [self presentViewController:composeView animated:YES completion:nil];
        }
    }
    
    [personViewController.navigationController popViewControllerAnimated:YES];
    return NO;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissMail];
}

- (void)longTapCaptured:(UILongPressGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath) {
        if (indexPath.section == 0) {
            return;
        }
        
        NSIndexPath *shiftedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
        longTapContact = [_fetchedResultsController objectAtIndexPath:shiftedPath];
        
        [longTapSheet setTitle:[self tableView:self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [longTapSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapSheet) {
        switch (buttonIndex) {
            case 0:
                [managedObjectContext deleteObject:longTapContact];
                VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate saveContext];
//                [managedObjectContext save:nil];
                [VHBLogUtils logEventType:LETContactsRemove];
                break;
        }
    }
}

@end
