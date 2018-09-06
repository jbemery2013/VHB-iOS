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
#import <EventKit/EventKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "APInvitee.h"
#import "APActivity.h"
#import "APSelectActivityViewController.h"
#import "APCompletedViewController.h"
#import "VHBDarkTableViewController.h"
#import "VHBLogUtils.h"

@interface APCreateEventViewController : VHBDarkTableViewController <ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, APIdeaChangedDelegate>
@property (strong, nonatomic) ABPeoplePickerNavigationController *peoplePicker;

@property (strong, nonatomic) UIGestureRecognizer *longPressRecognizer;
@property (strong, nonatomic) UIActionSheet *longPressActionSheet;
@property (strong, nonatomic) NSIndexPath *selectedInvitee;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *contactsButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) APActivity *activity;
@property (strong, nonatomic) IBOutlet UIToolbar *pickerToolbar;

@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pickerDoneButton;

- (IBAction)doneClicked:(id)sender;

@end
