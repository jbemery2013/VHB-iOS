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

#import "MahjongBoardViewController.h"
#import "DefaultsWrapper.h"

@interface MahjongBoardViewController () {
    CGRect initialBounds;
    CGRect prevVisibleBounds;
    UIActionSheet *actionSheet;
    UIBarButtonItem *popoverButton;
}

@end

@implementation MahjongBoardViewController

@synthesize board;
@synthesize boardView = _boardView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize contactsButton = _contactsButton;
@synthesize menuButton = _menuButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:_contactsButton, _menuButton, nil];
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *name = decryptStringForKey(@"mahjong_background");
    [self backgroundChanged:name];
    
    [_boardView setDelegate:self];
    [_boardView setBoard:board];
    [self loadBoard];
    //NSLog(@"%@", _boardView);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [VHBLogUtils logEventType:LETMahjongOpen];
    [VHBLogUtils startTimedEvent:LETMahjongClose];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [VHBLogUtils endTimedEvent:LETMahjongClose];
    [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
        self.backgroundImageView.image = nil;
        [self.boardView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
        [self.boardView removeFromSuperview];
    }
}

- (void)viewDidUnload
{
    board.puzzle = nil;
    board = nil;
    _boardView.board = nil;
    popoverButton = nil;
    actionSheet = nil;
    [self setBoardView:nil];
    [self setManagedObjectContext:nil];
    [self setBackgroundImageView:nil];
    [self setMenuButton:nil];
    [self setContactsButton:nil];
    [super viewDidUnload];
}

- (void)loadBoard
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_boardView setDelegate:self];
    [_boardView setBoard:board];
    [_boardView loadBoard];    
}

- (void)puzzleLoaded
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_boardView setNeedsLayout];
    [_boardView updateTransform];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"changeBackground"]) {
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSError *error = nil;
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    int index = (int)buttonIndex;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && buttonIndex > 0) {
        // Shift indexes if iPad has different number of menu items
        //index++;
    }
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    switch (index) {
        case 0:
            board.puzzle.current_state = nil;
            //board.puzzle.complete = [NSNumber numberWithBool:NO];
            [_boardView resetBoard];
            
            
            [appDelegate saveContext];
//            [__managedObjectContext save:&error];
            break;
        case 1:
            _boardView.highlightEnabled = !_boardView.highlightEnabled;
            [_boardView updateTiles];
            //[defaults setObject:[NSNumber numberWithBool:_boardView.highlightEnabled] forKey:@"highlight"];
            encryptIntForKey(@"highlight", (int)[NSNumber numberWithBool:_boardView.highlightEnabled]);
            //[defaults synchronize];
            break;
        case 2:
            [self performSegueWithIdentifier:@"changeBackground" sender:nil];
            break;
    }
}

- (void)backgroundChanged:(NSString *)name
{
    _backgroundImageView.image = nil;
    
    NSString *imageFile = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];

    if (imageFile) {
        UIImage *background = [[UIImage alloc] initWithContentsOfFile:imageFile];
        if ([name isEqualToString:@"Pine"] 
            || [name isEqualToString:@"Bubbles"]
            || [name isEqualToString:@"Canvas"]
            || [name isEqualToString:@"Circles"]) {
            _backgroundImageView.image = nil;
            _backgroundImageView.alpha = 0;
            self.view.backgroundColor = [UIColor colorWithPatternImage:background];
        } else {
            _backgroundImageView.alpha = 1.0;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundImageView.image = background;
        }
    } else {
        _backgroundImageView.image = [UIImage imageNamed:@"table_background.png"];
    }

}

- (void)tileSelected:(MahjongTileSlotView *)slotView
{
    
}

- (void)tileUnselected:(MahjongTileSlotView *)slotView
{
    slotView.transform = CGAffineTransformIdentity;
   // [slotView setNeedsDisplay];
  //  [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
}

- (void)puzzleComplete
{

    
    board.puzzle.complete = [NSNumber numberWithBool:YES];
    board.puzzle.current_state = nil;
    
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    NSError *error;
//    [__managedObjectContext save:&error];
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Puzzle complete. Returning to puzzle list.");
        [self performSelector:@selector(puzzleCompleteAccessibility) withObject:Nil afterDelay:2.5];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSArray *diffs = @[@"Easy", @"Intermediate", @"Hard", @"Expert"];
    [VHBLogUtils logEventType:LETMahjongCompleted withValue:[NSString stringWithFormat:@"%@ - %@ #%d", board.puzzle.layout.title, [diffs objectAtIndex:[board.puzzle.difficulty intValue]], ([board.puzzle.order intValue] % 50)]];
}
- (void)puzzleCompleteAccessibility
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)puzzleFailed
{
    //board.puzzle.complete = [NSNumber numberWithBool:NO];
    board.puzzle.current_state = nil;
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"No moves left. Puzzle resetting.");
    
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    NSError *error;
//    [__managedObjectContext save:&error];
}

- (IBAction)menuClicked:(id)sender {
    
    NSString *highlightString = _boardView.highlightEnabled ? @"Disable Highlighting" : @"Enable Highlighting";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Puzzle" otherButtonTitles:highlightString, @"Change Background", nil];
        [actionSheet showFromBarButtonItem:_menuButton animated:YES];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:self.title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Puzzle" otherButtonTitles:highlightString, @"Change Background", nil];
        [actionSheet showInView:self.view];
    }
    
}

-(void)setBoard:(MahjongBoard *)obj {
    board = obj;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
