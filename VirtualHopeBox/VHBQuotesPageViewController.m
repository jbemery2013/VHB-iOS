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

#import "VHBQuotesPageViewController.h"

@interface VHBQuotesPageViewController () {
    int favoriteCount;
}

@end

@implementation VHBQuotesPageViewController
@synthesize addButton;
@synthesize settingsButton;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext;
@synthesize longTapSheet, longTapRecognizer, longTapQuote;
@synthesize orderIndices;
@synthesize initialQuote;
@synthesize currentIndex, nextIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    longTapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapCaptured:)];
    [self.view addGestureRecognizer:longTapRecognizer];
    
    self.dataSource = self;
    self.delegate = self;
    
    [settingsButton setAccessibilityLabel:NSLocalizedString(@"Settings", @"")];
    [addButton setAccessibilityHint:NSLocalizedString(@"Double tap to add a quote.", @"")];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: settingsButton, addButton, nil] animated:YES];
    
    UIViewController *ctrl = [self viewControllerAtIndex:0];
    NSArray *ctrls;
    if (ctrl != nil) {
        ctrls = [NSArray arrayWithObject:ctrl];
        [self setViewControllers:ctrls direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    VHBQuoteViewController *ctrl = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? [[VHBQuoteViewController alloc] initWithNibName:@"VHBQuoteViewController" bundle:nil] : [[VHBQuoteViewController alloc] initWithNibName:@"VHBQuoteViewControllerIPad" bundle:nil];
    ctrl.quote = [self.fetchedResultsController.fetchedObjects objectAtIndex:[self getFetchIndex:(int)index]];
    ctrl.index = (int)index;
    ctrl.count = (int)orderIndices.count;
    return ctrl;
}

- (NSInteger)indexOfViewController:(VHBQuoteViewController *)controller
{
    if (orderIndices.count == 0) {
        return 0;
    }
    
    return controller.index;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [VHBLogUtils logEventType:LETQuotesOpen];
    [VHBLogUtils startTimedEvent:LETQuotesClose];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [VHBLogUtils endTimedEvent:LETQuotesClose];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quote" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: orderSortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    
    int count = (int)[_fetchedResultsController.fetchedObjects count];
    orderIndices = [[NSMutableArray alloc] init];
    
    // Fill array with indexes in order
    for (int i = 0; i < count; i++) {
        [orderIndices addObject:[NSNumber numberWithInt:i]];
    }
    
    // Count the number of favorited quotes and shift their indexes to the front of the array.
    int initialIndex = -1;
    favoriteCount = 0;
    for (int i = 0; i < count; i++) {
        Quote *quote = [_fetchedResultsController.fetchedObjects objectAtIndex:i];
        BOOL initial = [quote.objectID.URIRepresentation isEqual:initialQuote];
        if ([quote.favorite boolValue] || initial) {
            [orderIndices exchangeObjectAtIndex:i withObjectAtIndex:favoriteCount];
            if (initial) {
                initialIndex = favoriteCount;
                NSLog(@"Initial Quote Found At %d", initialIndex);
            }
            favoriteCount++;
        }
    }
    
    // Scramble the favorite indexes in the front of the array
    for (int i = 0; i < favoriteCount; ++i) {
        int nElements = favoriteCount - i;
        int n = (random() % nElements) + i;
        [orderIndices exchangeObjectAtIndex:i withObjectAtIndex:n];
        if (n == initialIndex) {
            initialIndex = i;
        } else if (i == initialIndex) {
            initialIndex = n;
        }
    }
    
    if (initialIndex != -1) {
        [orderIndices exchangeObjectAtIndex:initialIndex withObjectAtIndex:0];
    }
    
    // Scramble all the other indexes
    for (int i = favoriteCount; i < count; ++i) {
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [orderIndices exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    
    return _fetchedResultsController;
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    if (direction == UIAccessibilityScrollDirectionLeft) {
        [self nextPage];
        return YES;
    } else if (direction == UIAccessibilityScrollDirectionRight) {
        [self prevPage];
        return YES;
    }
    
    return NO;
}

- (void)nextPage
{
    if (currentIndex >= orderIndices.count-1) {
        return;
    }
    
    currentIndex++;
    
    VHBQuoteViewController *ctrl = (VHBQuoteViewController *)[self viewControllerAtIndex:currentIndex];
    [self setViewControllers:@[ctrl] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, ctrl.view);
}

- (void)prevPage
{
    if (currentIndex == 0) {
        return;
    }
    
    currentIndex--;
    VHBQuoteViewController *ctrl = (VHBQuoteViewController *)[self viewControllerAtIndex:currentIndex];
    [self setViewControllers:@[ctrl] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, ctrl.view);
}

- (int)getFetchIndex:(int)index
{
    return (int)[[orderIndices objectAtIndex:index] integerValue];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)longTapCaptured:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        longTapQuote = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[self getFetchIndex:currentIndex] inSection:0]];
        longTapSheet = [[UIActionSheet alloc] initWithTitle:@"Quote" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Quote" otherButtonTitles:([longTapQuote.favorite boolValue] ? @"Remove from Favorites" : @"Add to Favorites"), @"Edit Quote",  nil];
        [longTapSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapSheet) {
        NSError *error;
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        switch (buttonIndex) {
            case 0:
                [managedObjectContext deleteObject:longTapQuote];
                
                [appDelegate saveContext];
//                [managedObjectContext save:&error];
                if (error) {
                    NSLog(@"%@", error);
                }
                [self quoteDeleted];
                break;
            case 1:
                longTapQuote.favorite = [NSNumber numberWithBool:![longTapQuote.favorite boolValue]];
                
                favoriteCount += [longTapQuote.favorite boolValue] ? 1 : -1;
                
                [appDelegate saveContext];
//                [managedObjectContext save:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                }
                
                [((VHBQuoteViewController *)[self.viewControllers firstObject]) layout];
                
                break;
            case 2:
                [self performSegueWithIdentifier:@"editQuote" sender:self];
                break;
        }
    }
}

- (void)quoteDeleted
{
    [orderIndices removeObjectAtIndex:currentIndex];
    currentIndex = MAX(0, currentIndex - 1);
    NSArray *ctrls = [NSArray arrayWithObject:[self viewControllerAtIndex:currentIndex]];
    [self setViewControllers:ctrls direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [VHBLogUtils logEventType:LETQuotesRemove];
}

- (void)quoteCreated:(Quote *)quote
{
    self.initialQuote = [NSURL URLWithString:quote.objectID.URIRepresentation.absoluteString];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    
    currentIndex = 0;
    NSArray *ctrls = [NSArray arrayWithObject:[self viewControllerAtIndex:currentIndex]];
    [self setViewControllers:ctrls direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [VHBLogUtils logEventType:LETQuotesAdd];
}

- (void)quoteUpdated:(Quote *)quote
{
    [VHBLogUtils logEventType:LETQuotesEdit];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editQuote"] || [segue.identifier isEqualToString:@"addQuote"]) {
        VHBEditQuoteViewController *destination = segue.destinationViewController;
        destination.delegate = self;
        
        if ([segue.identifier isEqualToString:@"editQuote"]) {
            destination.quote = longTapQuote;
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        self.currentIndex = self.nextIndex;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    self.nextIndex = (int)[self indexOfViewController:[pendingViewControllers firstObject]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    VHBQuoteViewController *vc = (VHBQuoteViewController *) viewController;
    
    
    NSInteger index = [self indexOfViewController:vc];
    
    if (orderIndices.count == 0 || index == orderIndices.count-1) {
        return nil;
    }
    
    index++;
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    VHBQuoteViewController *vc = (VHBQuoteViewController *) viewController;
    NSInteger index = [self indexOfViewController:vc];
    
    if (orderIndices.count == 0 || index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}


@end
