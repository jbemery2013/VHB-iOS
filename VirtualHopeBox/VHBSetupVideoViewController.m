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

#import "VHBSetupVideoViewController.h"

@interface VHBSetupVideoViewController () {
    BOOL loading, hasCamera, capturing;
    int selectedPosition, rows, cols;
    NSString *cellNibName;
    NSDate *sessionStart;
}

@end

@implementation VHBSetupVideoViewController

@synthesize titleLabel;
@synthesize tableView;
@synthesize messageScrollView;
@synthesize addButton;
@synthesize reminders;
@synthesize mediaAssets;
@synthesize popoverController;
@synthesize nextButton;
@synthesize assetUrls;
@synthesize managedObjectContext;
@synthesize assetsLibrary;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize longTapActionSheet, addMediaActionSheet;//menuActionSheet,
@synthesize imagePickerController;
@synthesize photoActionSheet;
@synthesize videoActionSheet;
@synthesize photoCaptureController;
@synthesize videoCaptureController;

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
    
    addButton.accessibilityHint = @"Adds a visual reminder.";
    nextButton.accessibilityHint = @"Completes setup.";
    
    cellNibName = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"VHBVisualReminderCell" : @"VHBVisualReminderCellIpad";
    
    tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 80 : 128;
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:nextButton, addButton, nil]];
    
    [self.tableView registerNib:[UINib nibWithNibName:cellNibName bundle:nil] forCellReuseIdentifier:@"visualCell"];
    
    reminders = [[NSMutableArray alloc] init];
    mediaAssets = [[NSMutableArray alloc] init];
    assetUrls = [[NSMutableSet alloc] init];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    cols = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 4 : 6;
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (hasCamera) {
        NSArray *availableTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        NSLog(@"Available types for source as camera = %@", availableTypes);
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            if ([availableTypes containsObject:(NSString*)kUTTypeMovie]) {
                videoCaptureController = [[UIImagePickerController alloc] init];
                videoCaptureController.delegate = self;
                
                [videoCaptureController setAllowsEditing:NO];
                [videoCaptureController setSourceType:UIImagePickerControllerSourceTypeCamera];
                [videoCaptureController setMediaTypes: [NSArray arrayWithObject:(NSString *)kUTTypeMovie]];
                [videoCaptureController setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
                [videoCaptureController setCameraDevice:UIImagePickerControllerCameraDeviceRear];
                
            }
            
            if ([availableTypes containsObject:(NSString*)kUTTypeImage]) {
                photoCaptureController = [[UIImagePickerController alloc] init];
                photoCaptureController.delegate = self;
                [photoCaptureController setAllowsEditing:NO];
                [photoCaptureController setSourceType:UIImagePickerControllerSourceTypeCamera];
                [photoCaptureController setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
                [photoCaptureController setMediaTypes: [NSArray arrayWithObject:(NSString *)kUTTypeImage]];
            }
        }
    }
    
    longTapActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Reminder" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles: nil];
    
    addMediaActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photos", @"Videos", nil];
    
    photoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Photos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select", @"Capture", nil];
    
    if (!hasCamera || !videoCaptureController) {
        videoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Videos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select", @"YouTube", nil];
    } else {
        videoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Videos" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Select", @"Record", @"YouTube", nil];
    }
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    assetsLibrary = appDelegate.assets;
    managedObjectContext = appDelegate.managedObjectContext;

    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    for (VisualReminder *rem in [_fetchedResultsController fetchedObjects]) {
        if ([rem.assetType isEqualToString:@"YOUTUBE"]) {
            [self addMediaWithReminder:rem asset:(ALAsset *)nil];
        } else {
            [assetsLibrary assetForURL:[NSURL URLWithString:rem.assetPath] resultBlock:^(ALAsset *asset) {
                NSDate *createdDate = [asset valueForProperty:ALAssetPropertyDate];
                if ([createdDate isEqualToDate:rem.assetCreated]) {
                    [self addMediaWithReminder:rem asset:asset];
                } else {
                    [managedObjectContext deleteObject:rem];
                    NSLog(@"%@", @"Asset Creation Dates No Longer Match");
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"%@", @"Dead Asset Reference Removed");
                [managedObjectContext deleteObject:rem];
            }];
        }
    }
    
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self updateTableVisibility:0];
    }
    
    [self.tableView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCaptured:)]];
}

- (void)longPressCaptured:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"%@",NSStringFromCGPoint([[gestureRecognizer valueForKey:@"_startPointScreen"] CGPointValue]));
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:point];
        int col = floor(point.x / (self.tableView.frame.size.width / (float) cols));
        selectedPosition = path.row * cols + col;
        NSLog(@"%i", selectedPosition);
        [longTapActionSheet showInView:self.view];
    }
}

- (void)addMediaWithReminder:(VisualReminder *)reminder asset:(ALAsset *)asset
{
    [assetUrls addObject:reminder.assetPath];
    if ([reminder.assetType isEqualToString:@"YOUTUBE"]) {
        [mediaAssets addObject:[NSNull null]];
    } else {
        [mediaAssets addObject:asset];
    }
    
    [reminders addObject:reminder];
    
    int row = (int)floor((float) (mediaAssets.count-1) / (float) cols);
    if (row == rows) {
        rows++;
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self updateTableVisibility:0];
}

- (void)removeMedia:(int)index
{
    VisualReminder *reminder = [reminders objectAtIndex:index];
    [assetUrls removeObject:[reminder assetPath]];
    [reminders removeObjectAtIndex:index];
    [mediaAssets removeObjectAtIndex:index];
    [managedObjectContext deleteObject:reminder];
    [managedObjectContext save:nil];
    int row = (int)floor((float) (mediaAssets.count-1) / (float) cols);
    if (row == rows-2) {
        rows--;
    }
    [self.tableView reloadData];
    [self updateTableVisibility:0];
    [VHBLogUtils logEvent:@"VISUAL_REMINDER_REMOVED"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [VHBLogUtils logEvent:@"SETUP_VISUAL_REMINDER_SESSION" start:sessionStart];
    sessionStart = nil;
    self.fetchedResultsController.delegate = nil;
    [popoverController dismissPopoverAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.fetchedResultsController.delegate = self;
    sessionStart = [NSDate date];
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setTableView:nil];
    [self setAssetUrls:nil];
    [self setAddButton:nil];
    [self setMessageScrollView:nil];
    [self setNextButton:nil];
    [self setReminders:nil];
    [self setPopoverController:nil];
    [self setMediaAssets:nil];
    [self setManagedObjectContext:nil];
    [self setFetchedResultsController:nil];
    [self setAssetsLibrary:nil];
    //[self setMenuActionSheet:nil];
    [self setLongTapActionSheet:nil];
    [self setAddMediaActionSheet:nil];
    [self setImagePickerController:nil];
    [self setPhotoCaptureController:nil];
    [self setVideoCaptureController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rows;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"visualCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellNibName owner:nil options:nil] objectAtIndex:0];
    }
    
    ALAsset *asset;
    UIImageView *img;
    UIView *overlay;
    UILabel *duration;
    UIView *icon;
    VisualReminder *reminder;
    
    for (int col = 1; col <= cols; col++) {
        int index = (indexPath.row * cols + (col - 1));
        
        UIView *colCell = [[[cell.subviews objectAtIndex:0] subviews] objectAtIndex:col-1];
        img = (UIImageView *) [colCell viewWithTag:100];
        overlay = [colCell viewWithTag:101];
        duration = (UILabel *) [overlay viewWithTag:1];
        icon = [overlay viewWithTag:2];
        
        if (reminders.count > index) {
            colCell.hidden = NO;
            reminder = [reminders objectAtIndex:index];
            
            if ([reminder.assetType isEqualToString:@"YOUTUBE"]) {
                NSData *imgData = [NSData dataWithContentsOfFile:reminder.thumbnailPath];
                UIImage *image = [UIImage imageWithData:imgData];
                img.image = image;
                overlay.hidden = NO;
                int totalSeconds = [reminder.duration intValue];
                int seconds = totalSeconds % 60; 
                int minutes = (totalSeconds / 60) % 60;
                duration.text = [[NSString alloc] initWithFormat:@"%01i:%02i", minutes, seconds];
                colCell.accessibilityLabel = [NSString stringWithFormat:@"%@, %i minutes, %i seconds", reminder.title, minutes, seconds];
            } else {
                asset = (ALAsset *)[mediaAssets objectAtIndex:index];
                img.image = [UIImage imageWithCGImage:asset.thumbnail];
                
                if ([reminder.assetType isEqualToString:@"IMAGE"]) {
                    overlay.hidden = YES;
                    colCell.accessibilityLabel = @"Photo";
                } else {
                    overlay.hidden = NO;
                    int totalSeconds = [[asset valueForProperty:ALAssetPropertyDuration] intValue];
                    int seconds = totalSeconds % 60; 
                    int minutes = (totalSeconds / 60) % 60;
                    duration.text = [[NSString alloc] initWithFormat:@"%01i:%02i", minutes, seconds];
                    colCell.accessibilityLabel = [NSString stringWithFormat:@"Video, %i minutes, %i seconds", minutes, seconds];
                }
            }
            
        } else {
            colCell.hidden = YES;
            img.image = nil;
        }
    }
    // Configure the cell...
    
    return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapActionSheet) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Remove Clicked");
                [self removeMedia:selectedPosition];
                break;
        }
    } else if (actionSheet == addMediaActionSheet) {
        switch (buttonIndex) {
                [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
            case 0:
                if (!hasCamera || !photoCaptureController) {
                    [popoverController dismissPopoverAnimated:YES];
                    [self selectPhotoClicked];
                    break;
                }
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [photoActionSheet showInView:self.view];
                } else {
                    [photoActionSheet showFromBarButtonItem:addButton animated:YES];
                }
                
                break;
            case 1:
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [videoActionSheet showInView:self.view];
                } else {
                    [videoActionSheet showFromBarButtonItem:addButton animated:YES];
                }
            
                break;
        }
    } else if (actionSheet == photoActionSheet) {
        [popoverController dismissPopoverAnimated:YES];
        switch (buttonIndex) {
            case 0:
                [self selectPhotoClicked];
                break;
            case 1:
                [self capturePhotoClicked];
                break;
        }
    } else if (actionSheet == videoActionSheet) {
        [popoverController dismissPopoverAnimated:YES];
        switch (buttonIndex) {
            case 0:
                [self selectVideoClicked];
                break;
            case 1:
                if (!hasCamera || !videoCaptureController) {
                    [self performSegueWithIdentifier:@"pickYouTube" sender:nil];
                } else {
                    [self captureVideoClicked];
                }
                break;
            case 2:
                // on ipad clicking outside the bounds of the popover sends buttonIndex == 2 even if no such button exists
                if (hasCamera && videoCaptureController) {
                    [self performSegueWithIdentifier:@"pickYouTube" sender:nil];
                }
                break;
        }
    }
}

- (void)capturePhotoClicked
{
    capturing = YES;
    [self presentModalViewController:photoCaptureController animated:YES];
}

- (void)captureVideoClicked
{
    capturing = YES;
    [self presentModalViewController:videoCaptureController animated:YES];
}


- (void)selectPhotoClicked
{
    [imagePickerController setMediaTypes: [NSArray arrayWithObject:(NSString *)kUTTypeImage]];
    [imagePickerController setAllowsEditing:NO];
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentModalViewController:imagePickerController animated:YES];
    } else {
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        popoverController.delegate = self;
        [popoverController presentPopoverFromBarButtonItem:addButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)selectVideoClicked
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self performSegueWithIdentifier:@"pickVideo" sender:self];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:@"videoPicker"];
        VHBYouTubeViewController *videoPicker = [[nav viewControllers] objectAtIndex:0];
        videoPicker.delegate = self;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:nav];
        popoverController.delegate = self;
        [popoverController presentPopoverFromBarButtonItem:addButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pickVideo"]) {
        UINavigationController *destNav = segue.destinationViewController;
        
        ((VHBVideoPickerViewController *) [destNav.viewControllers objectAtIndex:0]).delegate = self;
    } else if ([segue.identifier isEqualToString:@"pickYouTube"]) {
        UINavigationController *destNav = segue.destinationViewController;
        
        ((VHBYouTubeViewController *) [destNav.viewControllers objectAtIndex:0]).delegate = self;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (capturing) {
        capturing = NO;
        NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
        UIImage *originalImage, *editedImage, *imageToSave;
        
        // Handle a still image capture
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
            originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
            
            if (editedImage) {
                imageToSave = editedImage;
            } else {
                imageToSave = originalImage;
            }
            
            // Save the new image (original or edited) to the Camera Roll
            [assetsLibrary writeImageToSavedPhotosAlbum:imageToSave.CGImage orientation:imageToSave.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
                reminder.assetPath = [assetURL absoluteString];
                reminder.assetType = @"IMAGE";
                
                [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    reminder.assetCreated = [asset valueForProperty:ALAssetPropertyDate];
                    reminder.dateCreated = [NSDate date];
                    [managedObjectContext save:nil];
                    [self addMediaWithReminder:reminder asset:asset];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                } failureBlock:^(NSError *myerror) {
                    NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
                }];
            }];
            [VHBLogUtils logEvent:@"PHOTO_CAPTURED"];
            [picker dismissModalViewControllerAnimated:YES];
        }
        
        // Handle a movie capture
        if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
            
            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:moviePath] completionBlock:^(NSURL *assetURL, NSError *error) {
                VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
                reminder.assetPath = [assetURL absoluteString];
                
                [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    reminder.assetCreated = [asset valueForProperty:ALAssetPropertyDate];
                    reminder.dateCreated = [NSDate date];
                    reminder.assetType = [asset valueForProperty:ALAssetPropertyType];
                    [managedObjectContext save:nil];
                    [self addMediaWithReminder:reminder asset:asset];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                } failureBlock:^(NSError *myerror) {
                    NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
                }];
            }];
            [VHBLogUtils logEvent:@"VIDEO_CAPTURED"];
            [picker dismissModalViewControllerAnimated:YES];
        }
    } else {
        
        NSURL *referenceURL = [info objectForKey: UIImagePickerControllerReferenceURL];
        if ([assetUrls containsObject:[referenceURL absoluteString]]) {
            [picker dismissModalViewControllerAnimated:YES];
            return;
        }
        
        VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
        reminder.assetPath = [referenceURL absoluteString];
        reminder.assetType = @"IMAGE";
        
        [assetsLibrary assetForURL:referenceURL resultBlock:^(ALAsset *asset) {
            reminder.assetCreated = [asset valueForProperty:ALAssetPropertyDate];
            reminder.dateCreated = [NSDate date];
            [managedObjectContext save:nil];
            [self addMediaWithReminder:reminder asset:asset];
        } failureBlock:^(NSError *myerror) {
            NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
        }];
        [VHBLogUtils logEvent:@"PHOTO_ADDED"];
        [picker dismissModalViewControllerAnimated:YES];
    }
}

- (void)didFinishPickingVideo:(ALAsset *)asset
{
    //NSString *urlString = ;
    NSDate *date = [asset valueForProperty:ALAssetPropertyDate];
    NSDictionary *urls = [asset valueForProperty:ALAssetPropertyURLs];
    NSString *type = [asset valueForProperty:ALAssetPropertyType];
    
    if (urls && urls.count > 0) {
        NSURL *url = [[urls allValues] objectAtIndex:0];
        if ([assetUrls containsObject:[url absoluteString]]) {
            return;
        }
        
        VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
        reminder.assetPath = [url absoluteString];
        reminder.assetType = type;
        reminder.assetCreated = date;
        reminder.dateCreated = [NSDate date];
        [managedObjectContext save:nil];
        [self addMediaWithReminder:reminder asset:asset];
        [VHBLogUtils logEvent:@"VIDEO_ADDED"];
    }
}

- (void)updateTableVisibility:(float)delay {
    [UIView animateWithDuration:.5 delay:delay options:0 animations:^{
        if (reminders.count > 0) {
            tableView.alpha = 1;
            messageScrollView.alpha = 0;
        } else {
            tableView.alpha = 0;
            messageScrollView.alpha = 1;
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)youTubeVideoSelected:(NSString *)title url:(NSString *)href thumbnail:(UIImage *)image duration:(NSTimeInterval)seconds
{
    VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@%@.jpg", @"YT-", (__bridge NSString *)uuidString];
    CFRelease(uuidString);
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = (NSString *)[dirPaths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@", docsDir, uniqueFileName];
    
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(image)];
	[data writeToFile:path atomically:YES];
    
    reminder.thumbnailPath = path;
    reminder.assetType = @"YOUTUBE";
    reminder.dateCreated = [NSDate date];
    reminder.assetPath = href;
    reminder.duration = [NSNumber numberWithInt:seconds];
    reminder.title = title;
    
    [managedObjectContext save:nil];
    [self addMediaWithReminder:reminder asset:nil];
    [VHBLogUtils logEvent:@"YOUTUBE_VIDEO_ADDED"];
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
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    //NSSortDescriptor *orderSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"difficulty = %i", difficulty];
    //[fetchRequest setPredicate:predicate];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
    return _fetchedResultsController;
}

- (IBAction)addClicked:(id)sender 
{
    [popoverController dismissPopoverAnimated:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [addMediaActionSheet showInView:self.view];
    } else {
        [addMediaActionSheet showFromBarButtonItem:addButton animated:YES];
    }
}

- (IBAction)doneClicked:(id)sender {
    [self performSegueWithIdentifier:@"home" sender:self];
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"home"]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"setup_complete"];
        [defaults synchronize];
    }
    [super performSegueWithIdentifier:identifier sender:sender];
}

@end
