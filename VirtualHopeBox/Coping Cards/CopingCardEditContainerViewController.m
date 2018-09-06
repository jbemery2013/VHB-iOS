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


#import "CopingCardEditContainerViewController.h"
#import "DefaultsWrapper.h"

@interface CopingCardEditContainerViewController () {
    int hintIndex;
}

@end

@implementation CopingCardEditContainerViewController

@synthesize tableContainer;
@synthesize doneButton;
@synthesize helpButton;
@synthesize delegate;
@synthesize copingCard;
@synthesize popoverView;
@synthesize overlayView;
@synthesize managedObjectContext;

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
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:doneButton, helpButton, nil]];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    doneButton.accessibilityHint = @"Saves this coping card.";
    helpButton.accessibilityHint = @"Shows help popups.";
    self.deleteSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Coping Card" otherButtonTitles:nil];
    
    if (copingCard) {
        self.navigationItem.title = @"Edit Card";
    } else {
        self.navigationItem.title = @"Add Card";
    }
    
    [self tableViewController].copingCard = copingCard;
    [self tableViewController].delegate = self;
    [[self tableViewController] loadCard];
	// Do any additional setup after loading the view.
}

- (CopingCardEditViewController *)tableViewController
{
    return (CopingCardEditViewController *)[self.childViewControllers firstObject];
}

//- (void)nextHint {
//    hintIndex++;
//    if (hintIndex > 3) {
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setBool:true forKey:@"coping_card_hints_viewed"];
//        [defaults synchronize];
//        hintIndex = 0;
//    }
//    [self loadHint];
//}
//
//- (void)loadHint
//{
//    [popoverView removeFromSuperview];
//    
//    CopingCardEditViewController *ctrl = [self tableViewController];
//    int y = 0;
//    if (hintIndex > 0) {
//        y = [ctrl tableView:ctrl.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:hintIndex-1]].frame.origin.y + 10;
//    }
//    
//    if (hintIndex == 1) {
//        y += 20;
//        popoverView = [[[NSBundle mainBundle] loadNibNamed:@"CopingCardHelpViews" owner:self options:nil] firstObject];
//        [popoverView addGestureRecognizer:dismissHintGesture];
//        CGRect frame = popoverView.frame;
//        frame.origin.x = 20;
//        frame.origin.y = y;
//        popoverView.frame = frame;
//    } else if (hintIndex == 2) {
//        y += 20;
//        popoverView = [[[NSBundle mainBundle] loadNibNamed:@"CopingCardHelpViews" owner:self options:nil] objectAtIndex:1];
//        [popoverView addGestureRecognizer:dismissHintGesture];
//        CGRect frame = popoverView.frame;
//        frame.origin.x = 20;
//        frame.origin.y = y;
//        popoverView.frame = frame;
//    } else if (hintIndex == 3) {
//        popoverView = [[[NSBundle mainBundle] loadNibNamed:@"CopingCardHelpViews" owner:self options:nil] lastObject];
//        [popoverView addGestureRecognizer:dismissHintGesture];
//        CGRect frame = popoverView.frame;
//        frame.origin.x = 20;
//        frame.origin.y = y - frame.size.height;
//        popoverView.frame = frame;
//    }
//    
//    if (hintIndex > 0) {
//        self.overlayView.frame = self.view.bounds;
//        [self.view addSubview:overlayView];
//        [self.view addSubview:popoverView];
//        [self.view bringSubviewToFront:popoverView];
//        popoverView.accessibilityLabel = ((UILabel *)[popoverView viewWithTag:5]).text;
//        popoverView.accessibilityViewIsModal = YES;
//        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, popoverView);
//    } else {
//        [overlayView removeFromSuperview];
//    }
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect frame = self.view.frame;
    overlayView = [[UIView alloc] initWithFrame:frame];
    overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (!decryptBoolForKey(@"coping_card_hints_viewed")) {
        [self help];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)helpClicked:(id)sender {
    [self help];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (hintIndex == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Next, identify the feelings (e.g. sad, angry, lonely) and physical symptoms (e.g. headache, nausea) that go along with the problem area." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        hintIndex = 2;
    } else if (hintIndex == 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Finally, pick coping skills (actions or positive thoughts) that help you cope with your chosen problem areas. Keep them simple, short, and realistic." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        hintIndex = 0;
        //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        encryptBoolForKey(@"coping_card_hints_viewed", YES);
    }
}

- (void)deleteClicked
{
    [self.deleteSheet showInView:self.view];
}

- (void)help
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"To begin each coping card, select a problem area that would be helpful to focus on." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    hintIndex = 1;
}

- (BOOL)deleteCard
{
    NSError *error;
    [self.managedObjectContext deleteObject:self.copingCard];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", error);
        return NO;
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        [self deleteCard];
        [self.delegate copingCardDeleted:self.copingCard];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)doneClicked:(id)sender
{
    BOOL edit = self.copingCard != nil;
    
    if ([[self tableViewController] saveCard]) {
        if (edit) {
            [self.delegate copingCardUpdated:self.copingCard];
        } else {
            [self.delegate copingCardCreated:self.copingCard];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
