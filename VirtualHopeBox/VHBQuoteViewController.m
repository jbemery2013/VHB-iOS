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

#import "VHBQuoteViewController.h"

@interface VHBQuoteViewController ()

@end

@implementation VHBQuoteViewController

@synthesize authorLabel;
@synthesize bodyLabel;
@synthesize favoriteIcon;
@synthesize pageLabel;
@synthesize quoteLabel;
@synthesize index;
@synthesize quote;
@synthesize count;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)layout
{
    if (!quote) {
        return;
    }
    
    bodyLabel.text = [NSString stringWithFormat:@"          %@", dRaw(encodeKey, quote.body)];
    authorLabel.text = dRaw(encodeKey, quote.author);
    pageLabel.text = [NSString stringWithFormat:@"%i of %i", index+1, count];
    favoriteIcon.hidden = ![quote.favorite boolValue];
    
    self.view.accessibilityLabel = [NSString stringWithFormat:@"Quote %@. %@. %@. %@", pageLabel.text, dRaw(encodeKey, quote.body), dRaw(encodeKey, quote.author), quote.favorite.boolValue ? @"Favorite." : @""];
    self.view.accessibilityHint = @"Double tap and hold to edit or delete.";
    
    [bodyLabel sizeToFit];
    CGRect bodyFrame = bodyLabel.frame;
    int maxHeight = self.view.frame.size.height - 50;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (bodyFrame.size.height > maxHeight) {
            bodyFrame = CGRectMake(bodyLabel.frame.origin.x, bodyLabel.frame.origin.y, 280, maxHeight);
        }
        
        bodyFrame.origin.y = (self.view.frame.size.height - bodyFrame.size.height - 30) / 2.0;
        bodyLabel.frame = bodyFrame;
        
        [authorLabel setFrame:CGRectMake(20, bodyFrame.origin.y + bodyFrame.size.height + 10, self.view.frame.size.width - (favoriteIcon.hidden ? 40 : 80), 20)];
        [favoriteIcon setFrame:CGRectMake(self.view.bounds.size.width - 56, bodyFrame.origin.y + 7 + bodyFrame.size.height, 24, 24)];
        
        CGRect frame = quoteLabel.frame;
        frame.origin.y = bodyFrame.origin.y - 26;
        quoteLabel.frame = frame;
    } else {
        if (bodyFrame.size.height > maxHeight) {
            bodyFrame = CGRectMake(bodyLabel.frame.origin.x, 20, 689, maxHeight);
        }
        
        bodyFrame.origin.y = (self.view.frame.size.height - bodyFrame.size.height - 30) / 2.0;
        bodyLabel.frame = bodyFrame;
        [authorLabel setFrame:CGRectMake(20, bodyLabel.frame.origin.y + bodyLabel.frame.size.height + 20, self.view.frame.size.width - 60, 56)];
        
        CGRect frame = quoteLabel.frame;
        frame.origin.y = bodyLabel.frame.origin.y - 30;
        quoteLabel.frame = frame;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [self layout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
