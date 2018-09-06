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

#import "SudokuPuzzlesViewController.h"
#import "SudokuBoardViewController.h"
#import "SudokuPuzzle.h"
#import "VHBAppDelegate.h"
#import "MBProgressHUD.h"
#import "GradientLayer.h"
#import "DefaultsWrapper.h"

@interface SudokuPuzzlesViewController () {
    NSArray *sectionTitles;
    UIImage *disclosure;
    NSMutableDictionary *screenShotMap;
    BOOL scrolling;
    int difficulty;
    BOOL changed;
    NSLock *lock;
    NSIndexPath *selectedPuzzle;
}

@end

@implementation SudokuPuzzlesViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize contactsButton = _contactsButton;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize difficultyController = _difficultyController;

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
    
    lock = [[NSLock alloc] init];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    _backgroundManagedObjectContext = appDelegate.backgroundManagedObjectContext;
    
    self.navigationController.toolbar.translucent = NO;
    self.navigationController.toolbar.tintColor = [UIColor darkGrayColor];
    sectionTitles = [[NSArray alloc] initWithObjects:@"Easy", @"Intermediate", @"Hard", @"Expert", nil];
    
    UISegmentedControl *segs = (UISegmentedControl *) _difficultyController.customView;
    
    [[segs.subviews objectAtIndex:3] setAccessibilityLabel:@"Easy Difficulty"];
    [[segs.subviews objectAtIndex:2] setAccessibilityLabel:@"Medium Difficulty"];
    [[segs.subviews objectAtIndex:1] setAccessibilityLabel:@"Hard Difficulty"];
    [[segs.subviews objectAtIndex:0] setAccessibilityLabel:@"Expert Difficulty"];
    
    difficulty = 0;
    [segs addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        ((UISegmentedControl *) _difficultyController.customView).tintColor = nil;
    }
    
    screenShotMap = [[NSMutableDictionary alloc] init];
    
    disclosure =[UIImage imageNamed:@"disclosure.png"];
    
    [_contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SudokuTableCell" bundle:nil] forCellReuseIdentifier:@"SudokuPuzzleCell"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    scrolling = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.tableView.bounds;
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [view.layer insertSublayer:bgLayer atIndex:0];
    self.tableView.backgroundView = view;
    
    if (selectedPuzzle) {
        [screenShotMap removeObjectForKey:[NSNumber numberWithInt:(int)selectedPuzzle.row]];
        [self configureCell:[self.tableView cellForRowAtIndexPath:selectedPuzzle] atIndexPath:selectedPuzzle];
    }
    
    [self performSelectorInBackground:@selector(loadThumbnails) withObject:nil];
    
}

- (void)didChangeSegmentControl:(UISegmentedControl *)control
{
    changed = YES;
    difficulty = (int)control.selectedSegmentIndex;
    NSError *error;
    
    [screenShotMap removeAllObjects];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    [self performSelectorInBackground:@selector(loadThumbnails) withObject:nil];
    
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"viewPuzzle"] || [[segue identifier] isEqualToString:@"viewDefaultPuzzle"]) {
        [self.navigationController setToolbarHidden:YES animated:YES];
        selectedPuzzle = [self.tableView indexPathForSelectedRow];
        SudokuBoardViewController *bvc = [segue destinationViewController];
        bvc.managedObjectContext = _managedObjectContext;
        
        SudokuPuzzle *puzzle = (SudokuPuzzle *) sender;
        [self loadPuzzle:puzzle controller:bvc];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    // Return the number of rows in the section.
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SudokuPuzzleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SudokuTableCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    
    return cell;
}

- (void)loadPuzzle:(SudokuPuzzle *)puzzle controller:(SudokuBoardViewController *)bvc
{
    //[bvc setTitle:[NSString stringWithFormat:@"%@ #%i",[sectionTitles objectAtIndex:difficulty]]];
    
    SudokuBoard *board = [[SudokuBoard alloc] init];
    [board loadPuzzle:puzzle];
    [bvc setManagedObjectContext:_managedObjectContext];
    [bvc setBoard:board];
    
    NSURL *uri = [[puzzle objectID] URIRepresentation];
    //NSData *uriData = [NSKeyedArchiver archivedDataWithRootObject:uri];
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:uriData forKey:@"lastPuzzle"];
    encryptStringForKey(@"lastPuzzle", uri.absoluteString);
    //[defaults synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SudokuPuzzle *puzzle = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"viewPuzzle" sender:puzzle];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SudokuPuzzle" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:50];
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:orderSortDescriptor, nil];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadScreenshots];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self loadScreenshots];
    }
}

- (void)loadScreenshots
{
    scrolling = NO;
    //[self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    scrolling = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrolling = YES;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.accessoryView = [[UIImageView alloc] initWithImage:disclosure];
    
    UIImageView *img = ((UIImageView *)[cell viewWithTag:102]);
    img.image = nil;
    NSNumber *key = [NSNumber numberWithInt:(int)indexPath.row];
    if ([screenShotMap objectForKey:key]) {
        ((UIImageView *)[cell viewWithTag:102]).image = [screenShotMap objectForKey:key];
        [MBProgressHUD hideHUDForView:[cell viewWithTag:102] animated:NO];
    } else if (![MBProgressHUD HUDForView:img]) {
        [MBProgressHUD showHUDAddedTo:img animated:NO];
    }
    
    SudokuPuzzle *puzzle = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
    BOOL complete = puzzle.complete != nil && puzzle.complete.intValue != 0;
    [((UIImageView *)[cell viewWithTag:103]) setHidden:!complete];
    NSString *title = [NSString stringWithFormat:@"%@  #%li",[sectionTitles objectAtIndex:difficulty],indexPath.row + 1];
    ((UILabel *)[cell viewWithTag:101]).text = title;
    cell.accessibilityLabel = [NSString stringWithFormat:@"%@, %@", title, complete ? @"Completed" : @"Incomplete"];
}

- (void)loadThumbnails
{
    NSLog(@"%s", __func__);
    [lock lock];
    changed = NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SudokuPuzzle" inManagedObjectContext:_backgroundManagedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:50];
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:orderSortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_backgroundManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
	NSError *error = nil;
	if (![fetch performFetch:&error]) {
        [lock unlock];
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    SudokuPuzzle *puzzle;
    SudokuBoardView *screenshotView;
    SudokuBoard *screenshotBoard = [[SudokuBoard alloc] init];
    NSNumber *key;
    
    for (int i = 0; i < fetch.fetchedObjects.count; i++) {
        key = [NSNumber numberWithInt:i];
        if ([screenShotMap objectForKey:key]) {
            continue;
        }
        
        if (changed) {
            break;
        }
        
        puzzle = [fetch.fetchedObjects objectAtIndex:i];
        screenshotView = [[SudokuBoardView alloc] initForScreenshot:CGRectMake(0, 0, 320, 320)];
        screenshotView.highlightEnabled = false;
        [screenshotView setBackgroundColor:[UIColor whiteColor]];
        [screenshotBoard loadPuzzle:puzzle];
        [screenshotView setBoard:screenshotBoard];
        [screenshotView setNeedsDisplay];
        UIImage *screen = [screenshotView getScreenshot];
        [screenShotMap setObject:screen forKey:key];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
        [self performSelectorOnMainThread:@selector(updateThumbnail:) withObject:path waitUntilDone:YES];
    }
    [lock unlock];
}

- (void)updateThumbnail:(NSIndexPath *)path
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    ((UIImageView *)[cell viewWithTag:102]).image = [screenShotMap objectForKey:[NSNumber numberWithInt:(int)path.row]];
    [MBProgressHUD hideHUDForView:[cell viewWithTag:102] animated:NO];
}

@end
