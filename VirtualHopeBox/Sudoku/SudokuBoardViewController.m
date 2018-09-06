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

#import "SudokuBoardViewController.h"
#import "SudokuCell.h"
#import "GradientLayer.h"
#import "DefaultsWrapper.h"

@interface SudokuBoardViewController () {
    SudokuBoardView *boardView;
    SudokuBoard *board;
    NSTimer *completeAnimTimer;
    int completeAnimIndex;
    UIPopoverController *popover;
    UIActionSheet *actionSheet;
    UIBarButtonItem *popoverButton;
}

@end

@implementation SudokuBoardViewController
@synthesize landscapeView = _landscapeView;
@synthesize portraitView = _portraitView;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize portraitBoardView = _portraitBoardView;
@synthesize landscapeBoardView = _landscapeBoardView;
@synthesize menuButton = _menuButton;
@synthesize contactButton = _contactButton;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [_portraitBoardView setBoard:board];
    [_landscapeBoardView setBoard:board];
    
    [_contactButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    [_menuButton setAccessibilityLabel:NSLocalizedString(@"Settings", @"")];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:_contactButton, _menuButton, nil] animated:YES];
    
    [self setViewForOrientation:self.interfaceOrientation];
    
}

- (void)setBoard:(SudokuBoard *)obj;
{
    board = obj;
    [_portraitBoardView setBoard:board];
    _portraitView.hidden = NO;
    [_landscapeBoardView setBoard:board];
    _landscapeView.hidden = NO;
    self.menuButton.enabled = YES;
    [popover dismissPopoverAnimated:YES];
    
    [boardView setNeedsDisplay];
}

- (void)setViewForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        boardView = _landscapeBoardView;
        boardView.selectedCellIndex = _portraitBoardView.selectedCellIndex;
        boardView.highlightValue = _portraitBoardView.highlightValue;
        self.view = [self landscapeView];
    } else {
        boardView = _portraitBoardView;
        boardView.selectedCellIndex = _landscapeBoardView.selectedCellIndex;
        boardView.highlightValue = _landscapeBoardView.highlightValue;
        self.view = [self portraitView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [VHBLogUtils logEventType:LETSudokuOpen];
    [VHBLogUtils startTimedEvent:LETSudokuClose];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [VHBLogUtils endTimedEvent:LETSudokuClose];
    
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    [_managedObjectContext save:nil];
    [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    actionSheet = nil;
    [self setPortraitBoardView:nil];
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [self setBoard:nil];
    [self setLandscapeView:nil];
    [self setPortraitView:nil];
    
    [self setLandscapeBoardView:nil];
    [self setMenuButton:nil];
    [self setContactButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSError *error = nil;
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    long index = buttonIndex;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && buttonIndex > 0) {
        //index++;
    }
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _portraitBoardView.verifyEnabled = NO;
    _landscapeBoardView.verifyEnabled = NO;
    
    switch (index) {
        case 0:
            board.puzzle.current_state = nil;
            board.puzzle.complete = [NSNumber numberWithBool:NO];
            
            
            [appDelegate saveContext];
//            [_managedObjectContext save:&error];
            [board loadPuzzle:board.puzzle];
            
            //[boardView setBoard:board]
            [boardView setNeedsDisplay];
            break;
        case 3:
            _portraitBoardView.highlightEnabled = !_portraitBoardView.highlightEnabled;
            _landscapeBoardView.highlightEnabled = !_landscapeBoardView.highlightEnabled;
            
            //[defaults setObject:[NSNumber numberWithBool:boardView.highlightEnabled] forKey:@"highlight"];
            encryptIntForKey(@"highlight", boardView.highlightEnabled);
            //[defaults synchronize];
            
            [boardView setNeedsDisplay];
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2) {
        if (UIAccessibilityIsVoiceOverRunning()) {
            [self performSelector:@selector(verifyAnswers) withObject:nil afterDelay:1.5];
        } else {
            [self verifyAnswers];
        }
    } else if (buttonIndex == 1) {
        if (UIAccessibilityIsVoiceOverRunning()) {
            [self performSelector:@selector(showHint) withObject:nil afterDelay:1.5];
        } else {
            [self showHint];
        }
    }
}

- (void)showHint {
    if ([board.puzzle.complete boolValue]) {
        return;
    }
    
    int idx;
    do {
        idx = arc4random_uniform(81);
        SudokuCell *cell = [board.cells objectAtIndex:idx];
        if (!cell.locked && (cell.marks.count == 0 || cell.marks.count > 1)) {
            [cell clearMarks];
            [cell.marks addObject:cell.solution];
            break;
        }
    } while (true);
    [self updatePuzzleState];
    [boardView setNeedsDisplay];
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Hint provided at Row: %d; Column %d;", (idx / 9) + 1, (idx % 9) + 1]);
    
    if ([board isComplete]) {
        [self puzzleComplete];
    }
}

- (void)verifyAnswers {
    if ([board.puzzle.complete boolValue]) {
        return;
    }
    
    _portraitBoardView.verifyEnabled = YES;
    _landscapeBoardView.verifyEnabled = YES;
    
    NSString *notice = @"";
    BOOL valid = YES;
    int index = 0;
    for (SudokuCell *cell in board.cells) {
        if (![cell isCorrect]) {
            if (valid) {
                valid = NO;
                notice = @"The following cells are incorrect.";
            }
            
            notice = [NSString stringWithFormat:@"%@ Row: %d; Column %d;", notice, (index / 9) + 1, (index % 9) + 1];
        }
        index++;
    }
    
    if (valid) {
        notice = @"All cells are correct.";
    }
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notice);
    
    [boardView setNeedsDisplay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setViewForOrientation:self.interfaceOrientation];
    [boardView setNeedsLayout];
    [boardView setNeedsDisplay];
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    popoverButton = barButtonItem;
    popover = popoverController;
    barButtonItem.title = NSLocalizedString(@"Puzzles", @"Puzzles");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    NSError *error = nil;
//    [_managedObjectContext save:&error];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (IBAction)menuClicked:(id)sender 
{
    
    NSString *highlightString = boardView.highlightEnabled ? @"Disable Highlighting" : @"Enable Highlighting";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Puzzle" otherButtonTitles:@"Get Hint", @"Verify Answers", highlightString, nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Puzzle" otherButtonTitles: @"Get Hint", @"Verify Answers", highlightString, nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)numberClicked:(id)sender 
{
    SudokuCell *cell = [boardView getSelectedCell];
    if (cell == nil) {
        return;
    }
    NSInteger val = [sender tag];
    
    [cell toggleMark:(int)val];
    boardView.highlightValue = (int)val;
    
    if ([board isComplete]) {
        [self puzzleComplete];
    }
    [self updatePuzzleState];
    [boardView setNeedsDisplay];
}

-(void)puzzleComplete 
{
    boardView.highlightValue = -1;
    boardView.selectedCellIndex = -1;
    board.puzzle.complete = [NSNumber numberWithBool:YES];
    completeAnimTimer = [NSTimer scheduledTimerWithTimeInterval:2.0/40.0 target:self selector:@selector(animateComplete) userInfo:nil repeats:YES];
    
    NSArray *titles = @[@"Easy", @"Intermediate", @"Hard", @"Expert"];
    [VHBLogUtils logEventType:LETSudokuCompleted withValue:[NSString stringWithFormat:@"%@ #%d", [titles objectAtIndex:[board.puzzle.difficulty intValue]], ([board.puzzle.order intValue] % 50) + 1]];
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Puzzle complete");
}

-(void)animateComplete
{
    if (completeAnimIndex * 2 >= [board.cells count]) {
        [completeAnimTimer invalidate];
        completeAnimIndex = 0;
        [self.navigationController popViewControllerAnimated:YES];
        [popover presentPopoverFromBarButtonItem:popoverButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        return;
    }
    
    SudokuCell *cell = [board.cells objectAtIndex:completeAnimIndex];
    cell.locked = true;
    cell = [board.cells objectAtIndex:80-completeAnimIndex];
    cell.locked = true;
    [boardView setNeedsDisplay];
    completeAnimIndex++;
}

- (IBAction)clearClicked:(id)sender {
    SudokuCell *cell = [boardView getSelectedCell];
    if (cell == nil) {
        return;
    }
    
    [cell clearMarks];
    [self updatePuzzleState];
    [boardView setNeedsDisplay];
}

- (IBAction)invertClicked:(id)sender {
    SudokuCell *cell = [boardView getSelectedCell];
    if (cell == nil) {
        return;
    }
    [cell invertMarks];
    
    if ([board isComplete]) {
        [self puzzleComplete];
    }
    [self updatePuzzleState];
    [boardView setNeedsDisplay];
}

- (void) updatePuzzleState
{
    NSMutableString * state = [[NSMutableString alloc] init];
    for (SudokuCell *cell in board.cells) {
        [state appendFormat:@"%@", cell];
    }
    board.puzzle.current_state = state;
}

@end
