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

#import "VHBSetupContactsViewController.h"

@interface VHBSetupContactsViewController () {
    ABAddressBookRef addressBook;
    UIPopoverController *popoverController;
    NSDate *sessionStart;
}

@end

@implementation VHBSetupContactsViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;
@synthesize longTapRecognizer;
@synthesize longTapSheet;
@synthesize longTapContact;
@synthesize peoplePickerController;
@synthesize personViewController;
@synthesize messageView;
@synthesize tableView;
@synthesize nextButton;
@synthesize addButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    CFRelease(addressBook);
    popoverController = nil;
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [self setLongTapSheet:nil];
    [self setLongTapRecognizer:nil];
    [self setLongTapContact:nil];
    [self setPersonViewController:nil];
    [self setPeoplePickerController:nil];
    [self setMessageView:nil];
    [self setTableView:nil];
    [self setNextButton:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self dismissPicker];
    [VHBLogUtils logEvent:@"SETUP_CONTACTS_SESSION" start:sessionStart];
    sessionStart = nil;
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self loadContacts];
    sessionStart = [NSDate date];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    addButton.accessibilityHint = @"Adds a support contact.";
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:nextButton, addButton, nil]];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
    peoplePickerController.peoplePickerDelegate = self;
    
    personViewController = [[ABPersonViewController alloc] init];
    personViewController.allowsEditing = NO;
    personViewController.addressBook = addressBook;
    personViewController.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
    personViewController.personViewDelegate = self;
    
    addressBook = ABAddressBookCreate();
    
    longTapSheet = [[UIActionSheet alloc] initWithTitle:@"Contact" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Contact" otherButtonTitles: nil];
    longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapCaptured:)];
    [tableView addGestureRecognizer:longTapRecognizer];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VHBContactCell" bundle:nil] forCellReuseIdentifier:@"contactCell"];
    [self loadContacts];
}

- (void)loadContacts
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    [tableView reloadData];
    [self updateTableVisibility:0];
}

- (void)updateTableVisibility:(float)delay {
    nextButton.enabled = [self fetchedResultsController].fetchedObjects.count > 0;
    [UIView animateWithDuration:.5 delay:delay options:0 animations:^{
        if ([self fetchedResultsController].fetchedObjects.count > 0) {
            tableView.alpha = 1;
            messageView.alpha = 0;
        } else {
            tableView.alpha = 0;
            messageView.alpha = 1;
        }
    } completion:^(BOOL finished) {
    }];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Fetched results controller

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
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self updateTableVisibility:0.5];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self updateTableVisibility:0.5];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    static NSString *cellIdentifier = @"contactCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VHBContactCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [managedObjectContext save:nil];
        [VHBLogUtils logEvent:@"CONTACT_REMOVED"];
    }
}

- (ABRecordRef)getPersonForSupportContact:(SupportContact *)contact
{
    NSString *recordId = contact.abRecordID;
    NSInteger numId = recordId.integerValue;
    ABRecordRef contactRef = ABAddressBookGetPersonWithRecordID(addressBook, numId);
    if (!contactRef) {
        NSArray * matchingPeople =(__bridge_transfer NSArray *)ABAddressBookCopyPeopleWithName(addressBook,(__bridge_retained CFStringRef)[NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName]);
        if (matchingPeople && matchingPeople.count > 0) {
            ABRecordRef person = (__bridge ABRecordRef)[matchingPeople objectAtIndex:0];
            contact.firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);    
            contact.lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSInteger recordID = ABRecordGetRecordID(person);
            contact.abRecordID = [NSString stringWithFormat:@"%i", recordID];
        } else {
            // This contact no longer exists...
            [self.managedObjectContext deleteObject:contact];
        }
        [self.managedObjectContext save:nil];
    }
    return contactRef;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    SupportContact *contact = [_fetchedResultsController objectAtIndexPath:indexPath];
    ABRecordRef contactRef = [self getPersonForSupportContact:contact];
    if (contactRef) {
        cell.textLabel.text = (__bridge_transfer NSString *) ABRecordCopyCompositeName(contactRef);
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    SupportContact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"SupportContact" inManagedObjectContext:managedObjectContext];
    NSString *contactFirst = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);    
    NSString *contactLast =  (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSInteger recordID = ABRecordGetRecordID(person);
    contact.abRecordID = [NSString stringWithFormat:@"%i", recordID];
    contact.firstName = contactFirst;
    contact.lastName = contactLast;
    contact.dateCreated = [NSDate date];
    contact.contactType = @"Support Contacts";
    [managedObjectContext save:nil];
    [self dismissPicker];
    [VHBLogUtils logEvent:@"CONTACT_ADDED"];
    
    return NO;
}

- (void) dismissPicker
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [peoplePickerController dismissModalViewControllerAnimated:YES];
    } else {
        [popoverController dismissPopoverAnimated:YES];
    }
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissPicker];
}

- (BOOL) personViewController:(ABPersonViewController*)personView shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    NSString *phone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(multi, identifierForValue);
    CFRelease(multi);
    
    if (phone) {
        NSString *cleanedString = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789-+()"] invertedSet]] componentsJoinedByString:@""];
        NSString *escapedPhoneNumber = [cleanedString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", escapedPhoneNumber]];
        [[UIApplication sharedApplication] openURL:telURL];
    }
    
    [self dismissPicker];
    return NO;
}

- (void)longTapCaptured:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
        if (indexPath) {        
            NSIndexPath *shiftedPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            longTapContact = [_fetchedResultsController objectAtIndexPath:shiftedPath];
            
            [longTapSheet setTitle:[self tableView:self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [longTapSheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapSheet) {
        switch (buttonIndex) {
            case 0:
                [managedObjectContext deleteObject:longTapContact];
                [managedObjectContext save:nil];
                [VHBLogUtils logEvent:@"CONTACT_REMOVED"];
                break;
        }
    }
}

- (IBAction)addClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:peoplePickerController animated:YES];
    } else {
        if (!popoverController) {
            popoverController = [[UIPopoverController alloc] initWithContentViewController:peoplePickerController];
        }
        [popoverController presentPopoverFromBarButtonItem:addButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}
@end
