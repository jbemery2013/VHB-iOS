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

#import "VHBVideoPickerViewController.h"

@interface VHBVideoPickerViewController () {
    int rows;
}

@end

@implementation VHBVideoPickerViewController

@synthesize delegate;
@synthesize assetsLibrary;
@synthesize videos;
@synthesize cancelButton;

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
    
    videos = [[NSMutableArray alloc] init];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.navigationItem setRightBarButtonItems:nil];
    }

    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    assetsLibrary = appDelegate.assets;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VHBVisualReminderCell" bundle:nil] forCellReuseIdentifier:@"visualCell"];
    
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        NSLog(@"%@", group);
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [videos addObject:result];
                int row = (int)floor((float) (videos.count-1) / 4.0f);
                if (row == rows) {
                    rows++;
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                } else {
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"%@ - %@", @"Asset Enumeration Failed", error);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@", videos);
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [super viewDidUnload];
    videos = nil;
    assetsLibrary = nil;
    delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"visualCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VHBVisualReminderCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    ALAsset *asset;
    UIImageView *img;
    UIView *overlay;
    UILabel *duration;
    UIView *icon;
    
    
    int columns = 4;
    for (int col = 1; col <= columns; col++) {
        int index = (indexPath.row * columns + (col - 1));
        //int tag = col * 100;
        
        UIView *colCell = [[[cell.subviews objectAtIndex:0] subviews] objectAtIndex:col-1];
        img = (UIImageView *) [colCell viewWithTag:100];
        overlay = [colCell viewWithTag:101];
        duration = (UILabel *) [overlay viewWithTag:1];
        icon = [overlay viewWithTag:2];
        
//        img = (UIImageView *) [cell viewWithTag:tag];
//        overlay = [cell viewWithTag:tag+1];
//        duration = (UILabel *) [cell viewWithTag:tag+2];
//        icon = [cell viewWithTag:tag+3];
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCaptured:)];
        
        if (videos.count > index) {
            colCell.hidden = NO;
            asset = (ALAsset *)[videos objectAtIndex:index];
            img.image = [UIImage imageWithCGImage:asset.thumbnail];
            [colCell addGestureRecognizer:tapGesture];
            int totalSeconds = [[asset valueForProperty:ALAssetPropertyDuration] intValue];
            int seconds = totalSeconds % 60; 
            int minutes = (totalSeconds / 60) % 60;
            
            colCell.accessibilityLabel = [NSString stringWithFormat:@"Video, %i minutes, %i seconds", minutes, seconds];

            duration.text = [[NSString alloc] initWithFormat:@"%01i:%02i", minutes, seconds];
        } else {
            if (colCell.gestureRecognizers.count > 0) {
                [colCell removeGestureRecognizer:[colCell.gestureRecognizers objectAtIndex:0]];
            }
            colCell.hidden = YES;
            duration.text = @"";
            img.image = nil;
        }
    }
    // Configure the cell...
    
    return cell;
}

- (void)tapCaptured:(UITapGestureRecognizer *)gesture
{
    int x = gesture.view.center.x;
    int y = gesture.view.superview.superview.center.y;
    NSIndexPath *path = [self.tableView indexPathForRowAtPoint:CGPointMake(x, y)];
    int index = (path.row * 4 + (gesture.view.tag - 1));
    NSLog(@"%@, %i", path, index);
    
    [delegate didFinishPickingVideo:[videos objectAtIndex:index]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

- (IBAction)backClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
