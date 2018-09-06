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
#import <CoreData/CoreData.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VHBSetupEULAViewController.h"
#import "VHBHomeViewController.h"
#import "NSData+Base64.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "MailData.h"
#import <UserNotifications/UserNotifications.h>
#define kFileNameEncryptedSQL @"/encrypt.sqlite"
#define kFileNameEncryptedSQLwal @"/encrypt.sqlite-wal"
#define SQL_FILE_BASE @"vhb"
#define kFilenameSQL       @"vhb.sqlite"
#define kFileNameSQLshm @"/vhb.sqlite-shm"
#define kFileNameSQLwal @"/vhb.sqlite-wal"
#define kConvertToDaREdone          @"ConvertToFIPS2"
//#import <LocalAuthentication/LocalAuthentication.h>
static NSString* encodeKey = @"T2!SEf1l3*";
@interface VHBAppDelegate : UIViewController <UIApplicationDelegate,MFMailComposeViewControllerDelegate, UNUserNotificationCenterDelegate>
//@interface VHBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *backgroundManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSPersistentStore *persistentStore;
@property (readonly, strong, nonatomic) ALAssetsLibrary *assets;
@property (readwrite, assign) NSString *databaseKey;

//@property (nonatomic, retain) UIImageView *cover; 
-(void)sendMail:(MailData *)data;
- (void)saveContext;
- (NSString *)applicationDocumentsDirectory;
- (void)scheduleQuoteNotification;


@end
