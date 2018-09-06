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

#import "ResearchUtility.h"

@implementation ResearchUtility

+ (BOOL)isEnrolled
{
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *participant = decryptStringForKey(@"DEFAULTS_PARTICIPANTNUMBER");
    return participant != nil && participant.length > 0;
}

+ (void)logEvent:(NSString *)view withItem:(NSString *)item withAction:(NSString *)action withValue:(NSString *)value
{
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Research Study
    
    NSString *participant = decryptStringForKey(@"DEFAULTS_PARTICIPANTNUMBER");
    if (!participant) {
        return;
    }
    NSString* supersecretvalue = decryptStringForKey(@"DEFAULTS_ENROLLMENTPASSWORD");
    
    NSLog(@"Logging: %@, %@, %@, %@", view, item, action, value);
    NSMutableString *txtFile = [NSMutableString string];
    NSDate *today = [NSDate date];
    NSString* ver = [[UIDevice currentDevice] systemVersion];
    
    // File Name
    NSString *fileName = [NSString stringWithFormat:@"VirtualHopeBox_Participant_%@.csv",participant];
    
    // Device
    NSString *device = [[UIDevice currentDevice] model];
    
    //participant = Participant
    //today = Timestamp
    //device = Device
    //(manual entry) = OS
    //ver = OS Version
    //(manual entry) = App
    //(manual entry) = App Version
    //duration = Duration (sec)
    //section = Section
    //item = Item
    //activityString = Activity
    //value = Value
    
    // Change Hard Coded info for app version number when updating
    NSString *appVersion = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSString *itemString = item;
    if (!itemString) {
        itemString = @"";
    }
    
    NSString *valString = value;
    if (!valString) {
        valString = @"Null";
    } else {
        valString = [valString stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    }
    
    NSString * logLine = [NSString stringWithFormat:@"%@,%@,%@,iOS,%@,VHB,%@,%@,%@,%@,\"%@\"\n", participant, today, device, ver, appVersion, view, itemString, action, valString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *finalPath = [NSString stringWithFormat:@"%@/%@",documentsDir, fileName];
    
    
    NSString* fileContents = [NSString stringWithContentsOfFile:finalPath
                                                       encoding:NSUTF8StringEncoding error:nil];
    [txtFile appendFormat:@"%@", fileContents];
    setSM(SMUnsecure);
    [txtFile appendFormat:@"%@\n", eRaw(supersecretvalue, logLine)];
    setSM(SMSecure);
    NSError *error;
    [txtFile writeToFile:finalPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error writing to log file: %@", error);
    }
}

@end
