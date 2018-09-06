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

#import "VHBHomeViewController.h"

@interface VHBHomeViewController () {
    
    int prevReminder;
}

@end

@implementation VHBHomeViewController
@synthesize settingsButton;
@synthesize contactButton;
@synthesize managedObjectContext;
@synthesize assetsLibrary;
@synthesize distractButton;
@synthesize inspireButton;
@synthesize relaxButton;
@synthesize copingButton;
@synthesize distractLabel;
@synthesize relaxLabel;
@synthesize inspireLabel;
@synthesize copingLabel;
@synthesize reminderTimer;
@synthesize navigationBarItem;
@synthesize reminderOneImageView;
@synthesize reminderTwoImageView;
@synthesize remindLabel;
@synthesize reminderWrapperView;
@synthesize fetchedResultsController = _fetchedResultsController;

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
    
    [self.navigationItem setHidesBackButton:YES];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    assetsLibrary = appDelegate.assets;
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self performSelectorInBackground:@selector(loadReminder) withObject:nil];
    
    [contactButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    [settingsButton setAccessibilityLabel:NSLocalizedString(@"Settings", @"")];
    [navigationBarItem setLeftBarButtonItem:settingsButton];
    
    [navigationBarItem setRightBarButtonItem:contactButton];
    
    
    float outlineWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 5 : 9;
    
    remindLabel.outlineColor = [UIColor blackColor];
    remindLabel.outlineWidth = outlineWidth;
    
    outlineWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 3 : 5;
    
    distractLabel.outlineColor = [UIColor blackColor];
    distractLabel.outlineWidth = outlineWidth;
    inspireLabel.outlineColor = [UIColor blackColor];
    inspireLabel.outlineWidth = outlineWidth;
    copingLabel.outlineColor = [UIColor blackColor];
    copingLabel.outlineWidth = outlineWidth;
    relaxLabel.outlineColor = [UIColor blackColor];
    relaxLabel.outlineWidth = outlineWidth;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    reminderTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(cycleImages) userInfo:nil repeats:YES];
    [self performSelectorInBackground:@selector(loadReminder) withObject:nil];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cycleImages) userInfo:nil repeats:NO];
    
    [VHBLogUtils logEventType:LETHomeOpen];
    [VHBLogUtils startTimedEvent:LETHomeClose];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [reminderTimer invalidate];
    reminderTimer = nil;
    //reminderOneImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"splash" ofType:@"png"]];
    
    [VHBLogUtils endTimedEvent:LETHomeClose];
}

- (void)cycleImages
{
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{ 
        reminderOneImageView.alpha = 0.0;
    } completion:^(BOOL finished) {
        reminderOneImageView.image = reminderTwoImageView.image;
        reminderTwoImageView.image = nil;
        reminderOneImageView.alpha = 1.0;
        
        [self performSelectorInBackground:@selector(loadReminder) withObject:nil];
    }];
}

- (void)loadReminder
{
    int count = (int)self.fetchedResultsController.fetchedObjects.count;
    if (count > 0) {
        int index = 0;
        do {
            index = arc4random() % count;
        } while (count > 1 && index == prevReminder);
        prevReminder = index;
        
        VisualReminder *reminder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [assetsLibrary assetForURL:[NSURL URLWithString:dRaw(encodeKey, reminder.assetPath)] resultBlock:^(ALAsset *asset) {
            if (asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                CGImageRef ref = [rep fullResolutionImage];
                
                UIImageOrientation orientation = UIImageOrientationUp;
                NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
                if (orientationValue != nil) {
                    orientation = [orientationValue intValue];
                }
                
                if (ref) {
                    UIImage *img = [self resizeImage:[UIImage imageWithCGImage:ref scale:1 orientation:orientation] toSize:reminderWrapperView.frame.size withCropRect:reminderWrapperView.frame];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        reminderTwoImageView.image = img;
                    });
                }
            }
        } failureBlock:^(NSError *myerror) {
            NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *splash = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"splash" ofType:@"png"]];
            reminderTwoImageView.image = splash;
        });
    }
}

- (UIImage *)resizeImage:(UIImage *)img toSize:(CGSize)newSize withCropRect:(CGRect)cropRect {
    CGImageRef                  imageRef;
    CGSize                      inputSize;
    UIImage                     *outputImage = nil;
    CGFloat                     scaleFactor, width;
    
    // resize, maintaining aspect ratio:
    
    float screenScale = [[UIScreen mainScreen] scale];
    
    scaleFactor = newSize.height / img.size.height;
    width = roundf(img.size.width * scaleFactor);
    
    if (width > newSize.width) {
        scaleFactor = newSize.width / img.size.width;
        newSize.height = roundf( img.size.height * scaleFactor );
    } else {
        newSize.width = width;
    }
    
    newSize.width *= screenScale;
    newSize.height *= screenScale;
    
    cropRect.origin.x *= screenScale;
    cropRect.origin.y *= screenScale;
    cropRect.size.width *= screenScale;
    cropRect.size.height *= screenScale;
    
    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    inputSize = newSize;
    
    // constrain crop rect to legitimate bounds
    if (cropRect.origin.x >= inputSize.width || cropRect.origin.y >= inputSize.height) return outputImage;
    if (cropRect.origin.x + cropRect.size.width >= inputSize.width) cropRect.size.width = inputSize.width - cropRect.origin.x;
    if (cropRect.origin.y + cropRect.size.height >= inputSize.height) cropRect.size.height = inputSize.height - cropRect.origin.y;
    
    // crop
    if ((imageRef = CGImageCreateWithImageInRect( outputImage.CGImage, cropRect))) {
        outputImage = [[UIImage alloc] initWithCGImage: imageRef];
        CGImageRelease(imageRef);
    }
    
    return outputImage;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetType == %@", @"IMAGE"];
    [fetchRequest setPredicate:predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    //NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    //[fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

- (void)viewDidUnload
{
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [self setReminderTimer:nil];
    [self setSettingsButton:nil];
    [self setContactButton:nil];
    [self setNavigationBarItem:nil];
    [self setReminderOneImageView:nil];
    [self setReminderTwoImageView:nil];
    [self setRemindLabel:nil];
    [self setReminderWrapperView:nil];
    [self setDistractButton:nil];
    [self setInspireButton:nil];
    [self setRelaxButton:nil];
    [self setCopingButton:nil];
    [self setDistractLabel:nil];
    [self setRelaxLabel:nil];
    [self setInspireLabel:nil];
    [self setCopingLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"quote_notification"]) {
        VHBQuotesPageViewController *destination = segue.destinationViewController;
        destination.initialQuote = sender;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
