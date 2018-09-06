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

#import "VHBSetupMusicViewController.h"

@interface VHBSetupMusicViewController () {
    BOOL toggleLock, messageVisible;
    NSDate *sessionStart;
}

@end

@implementation VHBSetupMusicViewController
@synthesize titleLabel;
@synthesize tableView;
@synthesize messageScrollView;
@synthesize addButton;
@synthesize nextButton;
@synthesize audioTableController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    sessionStart = [NSDate date];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [VHBLogUtils logEvent:@"SETUP_AUDIO_REMINDER_SESSION" start:sessionStart];
    sessionStart = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    addButton.accessibilityHint = @"Adds an audio reminder.";
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:nextButton, addButton, nil]];
    
    self.audioTableController = [[VHBAudioReminderViewController alloc] init];
    //self.tableView = audioTableController.tableView;
    audioTableController.tableView = self.tableView;
    tableView.delegate = audioTableController;
    tableView.dataSource = audioTableController;
    [tableView addGestureRecognizer:audioTableController.longTapGestureRecognizer];
    audioTableController.delegate = self;
    audioTableController.addMediaActionSheet.delegate = self;
    audioTableController.longTapActionSheet.delegate = self;
    audioTableController.musicPickerController.delegate = self;
    audioTableController.recordingPickerController.delegate = self;
    audioTableController.recordingActionSheet.delegate = self;

    messageVisible = YES;
    
    [audioTableController reloadData];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTableView:nil];
    [self setAddButton:nil];
    [self setMessageScrollView:nil];
    [self setNextButton:nil];
    
    [audioTableController viewDidUnload];
    [self setAudioTableController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == audioTableController.addMediaActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self presentModalViewController:audioTableController.musicPickerController animated:YES];
                break;
            case 1:
                [audioTableController.recordingActionSheet showInView:self.view];
                break;
        }
    } else if (actionSheet == audioTableController.longTapActionSheet) {
        [audioTableController actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        [self updateTableVisibility:.5];
    } else if (actionSheet == audioTableController.recordingActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self presentModalViewController:audioTableController.recordingPickerController animated:YES];
                break;
            case 1:
                if (!audioTableController.recorderView) {
                    audioTableController.recorderView = [[VHBAudioRecorderView alloc] initWithFrame:CGRectMake(60, 150, 200, 124)];
                    
                    audioTableController.recorderView.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 62, 200, 124);
                }
                audioTableController.recorderView.delegate = audioTableController;
                [self.navigationController.view addSubview:audioTableController.recorderView];
                break;
        }
    }
}

- (void)updateTableVisibility:(float)delay {
    [UIView animateWithDuration:.5 delay:delay options:0 animations:^{
        if (audioTableController.fetchedResultsController.fetchedObjects.count > 0) {
            tableView.alpha = 1;
            messageScrollView.alpha = 0;
        } else {
            tableView.alpha = 0;
            messageScrollView.alpha = 1;
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [audioTableController mediaPicker:mediaPicker didPickMediaItems:mediaItemCollection];
    [self updateTableVisibility:.5];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)toggleMessageVisiblity
{

}

- (IBAction)addClicked:(id)sender 
{
    [audioTableController menuClicked:self];
    [self toggleMessageVisiblity];
}

- (void)tableLoaded
{
    [self updateTableVisibility:0];
}

- (void)rowsChanged
{
    [self updateTableVisibility:.5];
}

@end
