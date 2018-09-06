﻿//
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
#import <CoreData/CoreData.h>
#import "SudokuBoardView.h"
#import "VHBLogUtils.h"

@interface SudokuBoardViewController : UIViewController <UISplitViewControllerDelegate, UIActionSheetDelegate>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet SudokuBoardView *portraitBoardView;
@property (strong, nonatomic) IBOutlet SudokuBoardView *landscapeBoardView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *contactButton;

@property (strong, nonatomic) IBOutlet UIView *portraitView;
@property (strong, nonatomic) IBOutlet UIView *landscapeView;

- (void)setBoard:(SudokuBoard *)board;

- (IBAction)menuClicked:(id)sender;
- (IBAction)numberClicked:(id)sender;
- (IBAction)clearClicked:(id)sender;
- (IBAction)invertClicked:(id)sender;


@end
