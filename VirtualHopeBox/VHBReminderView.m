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

#import "VHBReminderView.h"

@interface VHBReminderView () {

}

@end

@implementation VHBReminderView
@synthesize thumbnailView;
@synthesize durationView;
@synthesize overlayView;
@synthesize overlayIconView;
@synthesize reminder = _reminder;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        thumbnailView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return self;
}

- (VisualReminder *)getReminder
{
    return _reminder;
}

- (void)setReminder:(VisualReminder *)reminder
{
    _reminder = reminder;

    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self addSubview:thumbnailView];
    
    if (reminder) {
        if ([reminder.assetType isEqualToString:@"YOUTUBE"] || [reminder.assetType isEqualToString:ALAssetTypeVideo]) {
            overlayIconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, self.bounds.size.height - 15, 16, 10)];
            overlayIconView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"video" ofType:@"png"]];
            overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20)];
            overlayView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
            durationView = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 45, self.bounds.size.height - 20, 40, 20)];
            durationView.textAlignment = NSTextAlignmentRight;
            durationView.font = [UIFont boldSystemFontOfSize:13.0];
            durationView.textColor = [UIColor whiteColor];
            durationView.backgroundColor = [UIColor clearColor];
            [self addSubview:overlayView];
            [self addSubview:durationView];
            [self addSubview:overlayIconView];
        } else if (reminder.assetType == ALAssetTypePhoto) {
            overlayView = nil;
            durationView = nil;
            overlayIconView = nil;
        }
    }
}

@end
