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

#import "VHBAppDelegate.h"
#import "SudokuAppDelegate.h"
#import "MahjongAppDelegate.h"
#import "Quote.h"
#import "SupportContact.h"
#import "CBAppDelegate.h"
#import "ActivityIdea.h"
#import "AudioReminder.h"
#import "CopingCardAppDelegate.h"
#import "PMRAppDelegate.h"
#import "DefaultsWrapper.h"
#import "MailData.h"
#import "FIPS_iOS_routines.h"
#import "HashHelpers.h"
#import <LocalAuthentication/LocalAuthentication.h>
#define kConvertVersion             @"ConvertVersion"

@interface VHBAppDelegate (){
    BOOL isGrantedNotifications;
    BOOL notificationAlreadyDisplayed;
}
@end

@implementation VHBAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize backgroundManagedObjectContext = __backgroundManagedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize persistentStore = __persistentStore;
@synthesize assets = _assets;
@synthesize databaseKey;

NSString * const kUserDefaultsKeyDareImplemented = @"com.vpd.vhb.DareImplemented";
NSString * const kUserDefaultsKeyFIPSGCMImplemented = @"com.vpd.vhb.FIPSGCMImplemented";
NSString * const kUserDefaultsKeyDareBase = @"com.vpd.vhb.DareBase";


int const kAesModeCbc = 1;
int const kAesModeGcm = 2;

int const kSaltModeSecure = 1;
int const kSaltModeUnsecure = 2;

//Uses old pin to encrypt core data to new version
NSString *old_FIPS_Pin() {
    
    // 06/23/15 BGD Update this to use our hashed/salted value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *myTempKey = [HashHelpers securedSHA256DigestHashForPIN:[defaults integerForKey:kUserDefaultsKeyDareBase]];
    
    NSString *myKey = [myTempKey substringWithRange:NSMakeRange(8, 8)];
    NSLog(@"Key: %@", myKey);
    return myKey;
    
    //🔓[Bug 3515] BGH Update
    // return T2Pin;
    //🔒[Bug 3515]
}

// Encrypt CoreData SQL file
- (void)encryptCoreDataSQL {
    // Encrypt the Core Data SQL database
    
    // Construct the location for the encrypted database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName1 = [documentsDirectory stringByAppendingString:kFileNameEncryptedSQL];
    
    
    // Locate the existing unencrypted database...and encrypt it
    NSString *dbName = [documentsDirectory stringByAppendingString:@"/"];
    dbName = [dbName stringByAppendingString:kFilenameSQL];
    processBinaryFile(dbName, fileName1, T2E, t2p());
}

// Decrypt CoreData SQL file
- (void)decryptCoreDataSQL {
    // Decrypt the Core Data SQL database so the App can use it
    NSString *pin = nil;
    
    pin = t2p();
    
    // Locate the encrypted database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName1 = [documentsDirectory stringByAppendingString:kFileNameEncryptedSQL];
    
    // Construct the location for the unencrypted database
    NSString *dbName = [documentsDirectory stringByAppendingString:@"/"];
    dbName = [dbName stringByAppendingString:kFilenameSQL];
    processBinaryFile(fileName1, dbName, T2D, pin);
}

//Encrypt Core Data to new version
-(void)encryptCoreDataToNewVersion: (int) latestVersion
{
    [self setCBCModeUnsecure];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName1 = [documentsDirectory stringByAppendingString:kFileNameEncryptedSQL];
    
    // Construct the location for the unencrypted database
    NSString *dbName = [documentsDirectory stringByAppendingString:@"/"];
    dbName = [dbName stringByAppendingString:kFilenameSQL];
    processBinaryFile(fileName1, dbName, T2D, old_FIPS_Pin());
    
    [self setGCMModeSecure];

    processBinaryFile(dbName, fileName1, T2E, t2p());
}

// Get the path of a specific file
- (NSString *)dataFilePath:(NSString *)plistFileName extenstion:(NSString *)ext {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * fileName = [[NSString alloc] initWithString:plistFileName];
    fileName  = [fileName stringByAppendingString:ext];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void) deletedatabase {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath]]) {
        [[NSFileManager defaultManager] removeItemAtPath :[self dataFilePath] error:nil];
    }
}

- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilenameSQL];
}

-(int)fipsVersionStringToInt:(NSString *)fipsStringVal
{
    int version = 0;
    
    if ( [fipsStringVal length] > 0 )
    {
        NSString * fipsFirstPart = [fipsStringVal substringToIndex:2];
        NSString * fipsSecondPart = [fipsStringVal substringFromIndex:2];
        fipsSecondPart = [fipsSecondPart stringByReplacingOccurrencesOfString:@"." withString:@""];
        fipsStringVal = [fipsFirstPart stringByAppendingString:fipsSecondPart];
        
        version = [fipsStringVal intValue];
    }
    
    return version;
}//eom


-(void) migrateUserDefaultsFromVersion: (int) currVersion toLatest:(int) latestVersion
{
    //NSLog(@"Migrating UserDefaults | Version %d -> Version %d", currVersion, latestVersion);
    [self setCBCModeUnsecure];
    
    /*I was getting an error using the VHBConstant so I just wrote them values in */
    /*getting old encryped vlaues*/
    /* getting old encrypted values */
    BOOL bool_resetHelpPrompts      = decryptBoolForKey(@"resetHelpPrompts");
    BOOL bool_resetHelpUserDefault  = decryptBoolForKey(@"resetHelpUserDefault");
    BOOL bool_eula_accepted         = decryptBoolForKey(@"eula_accepted_DHA");
    BOOL bool_checkoxIsSelected     = decryptBoolForKey(@"checkoxIsSelected");
    BOOL bool_initialized           = decryptBoolForKey(@"cb_initialized");
    BOOL bool_vocal_prompts         = decryptBoolForKey(@"vocal_prompts");
    BOOL bool_background_type        = decryptBoolForKey(@"background_type");
    BOOL bool_cb_session_enabled = decryptBoolForKey(@"cb_session_enabled");
    BOOL bool_cb_settings_prompt_shown = decryptBoolForKey(@"cb_settings_prompt_shown");
    BOOL bool_copping_cards_initialized = decryptBoolForKey(@"coping_cards_initialized");
    BOOL bool_coping_card_hints_viewed = decryptBoolForKey(@"coping_card_hints_viewed");
    BOOL bool_mahjong_initialied =  decryptBoolForKey(@"mahjong_initialized");
    BOOL bool_pmr_initialied =      decryptBoolForKey(@"pmr_initialized");
    BOOL bool_pmr_captions =        decryptBoolForKey(@"pmr_captions");
    BOOL bool_sudoku_initialized =  decryptBoolForKey(@"sudoku_initialized");
    BOOL bool_hightlight =          decryptBoolForKey(@"highlight");
    BOOL bool_vhb_initialized =     decryptBoolForKey(@"vhb_initialized");
    
    NSString * bool_mahjong_background      = decryptStringForKey(@"mahjong_background");
    NSString * string_USE_RESEARCHSTUDY     = eGetValueForKey(encodeKey, @"DEFAULTS_USE_RESEARCHSTUDY");
    NSString * string_PARTICIPANTNUMBER     = eGetValueForKey(encodeKey, @"DEFAULTS_PARTICIPANTNUMBER");
    NSString * string_DEFAULTS_STUDYEMAIL   = eGetValueForKey(encodeKey, @"DEFAULTS_STUDYEMAIL");
    NSString * string_ENROLLMENTPASSWORD    = eGetValueForKey(encodeKey, @"DEFAULTS_ENROLLMENTPASSWORD");
    NSString * string_SEND_PASSWORD         = eGetValueForKey(encodeKey, @"DEFAULTS_SEND_PASSWORD");
    NSString * string_STUDY                 = eGetValueForKey(encodeKey, @"STUDY");
    
    float float_Inhale = decryptFloatForKey(@"inhale_duration");
    float float_Exhale = decryptFloatForKey(@"exhale_duration");
    float float_Hold = decryptFloatForKey(@"hold_duration");
    float float_Rest = decryptFloatForKey(@"rest_duration");
  
    [self setGCMModeSecure];
    /*saving new encdrypted values*/

    encryptFloatForKey(@"inhale_duration", float_Inhale);
    encryptFloatForKey(@"exhale_duration", float_Exhale);
    encryptFloatForKey(@"hold_duration", float_Hold);
    encryptFloatForKey(@"rest_duration", float_Rest);
    
    encryptBoolForKey(@"resetHelpPrompts", bool_resetHelpPrompts);
    encryptBoolForKey(@"resetHelpUserDefault", bool_resetHelpUserDefault);
    encryptBoolForKey(@"checkoxIsSelected", bool_checkoxIsSelected);
    encryptBoolForKey(@"eula_accepted_DHA", bool_eula_accepted);
    encryptBoolForKey(@"cb_initialized", bool_initialized);
    encryptBoolForKey(@"vocal_prompts", bool_vocal_prompts);
    encryptBoolForKey(@"background_type", bool_background_type);
    encryptBoolForKey(@"cb_session_enabled", bool_cb_session_enabled);
    encryptBoolForKey(@"cb_settings_prompt_shown", bool_cb_settings_prompt_shown);
    encryptBoolForKey(@"coping_cards_initialized", bool_copping_cards_initialized);
    encryptBoolForKey(@"coping_card_hints_viewed", bool_coping_card_hints_viewed);
    encryptBoolForKey(@"mahjong_initialized", bool_mahjong_initialied);
    encryptBoolForKey(@"pmr_initialized", bool_pmr_initialied);
    encryptBoolForKey(@"pmr_captions", bool_pmr_captions);
    encryptBoolForKey(@"sudoku_initialized", bool_sudoku_initialized);
    encryptBoolForKey(@"highlight", bool_hightlight);
    encryptBoolForKey(@"vhb_initialized", bool_vhb_initialized);
    
    if (bool_mahjong_background.length > 0)
    {
        eSaveValueForKey(encodeKey, bool_mahjong_background , @"mahjong_background");
    }
    if (string_USE_RESEARCHSTUDY.length > 0)
    {
        eSaveValueForKey(encodeKey, string_USE_RESEARCHSTUDY , @"resetHelpPrompts");
    }
    if (string_PARTICIPANTNUMBER.length > 0)
    {
        eSaveValueForKey(encodeKey, string_PARTICIPANTNUMBER , @"DEFAULTS_PARTICIPANTNUMBER");
    }
    if (string_DEFAULTS_STUDYEMAIL.length > 0)
    {
        eSaveValueForKey(encodeKey, string_DEFAULTS_STUDYEMAIL , @"DEFAULTS_STUDYEMAIL");
    }
    if (string_ENROLLMENTPASSWORD.length > 0)
    {
        eSaveValueForKey(encodeKey, string_ENROLLMENTPASSWORD , @"DEFAULTS_ENROLLMENTPASSWORD");
    }
    if (string_SEND_PASSWORD.length > 0)
    {
        eSaveValueForKey(encodeKey, string_SEND_PASSWORD , @"DEFAULTS_SEND_PASSWORD");
    }
    if(string_STUDY != nil) {
        eSaveValueForKey(encodeKey, string_STUDY, @"STUDY");
    }
}


// 09/24/2015
// This is needed when we install the DaRE version on an old unencrypted installation
- (void)convert2DaRE {
    
    self.databaseKey = old_FIPS_Pin();
    
    //fips latest version
    NSString * fipsVersionString = t2FIPSVersion();
    
    NSLog(@"Fips Current Version %@", fipsVersionString);
    
    int fipsLatestVersion = [self fipsVersionStringToInt:fipsVersionString];
    
    NSLog(@"Fips Latest Version %d", fipsLatestVersion);
    
    if(fipsLatestVersion == AMGcm) {
        [self setCBCModeUnsecure];
    }
    else {
        [self setGCMModeSecure];
    }

    /*********** User Defaults CHECK  ************/
    //lets check the version and updated it if needed
    NSString *fipsCurrVersionString = eGetValueForKey(old_FIPS_Pin(), kConvertVersion);
    int fipsCurrentVersion = [self fipsVersionStringToInt:fipsCurrVersionString];
    //is the existing data not in the latest fips?
    if (fipsLatestVersion != fipsCurrentVersion)
    {
        //encrypted data exist
        if (fipsCurrentVersion >= 0)
        {
            //is this a new installed or previous version 1?
            [self setCBCModeUnsecure];
            NSString *testValue = eGetValueForKey(old_FIPS_Pin(), kConvertToDaREdone);
            if (testValue == nil || [testValue length] != 0)
                
            {
                //migrating data
                [self encryptCoreDataToNewVersion:fipsLatestVersion];
            }
        }
    }
    if (fipsLatestVersion != fipsCurrentVersion)
    {
        //encrypted data exist
        if (fipsCurrentVersion >= 0)
        {
            //is this a new installed or previous version 1?
            [self setCBCModeUnsecure];
            NSString *testValue = eGetValueForKey(old_FIPS_Pin(), kConvertToDaREdone);
            if (testValue == nil || [testValue length] != 0)
            {
                //migrating data
                [self migrateUserDefaultsFromVersion:1 toLatest:fipsLatestVersion];
            }
        }
    }

    [self setGCMModeSecure]; 
  
    
    // And remember that we did this already...or we didn't need to do it!
    eSaveValueForKey(t2p(), @"YES", kConvertToDaREdone);
    eSaveValueForKey(t2p(), fipsVersionString, kConvertVersion);
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BOOL bContinue = YES;
    
    // 06/22/15 BGD Determine if we have DaRE implemented already
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *strDaREValue = [defaults objectForKey:kUserDefaultsKeyFIPSGCMImplemented];
    
    initT2Crypto();
    
    if (strDaREValue.length == 0) {

        [self convert2DaRE];

        [self decryptCoreDataSQL];
        
        [defaults setObject:@"YES" forKey:kUserDefaultsKeyFIPSGCMImplemented];
        
        [defaults synchronize];
        
    } else {
        NSLog(@"$$$$$$$$$$$$ 2DaRE has been implemented already on this device");
        // Decrypt the encrypted database
        [self decryptCoreDataSQL];
    }
    return bContinue;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isGrantedNotifications = false;
    notificationAlreadyDisplayed = false;
    
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    [self canEvaluatePolicy];

    NSLog(@"%@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        isGrantedNotifications = granted;
        NSLog(@"Notification status is %D", granted);
    }];
    
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(!decryptBoolForKey(@"vhb_initialized")){
        [self loadQuotes];
        [self loadActivityIdeas];
        
        [self saveContext];
        
        eSaveValueForKey(encodeKey, @"true", @"vhb_initialized");
        eSaveValueForKey(encodeKey, @"YES", @"ConvertedCoreData");
    }
    else {
        NSString *testValue = eGetValueForKey(encodeKey, @"ConvertedCoreData");
        if (testValue == nil || [testValue length] == 0 || [@"NO" isEqual: testValue]) {
            [self convertCoreData];
            eSaveValueForKey(encodeKey, @"YES", @"ConvertedCoreData");
        }
    }
    
    [SudokuAppDelegate initDataWithContext:[self managedObjectContext] defaults:nil];
    [MahjongAppDelegate initDataWithContext:[self managedObjectContext] defaults:nil];
    [CBAppDelegate initDataWithContext:[self managedObjectContext] defaults:nil];
    [PMRAppDelegate initDataWithContext:[self managedObjectContext] defaults:nil];
    [CopingCardAppDelegate initDataWithContext:[self managedObjectContext] defaults:nil];
    
    encryptStringForKey(@"vhb_version", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]);

    _assets = [[ALAssetsLibrary alloc] init];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSString *storyboardId = decryptBoolForKey(@"eula_accepted_DHA") ? @"home" : @"eula";
    UIViewController *rootController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:storyboardId];
    [((UINavigationController *)self.window.rootViewController) setViewControllers:[NSArray arrayWithObject:rootController]];
    
    //NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/vid.mov"]];
    //UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil);
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        ((UINavigationController *)self.window.rootViewController).navigationBar.tintColor = [UIColor darkGrayColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    UIImageView *imageView = (UIImageView *)[UIApplication.sharedApplication.keyWindow.subviews.lastObject viewWithTag:101];   // search by the same tag value
    [imageView removeFromSuperview];
    
    [self scheduleQuoteNotification];
}

- (void)scheduleQuoteNotification
{

    NSDate *time = decryptDateForKey(@"quote_reminder_time");
    BOOL scheduled = decryptBoolForKey(@"quote_reminder_scheduled");
    if (!time || !scheduled) {
        return;
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone defaultTimeZone];
    NSDateComponents *nowComps = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:now];
    NSInteger nowHour = [nowComps hour];
    NSInteger nowMinute = [nowComps minute];
    
    NSDateComponents *reminderComps = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:time];
    NSInteger hour = [reminderComps hour];
    NSInteger minute = [reminderComps minute];
    
    [nowComps setHour:hour];
    [nowComps setMinute:minute];
    
    NSDate *fire;
    if (nowHour >= hour && nowMinute >= minute) {
        fire = [[calendar dateFromComponents:nowComps] dateByAddingTimeInterval:(24*60*60)];
    } else {
        fire = [calendar dateFromComponents:nowComps];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss a zz"];
    
    NSLog(@"Scheduled for %@", [formatter stringFromDate:fire]);
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Quote" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: orderSortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![fetch performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    
    if (fetch.fetchedObjects.count == 0) {
        return;
    }

    NSInteger index = arc4random() % fetch.fetchedObjects.count;
    
    Quote *quote = (Quote *)[fetch.fetchedObjects objectAtIndex:index];

    
    NSDateComponents *finalReminder = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:fire];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    if (isGrantedNotifications){
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (content){
            content.title = @"VHB Inspiring Quote";
            content.body = dRaw(encodeKey, quote.body);
            content.sound = [UNNotificationSound defaultSound];
            content.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"quote", @"type", quote.objectID.URIRepresentation.absoluteString, @"uri", nil];
            
            UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:finalReminder repeats:YES];
            NSLog(@"The final time is %@",finalReminder);
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"UNLocalNotification" content:content trigger:trigger];
            [center addNotificationRequest:request withCompletionHandler:nil];
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    if ([@"quote" isEqualToString:[notification valueForKey:@"type"]]) {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateInactive) {
            [self scheduleQuoteNotification];
            UIViewController *rootController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"home"];
            [((UINavigationController *)self.window.rootViewController) setViewControllers:[NSArray arrayWithObject:rootController]];
            [((UINavigationController *)self.window.rootViewController) popToRootViewControllerAnimated:NO];

            if ([((UINavigationController *)self.window.rootViewController).topViewController isKindOfClass:[VHBSetupEULAViewController class]]) {
                UIViewController *rootController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"home"];
                [((UINavigationController *)self.window.rootViewController) setViewControllers:[NSArray arrayWithObject:rootController]];
            }

            [((UINavigationController *)self.window.rootViewController).topViewController performSegueWithIdentifier:@"quote_notification" sender:[NSURL URLWithString:[notification.request.content.userInfo valueForKey:@"uri"]]];

            NSLog(@"Quote Notification Launch Via Notification");
        }

        [self scheduleQuoteNotification];
        completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound);
    }
}


void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"%@", exception);
}

-(void) setGCMModeSecure
{
    setAM(AMGcm);
    setSM(SMSecure);
}

-(void) setCBCModeUnsecure
{
    setAM(AMCbc);
    setSM(SMUnsecure);
}

-(void) setGCMModeUnsecure
{
    setAM(AMGcm);
    setSM(SMUnsecure);
}

- (void) convertCoreData {
    NSError *error = nil;
    
    //Grab and convert quotes
    NSFetchRequest *quotefetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *quoteentity = [NSEntityDescription entityForName:@"Quote" inManagedObjectContext:self.managedObjectContext];
    [quotefetchRequest setEntity:quoteentity];
    NSArray *quotes = [self.managedObjectContext executeFetchRequest:quotefetchRequest error:&error];
    if (quotes != nil) {
        if ([quotes count] > 0) {
            for (Quote* quote in quotes) {
                [self setCBCModeUnsecure];
                NSString* decryptAuthor = dRaw(encodeKey, quote.author);
                NSString* decryptBody = dRaw(encodeKey, quote.body);
                [self setGCMModeSecure];
                quote.author = eRaw(encodeKey, decryptAuthor);
                quote.body = eRaw(encodeKey, decryptBody);
            }
        }
    }
    
    //Grab and convert visualreminders
    NSFetchRequest *vrfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *vrentity = [NSEntityDescription entityForName:@"VisualReminder" inManagedObjectContext:self.managedObjectContext];
    [vrfetchRequest setEntity:vrentity];
    NSArray *vrs = [self.managedObjectContext executeFetchRequest:vrfetchRequest error:&error];
    if (vrs != nil) {
        if ([vrs count] > 0) {
            for (VisualReminder* vr in vrs) {
                [self setCBCModeUnsecure];
                NSString* decryptVisaulReminderPath = dRaw(encodeKey, vr.assetPath);
                [self setGCMModeSecure];
                vr.assetPath = eRaw(encodeKey, decryptVisaulReminderPath);

                if (vr.thumbnailPath != nil && vr.thumbnailPath.length > 0) {
                    [self setCBCModeUnsecure];
                    NSString* decryptThumbnailPath = dRaw(encodeKey, vr.thumbnailPath);
                    [self setGCMModeSecure];
                    vr.thumbnailPath = eRaw(encodeKey, decryptThumbnailPath);
                }
                
                if (vr.title != nil && vr.title.length > 0) {
                    [self setCBCModeUnsecure];
                    NSString* decryptTitle = dRaw(encodeKey, vr.title);
                    [self setGCMModeSecure];
                    vr.title = eRaw(encodeKey, decryptTitle);
                }
            }
        }
    }
    
    //Grab and convert visualreminders
    NSFetchRequest *arfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *arentity = [NSEntityDescription entityForName:@"AudioReminder" inManagedObjectContext:self.managedObjectContext];
    [arfetchRequest setEntity:arentity];
    NSArray *ars = [self.managedObjectContext executeFetchRequest:arfetchRequest error:&error];
    if (ars != nil) {
        if ([ars count] > 0) {
            for (AudioReminder* ar in ars) {
                [self setCBCModeUnsecure];
                NSString* decryptAudioRemider = dRaw(encodeKey, ar.title);
                [self setGCMModeSecure];
                ar.title = eRaw(encodeKey, decryptAudioRemider);
                if (ar.filepath != nil && ar.filepath.length > 0) {
                    [self setCBCModeUnsecure];
                    NSString* decryptAudioReminderPath = dRaw(encodeKey, ar.filepath);
                    [self setGCMModeSecure];
                    ar.filepath = eRaw(encodeKey, decryptAudioReminderPath);
                }
                if (ar.artist != nil && ar.artist.length > 0) {
                    [self setCBCModeUnsecure];
                    NSString* decryptAudioReminderArtist = dRaw(encodeKey, ar.artist);
                    [self setGCMModeSecure];
                    ar.artist = eRaw(encodeKey, decryptAudioReminderArtist);
                }
            }
        }
    }
    
    //Grab and convert support contacts
    NSFetchRequest *contactfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *contactentity = [NSEntityDescription entityForName:@"SupportContact" inManagedObjectContext:self.managedObjectContext];
    [contactfetchRequest setEntity:contactentity];
    NSArray *contacts = [self.managedObjectContext executeFetchRequest:contactfetchRequest error:&error];
    if (contacts != nil) {
        if ([contacts count] > 0) {
            for (SupportContact* contact in contacts) {
                [self setCBCModeUnsecure];
                NSString* decryptFirstName = dRaw(encodeKey, contact.firstName);
                [self setGCMModeSecure];
                contact.firstName = eRaw(encodeKey, decryptFirstName);
                if (contact.lastName != nil && contact.lastName.length > 0) {
                    [self setCBCModeUnsecure];
                    NSString* decryptLastName = dRaw(encodeKey, contact.lastName);
                    [self setGCMModeSecure];
                    contact.lastName = eRaw(encodeKey, decryptLastName);
                }
            }
        }
    }
    
    //Grab and convert activity ideas
    NSFetchRequest *actfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *actentity = [NSEntityDescription entityForName:@"ActivityIdea" inManagedObjectContext:self.managedObjectContext];
    [actfetchRequest setEntity:actentity];
    NSArray *activities = [self.managedObjectContext executeFetchRequest:actfetchRequest error:&error];
    if (activities != nil) {
        if ([activities count] > 0) {
            for (ActivityIdea* idea in activities) {
                [self setCBCModeUnsecure];
                NSString*  decryptName = dRaw(encodeKey, idea.name);
                [self setGCMModeSecure];
                idea.name = eRaw(encodeKey, decryptName);
                if (idea.verb != nil && idea.verb.length > 0) {
                    [self setCBCModeUnsecure];
                    NSString* decryptVerb = dRaw(encodeKey, idea.verb);
                    [self setGCMModeSecure];
                    idea.verb = eRaw(encodeKey, decryptVerb);
                }
            }
        }
    }
    
    //Grab and convert coping cards
    NSFetchRequest *copingcardfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *copingcardentity = [NSEntityDescription entityForName:@"CopingCard" inManagedObjectContext:self.managedObjectContext];
    [copingcardfetchRequest setEntity:copingcardentity];
    NSArray *cards = [self.managedObjectContext executeFetchRequest:copingcardfetchRequest error:&error];
    if (cards != nil) {
        if ([cards count] > 0) {
            for (CopingCard* card in cards) {
                [self setCBCModeUnsecure];
                NSString* decryptProblem = dRaw(encodeKey, card.problem);
                [self setGCMModeSecure];
                card.problem = eRaw(encodeKey, decryptProblem);
            }
        }
    }
    
    //Grab and convert coping skills
    NSFetchRequest *copingskillfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *copingskillentity = [NSEntityDescription entityForName:@"CopingSkill" inManagedObjectContext:self.managedObjectContext];
    [copingskillfetchRequest setEntity:copingskillentity];
    NSArray *skills = [self.managedObjectContext executeFetchRequest:copingskillfetchRequest error:&error];
    if (skills != nil) {
        if ([skills count] > 0) {
            for (CopingSkill* skill in skills) {
                [self setCBCModeUnsecure];
                NSString *decryptSkill = dRaw(encodeKey, skill.skill);
                [self setGCMModeSecure];
                skill.skill = eRaw(encodeKey, decryptSkill);
            }
        }
    }
    //Grab and convert symptoms
    NSFetchRequest *symptomsfetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *symptomsentity = [NSEntityDescription entityForName:@"Symptom" inManagedObjectContext:self.managedObjectContext];
    [symptomsfetchRequest setEntity:symptomsentity];
    NSArray *symptoms = [self.managedObjectContext executeFetchRequest:symptomsfetchRequest error:&error];
    if (symptoms != nil) {
        if ([symptoms count] > 0) {
            for (Symptom* symptom in symptoms) {
               
                [self setCBCModeUnsecure];
                NSString* decryptSymptom = dRaw(encodeKey, symptom.symptom);
                [self setGCMModeSecure];
                symptom.symptom = eRaw(encodeKey, decryptSymptom);
            }
        }
    }
    NSError *saveerror = nil;
    if (![self.managedObjectContext save:&saveerror]) {
        NSLog(@"Error");
    }
    else {
        [self encryptCoreDataSQL];
    }
}


- (void)loadActivityIdeas
{
    NSDate *date = [NSDate date];
    
    ActivityIdea *idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Fishing");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Running");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Walking");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Movie");
    idea.verb = eRaw(encodeKey, @"watch a");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Hang Out");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Biking");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Dinner");
    idea.verb = eRaw(encodeKey, @"have");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Lunch");
    idea.verb = eRaw(encodeKey, @"have");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Breakfast");
    idea.verb = eRaw(encodeKey, @"have");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Golf");
    idea.verb = eRaw(encodeKey, @"play");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Basketball");
    idea.verb = eRaw(encodeKey, @"play");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Tennis");
    idea.verb = eRaw(encodeKey, @"play");
    
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Soccer");
    idea.verb = eRaw(encodeKey, @"play");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Bowling");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Gym");
    idea.verb = eRaw(encodeKey, @"go to the");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Swimming");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Hiking");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Pool");
    idea.verb = eRaw(encodeKey, @"play");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Camping");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Shopping");
    idea.verb = eRaw(encodeKey, @"go");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Beach");
    idea.verb = eRaw(encodeKey, @"go to the");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Coffee / Tea");
    idea.verb = eRaw(encodeKey, @"have");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Study");
    idea.verb = eRaw(encodeKey, @"");
    idea.dateCreated = date;
    
    idea = [NSEntityDescription insertNewObjectForEntityForName:@"ActivityIdea" inManagedObjectContext:[self managedObjectContext]];
    idea.name = eRaw(encodeKey, @"Cards");
    idea.verb = eRaw(encodeKey, @"play");
    idea.dateCreated = date;
}

- (void)loadQuotes
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"quotes" ofType:@"txt"];
    NSString *quotesFile = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
    NSMutableArray *lines = [[NSMutableArray alloc] initWithArray:[quotesFile componentsSeparatedByString:@"\n"]];
    
    NSDate *creationDate = [NSDate date];
    NSArray *data;
    Quote *quote;
    
    for (NSString *line in lines) {
        data = [[NSArray alloc] initWithArray:[line componentsSeparatedByString:@"|"]];
        if (data.count < 2) {
            continue;
        }
        quote = [NSEntityDescription insertNewObjectForEntityForName:@"Quote" inManagedObjectContext:[self managedObjectContext]];
        quote.dateCreated = creationDate;
        quote.body = eRaw(encodeKey, [data objectAtIndex:0]);
        quote.author = eRaw(encodeKey, [data objectAtIndex:1]);
        quote.favorite = [NSNumber numberWithBool:NO];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.window.bounds];
    
    //Tag to keep reference of privacyView in self
    imageView.tag = 101;
    //Set ImageView content mode to aspect fill to prevent image being distorted
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    //ImageView setting image
    [imageView setImage:[UIImage imageNamed:@"DHA-splash.png"]];
    //Add ImageView as a Subview
    [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:imageView];
    
    [VHBLogUtils clearTimedEvents];
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
//    float width = [UIScreen mainScreen].bounds.size.width;
//    float height =[UIScreen mainScreen].bounds.size.height;
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
//    imageView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
//    [self.window addSubview:imageView];
//    imageView.contentMode  = UIViewContentModeScaleAspectFill;
//    [self.window bringSubviewToFront:imageView];
//    
//    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
//                                                      object:nil
//                                                       queue:[NSOperationQueue mainQueue]
//                                                  usingBlock:^(NSNotification* a) {
//                                                      [self.window sendSubviewToBack:imageView];
//                                                  }];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.window.bounds];
//    
//    imageView.tag = 101;    // Give some decent tagvalue or keep a reference of imageView in self
//    //    imageView.backgroundColor = [UIColor redColor];
//    [imageView setImage:[UIImage imageNamed:@"Default-568h@2x.png"]];   // assuming Default.png is your splash image's name
//    
//    [UIApplication.sharedApplication.keyWindow.subviews.lastObject addSubview:imageView];
    
    [self saveContext];
    [self deletedatabase];
}

- (BOOL)canEvaluatePolicy {
    LAContext *context = [[LAContext alloc] init];
    __block  NSString *message;
    NSError *error;
    BOOL success;
    
    // test if we can evaluate the policy, this test will tell us if Touch ID is available and enrolled
    
    success = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthentication error:&error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // write all your code here
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // write all your code here
                [self evaluatePolicy];
            });
            //message = [NSString stringWithFormat:@"Touch ID is available"];
        }
        else if(error) {
            
            switch (error.code) {
                case LAErrorTouchIDNotEnrolled:
                    message = [NSString stringWithFormat:@"Touch ID is not available"];
                    
                    [self showAlert:@"Biometrics Not Enabled" setMessage:message];
                    break;
                    //case LA:
                    
                case LAErrorPasscodeNotSet:
                    message = [NSString stringWithFormat:@"Plase enable passcode in your phone setting  to setup Touch ID"];
                    
                    [self showAlert:@"Passcode Not Set" setMessage:message];
                    
                case LAErrorUserCancel:
                    
                case LAErrorTouchIDNotAvailable:
                    message = [NSString stringWithFormat:@"Touch ID is not available for this phone"];
                    
                    //[self showAlert:@"Touch ID Not Avilable" setMessage:message];
                    
                    NSLog(@"user pressed cancel");
                    
                    //[self evaluatePolicy];
                    
                default:
                    break;
            }
        }
    });
    return  success;
}


- (void)evaluatePolicy {
    LAContext *context = [[LAContext alloc] init];
    //    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:self.window.bounds];
    
    // Show the authentication UI with our reason string.
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Unlock access to locked feature" reply:^(BOOL success, NSError *authenticationError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                
                //[imageView removeFromSuperview];
            }
            else  if (authenticationError){
                
                //message = [NSString stringWithFormat:@"evaluatePolicy: %@", authenticationError.localizedDescription];
                
                switch (authenticationError.code) {
                    case LAErrorUserCancel:
                        
                        NSLog(@"USER CANCELD");
                        //[self showAlert:@"Touch ID " setMessage:@"Enter a pin or set up touch id"];
                        [self evaluatePolicy];
                        break;
                        
                    default:
                        break;
                }
                //[self showAlert:@"Authentication Unsuccessful" setMessage:@"Touch ID or passcode unsuccessful."];
            }
        });
    }];
}

-(void) showAlert: (NSString*) title setMessage:(NSString*) message {
    
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    
    [alert addAction:okButton];
    
    
    UIViewController *viewController =  [[[[UIApplication sharedApplication] delegate]window ] rootViewController];
    
    if ( viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed ) {
        viewController = viewController.presentedViewController;
    }
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:alert.view
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationLessThanOrEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1
                                      constant:viewController.view.frame.size.height*2.0f];
    
    [alert.view addConstraint:constraint];
    [viewController presentViewController:alert animated:YES completion:^{
        
        NSLog(@"pressed okay");

    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self canEvaluatePolicy];
    [self decryptCoreDataSQL];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges]) {
            if(![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                //abort();
            }
            else {
                [self encryptCoreDataSQL];
            }
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        __backgroundManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [__backgroundManagedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VirtualHopeBoxModel" withExtension:@"momd"];
    NSManagedObjectModel *vhbModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSManagedObjectModel *mahjongModel = [MahjongAppDelegate getObjectModels];
    NSManagedObjectModel *sudokuModel = [SudokuAppDelegate getObjectModels];
    NSManagedObjectModel *cbModel = [CBAppDelegate getObjectModels];
    NSManagedObjectModel *ccModel = [CopingCardAppDelegate getObjectModels];
    
    
    __managedObjectModel = [NSManagedObjectModel modelByMergingModels:[NSArray arrayWithObjects:vhbModel, sudokuModel, mahjongModel, cbModel, ccModel, nil]];
    return __managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [self getStoreURL];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             @{@"journal_mode": @"TRUNCATE"}, NSSQLitePragmasOption, nil];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error = nil;
    __persistentStore = [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
    if (!__persistentStore) {
        NSLog(@"Error: %@",error);
    }
    
    return __persistentStoreCoordinator;
}

-(NSURL *)getStoreURL {
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: kFilenameSQL];
    /*
     Set up the store.
     For the sake of illustration, provide a pre-populated default store.
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:storePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:SQL_FILE_BASE ofType:@"sqlite"];
        if (defaultStorePath) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
    
    return storeUrl;
}

#pragma mark - Application's Documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    // Disable Enrollment   - Remove this line to enable Enrollment
    return NO;
}

- (void)emailEnrollment
{
    // Fetch filtered data
    NSString* pNum = eGetValueForKey(encodeKey, @"DEFAULTS_PARTICIPANTNUMBER");
    NSString *email = eGetValueForKey(encodeKey, @"DEFAULTS_STUDYEMAIL");
    NSString* pword = eGetValueForKey(encodeKey, @"DEFAULTS_ENROLLMENTPASSWORD");
    // Open mail view
    MailData *data = [[MailData alloc] init];
    data.mailRecipients = [NSArray arrayWithObjects:email, nil];
    NSString *subjectString = [NSString stringWithFormat:@"VHB Study Enrollment"];
    data.mailSubject = subjectString;
    //Set the salt mode to unsecure
    [self setGCMModeUnsecure];
    NSString *bodyString = [NSString stringWithFormat:@"Password record for:\r\nParticipant#:%@\r\n\r\n http://key.enrollment.local?key=%@", pNum, eRaw(encodeKey, pword)];
    //Set salt mode to secure
    [self setGCMModeSecure];
    data.mailBody = [NSString stringWithFormat:@"%@", bodyString];
}

-(void)sendMail:(MailData *)data
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:data.mailSubject];
        [mail setMessageBody:data.mailBody isHTML:YES];
        [mail setToRecipients:data.mailRecipients];
        
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:mail animated:YES completion:nil];
    }
    else
    {
        //[self launchMailAppOnDeviceWithMailData:data];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch(result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
    }
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


-(void) upgradeStudyEnrollmentFileFromFIPSVersion:(int)currVersion toLatest:(int)latestVersion {
    NSString *participant = eGetValueForKey(encodeKey,  @"DEFAULTS_PARTICIPANTNUMBER");
    NSString * pword = eGetValueForKey(encodeKey, @"DEFAULTS_ENROLLMENTPASSWORD");
    NSString * fileName = [NSString stringWithFormat:@"VirtualHopeBox_Participant_%@.csv",participant];
    NSArray  * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString * documentsDir = [paths objectAtIndex:0];
    NSString * finalPath = [NSString stringWithFormat:@"%@/%@",documentsDir, fileName];
    
    if(currVersion > 0) {
        setAM(currVersion);
        if(currVersion == AMCbc) {
            setSM(SMUnsecure);
        }
        //Decrypt the file
        NSMutableString * txtFile = [NSMutableString string];
        NSString* fileContents = [NSString stringWithContentsOfFile:finalPath encoding:NSUTF8StringEncoding error:nil];
        if(fileContents != nil) {
            NSArray* allLines = [fileContents componentsSeparatedByString:@"\n"];
            
            for(int i = 0; i < allLines.count; i++) {
                if([allLines[i] length] != 0) {
                    NSString* line = allLines[i];
                    [txtFile appendFormat:@"%@\n", dRaw(pword, line)];
                }
            }
            [txtFile writeToFile:finalPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
    
    //Encrypt the file
    [self setGCMModeUnsecure];
    NSMutableString * txtFile = [NSMutableString string];
    NSString* fileContents = [NSString stringWithContentsOfFile:finalPath encoding:NSUTF8StringEncoding error:nil];
    if(fileContents != nil) {
        //Once decrypted we will have a newline that was encrypted and a newline seperating the encrypted lines
        NSArray* allLines = [fileContents componentsSeparatedByString:@"\n\n"];
        for(int i = 0; i < allLines.count; i++) {
            if([allLines[i] length] != 0) {
                NSString* line = [allLines[i] stringByAppendingString:@"\n"];
                [txtFile appendFormat:@"%@\n", eRaw(pword, line)];
            }
        }
        [txtFile writeToFile:finalPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    [self setGCMModeSecure];
}




@end
