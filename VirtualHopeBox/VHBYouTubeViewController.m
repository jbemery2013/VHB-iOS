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

#import "VHBYouTubeViewController.h"

@interface VHBYouTubeViewController () {
    NSArray *rows;
    NSMutableData *responseData;
    NSURLConnection *connection;
    int startIndex, resultCount;
    MBProgressHUD *hud;
}

@end

@implementation VHBYouTubeViewController
@synthesize searchBar;
@synthesize delegate;
@synthesize backButton;
@synthesize saveButton;
NSMutableDictionary* selections;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:backButton, nil]];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:saveButton, nil]];
    self.tableView.tableHeaderView = searchBar;
    searchBar.delegate = self;
    startIndex = 1;
    resultCount = 20;
    [self.tableView registerNib:[UINib nibWithNibName:@"VHBYouTubeReminderCell" bundle:nil] forCellReuseIdentifier:@"youTubeCell"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [searchBar becomeFirstResponder];
}

- (NSString *)urlEncode:(NSString *)str
{
    NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    return result;
}

- (void)viewDidUnload
{
    rows = nil;
    selections = nil;
    responseData = nil;
    connection = nil;
    delegate = nil;
    [self setSearchBar:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"youTubeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VHBYouTubeReminderCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    // Configure the cell...
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    UILabel *author = (UILabel *)[cell viewWithTag:2];
    
    NSDictionary *row = [rows objectAtIndex:indexPath.row];
    NSDictionary *snippet = [row objectForKey:@"snippet"];
    
    NSDictionary *thumbnails = [[snippet objectForKey:@"thumbnails"] objectForKey:@"default"];
    [self loadImageInCell:cell url:[NSURL URLWithString:[thumbnails objectForKey:@"url"]]];
    
    title.text = [snippet objectForKey:@"title"];
    author.text = [snippet objectForKey:@"channelTitle"];
    
    int titleHeight =[VHBViewUtils boundingRectForString:title.text withSize:CGSizeMake(214, 52) font:title.font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft].height;
    
    CGRect frame = title.frame;
    frame.size.height = titleHeight;
    title.frame = frame;
    frame = author.frame;
    frame.origin.y = title.frame.origin.y + titleHeight + 2;
    author.frame = frame;
    
    return cell;
}

- (void)loadImageInCell:(UITableViewCell *)cell url:(NSURL *)url
{
    UIImageView *img = (UIImageView *)[cell viewWithTag:3];
    [img setImageWithURL:url placeholderImage:[UIImage imageNamed:@"youtube.png"]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)bar
{
    [self query:[bar text]];
    [bar resignFirstResponder];
}

- (void)query:(NSString *)q
{
    hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    hud.userInteractionEnabled = NO;
    [self.navigationController.view addSubview:hud];
    [hud show:YES];
    
    NSString *key = @"AIzaSyBWQ9ydq7ZE7GbRdD5_Tt1mlK66nahy96M";//@"AI39si7MTKRN8WhD-PjPShszFM0plR95CWG-Tg24qdYrp49vqAJzGTVmLQzgNjtUThGQygW_ARBqScgQeIgpGW6af5e16ZEBRw";
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=%@&maxResults=%i&key=%@", [self urlEncode:q], resultCount, key];
    //NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    responseData = [NSMutableData data];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else if([(NSString*)[json objectForKey:@"kind"] containsString:@"searchListResponse"] == YES){
        NSArray *items = [json objectForKey:@"items"];
        NSMutableArray* ids = [[NSMutableArray alloc] init];
        for (int i = 0; i < items.count; i++) {
            NSDictionary *row = [items objectAtIndex:i];
            [ids addObject:[[row objectForKey:@"id"] objectForKey:@"videoId"]];
        }
        NSString* result = [ids componentsJoinedByString:@","];
        
        NSString *key = @"AIzaSyBWQ9ydq7ZE7GbRdD5_Tt1mlK66nahy96M";
        NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=%@&key=%@", result, key];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        responseData = [NSMutableData data];
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    else {
        rows = [json objectForKey:@"items"];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [hud hide:YES];
        [hud removeFromSuperview];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *row = [rows objectAtIndex:indexPath.row];
    NSDictionary *snippet = [row objectForKey:@"snippet"];
    NSString *title = [snippet objectForKey:@"title"];
    
//    NSDictionary *mediaGroup = [row objectForKey:@"media$group"];
//    int duration = [[[mediaGroup objectForKey:@"yt$duration"] objectForKey:@"seconds"] intValue];
    
    NSString *href = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@",[row objectForKey:@"id"]];
    
    NSLog(@"%@", row);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *img = (UIImageView *)[cell viewWithTag:3];
    
    if(selections == nil) {
        selections = [[NSMutableDictionary alloc] init];
    }
    
    [selections setObject:[[NSArray alloc] initWithObjects:title, href, img.image, 0, nil] forKey:indexPath];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [selections removeObjectForKey:indexPath];
}

- (IBAction)cancelClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveClicked:(id)sender {
    if(selections != nil) {
        NSArray* items = [selections allValues];
        for (int i = 0; i < items.count; i++) {
            NSArray* item = [items objectAtIndex:i];
            
            [delegate youTubeVideoSelected:[item objectAtIndex:0] url:[item objectAtIndex:1] thumbnail:[item objectAtIndex:2] duration:0];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
