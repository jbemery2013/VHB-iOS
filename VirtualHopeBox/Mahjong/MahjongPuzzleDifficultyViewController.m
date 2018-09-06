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

#import "MahjongPuzzleDifficultyViewController.h"
#import "VHBAppDelegate.h"
#import "MahjongBoardViewController.h"
#import "GradientLayer.h"
#import "MahjongPuzzle.h"
#import "MahjongLayout.h"
#import "DefaultsWrapper.h"

@interface MahjongPuzzleDifficultyViewController () {
    int difficulty;
    UIImage *disclosure;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MahjongPuzzleDifficultyViewController

@synthesize contactsButton = _contactsButton;
@synthesize sectionTitles;
@synthesize difficultyController = _difficultyController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    __managedObjectContext = appDelegate.managedObjectContext;
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbar.tintColor = [UIColor darkGrayColor];
    sectionTitles = [[NSArray alloc] initWithObjects:@"Easy", @"Intermediate", @"Hard", @"Expert", nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MahjongTableCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    disclosure = [UIImage imageNamed:@"disclosure.png"];
    
    [_contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    
    UISegmentedControl *segs = (UISegmentedControl *) _difficultyController.customView;
    
    [[segs.subviews objectAtIndex:3] setAccessibilityLabel:@"Easy Difficulty"];
    [[segs.subviews objectAtIndex:2] setAccessibilityLabel:@"Medium Difficulty"];
    [[segs.subviews objectAtIndex:1] setAccessibilityLabel:@"Hard Difficulty"];
    [[segs.subviews objectAtIndex:0] setAccessibilityLabel:@"Expert Difficulty"];
    
    [segs addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        segs.tintColor = nil;
    }
}

- (void)didChangeSegmentControl:(UISegmentedControl *)control 
{
    difficulty = (int)control.selectedSegmentIndex;
    NSError *error;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    sectionTitles = nil;
    disclosure = nil;
    [self setManagedObjectContext:nil];
    [self setFetchedResultsController:nil];
    [self setDifficultyController:nil];
    [self setContactsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)setDifficulty:(int)value
{
    [((UISegmentedControl *) _difficultyController.customView) setSelectedSegmentIndex:value];
    difficulty = value;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"MahjongTableCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        MahjongBoardViewController *mdvc = (MahjongBoardViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
//        //[self loadDetailView :indexPath :self.detailViewController :mdvc];
//        [mdvc loadBoard];
//    } else {
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        [self.navigationController setToolbarHidden:YES animated:NO];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self loadDetailViewFromIndex:indexPath controller:segue.destinationViewController sender:sender];
    }
}

- (void)loadDetailViewFromIndex:(NSIndexPath *)indexPath controller:(MahjongBoardViewController *)viewController sender:(id)sender
{
    MahjongPuzzle *puzzle = nil;
    if ([sender class] == [MahjongPuzzle class]) {
        puzzle = sender;
    } else {
        puzzle = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    }
    
    MahjongBoard *board = [[MahjongBoard alloc] initWithPuzzle:puzzle];
    [board loadPuzzle];
    [viewController setBoard:board];
   // [viewController setTitle:[NSString stringWithFormat:@"%@ - %@ #%@", [((MahjongLayout *)puzzle.layout) title], [sectionTitles objectAtIndex:difficulty], puzzle.puzzle_name]];
    [viewController setManagedObjectContext:__managedObjectContext];
    
    NSURL *uri = [[puzzle objectID] URIRepresentation];
    //NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:uri];
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:uriData forKey:@"lastPuzzle"];
    encryptStringForKey(@"lastPuzzle", uri.absoluteString);
    //[defaults synchronize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.tableView.bounds;
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [view.layer insertSublayer:bgLayer atIndex:0];
    self.tableView.backgroundView = view;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MahjongPuzzle" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"layout.title" ascending:YES];
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, orderSortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    [fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    MahjongPuzzle *puzzle = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    cell.accessoryView = [[UIImageView alloc] initWithImage:disclosure];
    
    NSString *title = [NSString stringWithFormat:@"%@ - %@ #%d", [((MahjongLayout *)puzzle.layout) title], [sectionTitles objectAtIndex:difficulty], puzzle.order.intValue + 1];
    ((UITextView *) [cell viewWithTag:100]).text = title;
    
    BOOL complete = [puzzle.complete boolValue];
    ((UITextView *) [cell viewWithTag:100]).textColor = complete ? [UIColor lightGrayColor] : [UIColor whiteColor];
    ((UIImageView *) [cell viewWithTag:200]).hidden = !complete;
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", title, complete ? @"Completed" : @"Incomplete"];
}

@end
