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

#import "VHBDarkTableViewController.h"
#import "GradientLayer.h"

@interface VHBDarkTableViewController ()

@end

@implementation VHBDarkTableViewController

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
    
//    [self.tableView setBounces:NO];

//
//    UIImage *background = [UIImage imageNamed:@"table_background.png"];
//    
//    if ([self.tableView respondsToSelector:@selector(backgroundView)] ) {
//        UIImageView *bgView = [[UIImageView alloc] initWithImage:background];
//        self.tableView.backgroundView = bgView;
//    } else {
//        self.tableView.backgroundView = nil;
//        self.tableView.backgroundColor = [UIColor clearColor];
//        self.view.backgroundColor = [UIColor colorWithPatternImage:background];
//    }
    
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView:tableView titleForHeaderInSection:section].length == 0) {
        return 20;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    
    
    UILabel *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, tableView.frame.size.width - 40, 40)];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, tableView.frame.size.width - 100, 40)];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.7 alpha:1];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor colorWithWhite:.2 alpha:1];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont boldSystemFontOfSize:16];
    [view addSubview: label];
    return view;
}


@end
