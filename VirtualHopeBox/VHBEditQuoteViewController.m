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

#import "VHBEditQuoteViewController.h"

@interface VHBEditQuoteViewController()
@end

@implementation VHBEditQuoteViewController
@synthesize bodyField;
@synthesize authorField;
@synthesize quote;
@synthesize managedObjectContext;
@synthesize doneButton;
@synthesize delegate;

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
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    authorField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Author" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:.5 alpha:1.0]}];
    bodyField.placeholderColor = [UIColor colorWithWhite:.5 alpha:1.0];
	bodyField.placeholder = @"Quote";
    bodyField.delegate = self;
    authorField.delegate = self;
    
    if (quote) {
        bodyField.text = dRaw(encodeKey, quote.body);
        authorField.text = dRaw(encodeKey, quote.author);
        self.title = @"Edit Quote";
    } else {
        self.title = @"Add Quote";
    }
    
    doneButton.accessibilityHint = @"Saves this quote.";
    
    [self updateDoneButton];
}

- (void)viewDidUnload
{
    [self setBodyField:nil];
    [self setAuthorField:nil];
    [self setDoneButton:nil];
    [self setManagedObjectContext:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doneClicked:(id)sender 
{
    if (!doneButton.enabled) {
        return;
    }
    
    BOOL edit = YES;
    
    if (!quote) {
        quote = [NSEntityDescription insertNewObjectForEntityForName:@"Quote" inManagedObjectContext:managedObjectContext];
        quote.dateCreated = [NSDate date];
        quote.favorite = [NSNumber numberWithBool:YES];
        edit = NO;
    }
    
    quote.body = eRaw(encodeKey, bodyField.text);
    quote.author = eRaw(encodeKey, authorField.text);
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    NSError *error;
//    [managedObjectContext save:&error];
//    if (error) {
//        NSLog(@"%@", error);
//    }
    
    if (edit) {
        [self.delegate quoteUpdated:quote];
    } else {
        [self.delegate quoteCreated:quote];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger newLength = (textView.text.length - range.length) + text.length;
    return newLength <= 440 ? YES : NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [bodyField becomeFirstResponder];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateDoneButton];
}

- (void)updateDoneButton
{
    doneButton.enabled = [bodyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}

@end
