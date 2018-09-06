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

#import "VHBRelaxTableViewController.h"
#import "NSOutlinedLabel.h"
#import "GradientLayer.h"

@interface VHBRelaxTableViewController ()

@end

@implementation VHBRelaxTableViewController
@synthesize contactsButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.tableView.bounds;
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [view.layer insertSublayer:bgLayer atIndex:0];
    self.tableView.backgroundView = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorColor = [UIColor blackColor];
    
    [contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    
    self.tableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
}

- (void)viewDidUnload
{
    [self setContactsButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    cell.backgroundColor = indexPath.row % 2 
    ? [UIColor colorWithRed:0.004 green:0.404 blue:0.694 alpha:1]
    : [UIColor colorWithRed:0.004 green:0.318 blue:0.545 alpha:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSOutlinedLabel *label = (NSOutlinedLabel *)[cell viewWithTag:1];
    label.outlineColor = [UIColor blackColor];
    label.outlineWidth = 3;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"beach"]) {
        GuidedMeditationViewController *ctrl = (GuidedMeditationViewController *)segue.destinationViewController;
        ctrl.meditationType = GuidedMeditationTypeBeach;
    } else if ([segue.identifier isEqualToString:@"forest"]) {
        GuidedMeditationViewController *ctrl = (GuidedMeditationViewController *)segue.destinationViewController;
        ctrl.meditationType = GuidedMeditationTypeForest;
    } else if ([segue.identifier isEqualToString:@"road"]) {
        GuidedMeditationViewController *ctrl = (GuidedMeditationViewController *)segue.destinationViewController;
        ctrl.meditationType = GuidedMeditationTypeRoad;
    }
}

@end
