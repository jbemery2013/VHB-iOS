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

#import "CopingCardsViewController.h"

@interface CopingCardsViewController ()

@end

@implementation CopingCardsViewController

@synthesize addButton, editButton;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
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
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addButton, editButton, nil]];
    
    addButton.accessibilityLabel = @"Create a new coping card.";
    editButton.accessibilityLabel = @"Edit the current coping card.";
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    self.dataSource = self;
    self.delegate = self;
    
    UIViewController *ctrl = [self viewControllerAtIndex:0];
    NSArray *ctrls;
    if (ctrl != nil) {
        ctrls = [NSArray arrayWithObject:ctrl];
        [self setViewControllers:ctrls direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [VHBLogUtils endTimedEvent:LETCardsClose];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    [VHBLogUtils logEventType:LETCardsOpen];
    [VHBLogUtils startTimedEvent:LETCardsClose];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([segue.identifier isEqualToString:@"edit"] || [segue.identifier isEqualToString:@"add"]) {
        CopingCardEditContainerViewController *ctrl = (CopingCardEditContainerViewController *) segue.destinationViewController;
        ctrl.delegate = self;
        
        if ([segue.identifier isEqualToString:@"edit"]) {
            ctrl.copingCard = [self.fetchedResultsController.fetchedObjects objectAtIndex:currentIndex];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)copingCardCreated:(CopingCard *)card
{
    NSLog(@"Added: %@", card);
    currentIndex = (int)self.fetchedResultsController.fetchedObjects.count-1;
    NSArray *ctrls = [NSArray arrayWithObject:[self viewControllerAtIndex:currentIndex]];
    
    [self setViewControllers:ctrls direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self logCard:card withLogType:LETCardsAdd];
}

-(void)logCard:(CopingCard *)card withLogType:(LogEntryType)type
{
    NSMutableString *cardStr = [NSMutableString stringWithFormat:@"Problem Area: %@; Symptoms: ", dRaw(encodeKey, card.problem)];
    
    BOOL first = YES;
    if (card.symptoms.count == 0) {
        [cardStr appendString:@"N/A"];
    } else {
        for (Symptom *symp in card.symptoms) {
            if (!first) {
                [cardStr appendString:@", "];
            }
            [cardStr appendString:symp.symptom];
            first = NO;
        }
    }
    
    [cardStr appendString:@"; Coping Skills: "];
    
    first = YES;
    if (card.copingSkills.count == 0) {
        [cardStr appendString:@"N/A"];
    } else {
        for (CopingSkill *skill in card.copingSkills) {
            if (!first) {
                [cardStr appendString:@", "];
            }
            [cardStr appendString:dRaw(encodeKey, skill.skill)];
            first = NO;
        }
    }
    
    [VHBLogUtils logEventType:type withValue:cardStr];
}

-(void)copingCardUpdated:(CopingCard *)card
{
    NSLog(@"Updated: %@", card);
    [self logCard:card withLogType:LETCardsEdit];
}

-(void)copingCardDeleted:(CopingCard *)card
{
    NSLog(@"Deleted: %@", card);
    
    currentIndex = MAX(0, currentIndex - 1);
    
    NSArray *ctrls = [NSArray arrayWithObject:[self viewControllerAtIndex:currentIndex]];
    [self setViewControllers:ctrls direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [VHBLogUtils logEventType:LETCardsRemove];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return [[CopingCardHelpViewController alloc] initWithNibName:@"CopingCardHelpPageIpad" bundle:nil];
        } else {
            return [[CopingCardHelpViewController alloc] initWithNibName:@"CopingCardHelpPage" bundle:nil];
        }
        
    }
    
    CopingCardPageViewController *ctrl = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [[CopingCardPageViewController alloc] initWithNibName:@"CopingCardPageIpad" bundle:nil] : [[CopingCardPageViewController alloc] initWithNibName:@"CopingCardPage" bundle:nil];
    ctrl.card = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
    
    return ctrl;
}

- (NSInteger)indexOfViewController:(CopingCardPageViewController *)controller
{
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        return 0;
    }
    
    return [self.fetchedResultsController.fetchedObjects indexOfObject:controller.card];
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
    CopingCardPageViewController *pvc = (CopingCardPageViewController *) viewController;
    
    
    NSInteger index = [self indexOfViewController:pvc];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0 || index == self.fetchedResultsController.fetchedObjects.count-1) {
        return nil;
    }
    
    index++;
    
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    CopingCardPageViewController *pvc = (CopingCardPageViewController *) viewController;
    NSInteger index = [self indexOfViewController:pvc];
    
    if (self.fetchedResultsController.fetchedObjects.count == 0 || index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return MAX(1, self.fetchedResultsController.fetchedObjects.count);
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return currentIndex;
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
    if (currentIndex >= self.fetchedResultsController.fetchedObjects.count-1) {
        return;
    }
    
    currentIndex++;
    
    CopingCardPageViewController *ctrl = (CopingCardPageViewController *)[self viewControllerAtIndex:currentIndex];
    [self setViewControllers:@[ctrl] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Card %d of %lu", currentIndex+1, self.fetchedResultsController.fetchedObjects.count]);
}

- (void)prevPage
{
    if (currentIndex == 0) {
        return;
    }
    
    currentIndex--;
    CopingCardPageViewController *ctrl = (CopingCardPageViewController *)[self viewControllerAtIndex:currentIndex];
    [self setViewControllers:@[ctrl] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Card %d of %lu", currentIndex+1, self.fetchedResultsController.fetchedObjects.count]);
}

- (void)toggleHelp:(BOOL)enabled
{
    if (enabled) {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addButton, nil] animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:addButton, editButton, nil] animated:YES];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    [self toggleHelp:controller.fetchedObjects.count == 0];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CopingCard" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]]];

    [fetchRequest setPredicate:nil];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [self toggleHelp:_fetchedResultsController.fetchedObjects.count == 0];
    
    return _fetchedResultsController;
}


@end
