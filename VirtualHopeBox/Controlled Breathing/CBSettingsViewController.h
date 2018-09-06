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

#import <UIKit/UIKit.h>
#import "CBChangeSessionDurationViewController.h"
#import "CBChangeMusicViewController.h"
#import "CBChangeBackgroundViewController.h"
#import "CBChangeDurationViewController.h"
#import "VHBDarkTableViewController.h"

@interface CBSettingsViewController : VHBDarkTableViewController < CBChangeMusicDelegate, CBChangeBackgroundDelegate, UIPopoverControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *musicTypeLabel;
@property (strong, nonatomic) IBOutlet UISwitch *vocalPromptsSwitch;
@property (strong, nonatomic) IBOutlet UILabel *backgroundTypeLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *inhaleCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *exhaleCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *holdCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *restCell;
@property (strong, nonatomic) IBOutlet UIPickerView *externalPickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *embeddedPickerView;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;
@property (strong, nonatomic) IBOutlet UISwitch *sessionSwitch;
@property (strong, nonatomic) IBOutlet UITableViewCell *sessionCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *vocalPromptsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *unlimitedCell;

@end
