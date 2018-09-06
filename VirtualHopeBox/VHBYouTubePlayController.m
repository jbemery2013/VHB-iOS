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

#import "VHBYouTubePlayController.h"

@interface VHBYouTubePlayController () {
    NSTimer *hideTimer;
}
@end

@implementation VHBYouTubePlayController
@synthesize webView;
@synthesize url;

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
    
    NSString *youTubeVideoHTML = @"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background:#000;margin-top:0px;margin-left:0px\"><div><object width=\"320\" height=\"480\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\" value=\"transparent\"></param><embed src=\"%@\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"320\" height=\"480\"></embed></object></div></body></html>";
    
    // Populate HTML with the URL and requested frame size
    NSString *html = [NSString stringWithFormat:youTubeVideoHTML, @"http://www.youtube.com/watch?v=EfEp6gKPU_8", @"http://www.youtube.com/watch?v=EfEp6gKPU_8"];
    
    // Load the html into the webview
    [webView loadHTMLString:html baseURL:nil];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setUrl:nil];

    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
