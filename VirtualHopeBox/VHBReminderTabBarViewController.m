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

#import "VHBReminderTabBarViewController.h"

@interface VHBReminderTabBarViewController ()

@end

@implementation VHBReminderTabBarViewController
@synthesize contactsButton;
@synthesize menuButton;
@synthesize loadMessage;

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
    
    [menuButton setAccessibilityLabel:NSLocalizedString(@"Add", @"")];
    [menuButton setAccessibilityHint:NSLocalizedString(@"Adds a visual reminder.", @"")];
    
    [contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:contactsButton, menuButton, nil] animated:YES];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        self.tabBar.tintColor = nil;
    } else {
    }
    
    if (loadMessage) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil message:loadMessage delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [message show];
    }
    
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [VHBLogUtils logEventType:LETRemindOpen];
    [VHBLogUtils startTimedEvent:LETRemindClose];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [VHBLogUtils endTimedEvent:LETRemindClose];
}

- (void)viewDidUnload
{
    [self setContactsButton:nil];
    [self setMenuButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == [[tabBar items] objectAtIndex:0]) {
        [menuButton setAccessibilityHint:NSLocalizedString(@"Adds a visual reminder.", @"")];
    } else if (item == [[tabBar items] objectAtIndex:1]) {
        [menuButton setAccessibilityHint:NSLocalizedString(@"Adds an audio reminder.", @"")];
    }
}


- (IBAction)menuClicked:(id)sender {
    if ([self selectedIndex] == 0) {
        VHBVisualReminderViewController *vc = [[self viewControllers] objectAtIndex:0];
        [vc menuClicked:self];
    } else if ([self selectedIndex] == 1) {
        VHBAudioReminderViewController *vc = [[self viewControllers] objectAtIndex:1];
        [vc menuClicked:self];
    }
}
@end
