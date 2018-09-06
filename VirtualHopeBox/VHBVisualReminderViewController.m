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

#import "VHBVisualReminderViewController.h"
#import "GradientLayer.h"

@interface VHBVisualReminderViewController () {
    BOOL loading, hasCamera, capturing, saveSuccess;
    int selectedPosition;
    MPMoviePlayerViewController *moviePlayerController;
}

@end

@implementation VHBVisualReminderViewController

@synthesize galleryScrollView;
@synthesize playButton;
@synthesize helpView;
@synthesize largeImageView;
@synthesize managedObjectContext;
@synthesize assetsLibrary;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize longTapActionSheet, addMediaActionSheet;//menuActionSheet,
@synthesize selectedView;
@synthesize imagePickerController;
@synthesize videoPickerController;
@synthesize assetViewDict;
@synthesize leftSwipeRecognizer;
@synthesize rightSwipeRecognizer;
@synthesize popoverController;
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
    
    loading = YES;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    assetViewDict = [[NSMutableDictionary alloc] init];
    
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
    
    if (_fetchedResultsController.fetchedObjects.count == 0) {
        self.helpView.alpha = 1;
    }
    
    for (VisualReminder *rem in [_fetchedResultsController fetchedObjects]) {
        if ([rem.assetType isEqualToString:@"YOUTUBE"]) {
            [self loadReminder:rem];
        } else {
            [assetsLibrary assetForURL:[NSURL URLWithString:dRaw(encodeKey, rem.assetPath)] resultBlock:^(ALAsset *asset) {
                NSDate *createdDate = [asset valueForProperty:ALAssetPropertyDate];
                if ([createdDate isEqualToDate:rem.assetCreated]) {
                    [self loadReminder:rem];
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
    
    [largeImageView setUserInteractionEnabled:YES];
    [largeImageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(largeImageLongPressCaptured:)]];
    
    leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeDetected:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeDetected:)];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [largeImageView addGestureRecognizer:leftSwipeRecognizer];
    [largeImageView addGestureRecognizer:rightSwipeRecognizer];
    
    
    loading = NO;
    
    if (!selectedView) {
        for (int i = 0; i < [[galleryScrollView subviews] count]; i++) {
            UIView *view = [[galleryScrollView subviews] objectAtIndex:i];
            if ([view isMemberOfClass:[VHBReminderView class]]) {
                [self selectThumbnail:(VHBReminderView *)view];
                break;
            }
        }
    }
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]];
    }
}

- (BOOL)accessibilityScroll:(UIAccessibilityScrollDirection)direction
{
    if (direction == UIAccessibilityScrollDirectionLeft) {
        [self leftSwipeDetected:nil];
        return YES;
    } else if (direction == UIAccessibilityScrollDirectionRight) {
        [self rightSwipeDetected:nil];
        return YES;
    }
    
    return NO;
}

- (void)updateHelpVisibility:(BOOL)animated
{
    float duration = 0;
    if (animated) {
        duration = .3;
    }
    if (assetViewDict.count == 0 && self.helpView.alpha < 1) {
        [UIView animateWithDuration:duration animations:^{
            self.helpView.alpha = 1;
        }];
    } else if (assetViewDict.count > 0 && self.helpView.alpha > 0) {
        [UIView animateWithDuration:duration animations:^{
            self.helpView.alpha = 0;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.fetchedResultsController.delegate = self;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [popoverController dismissPopoverAnimated:YES];
    [addMediaActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [videoActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [longTapActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [photoActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)leftSwipeDetected:(UISwipeGestureRecognizer *)recognizer
{
    int lastPosition = 0;
    for (int i = 0; i < [[galleryScrollView subviews] count]; i++) {
        UIView *view = [[galleryScrollView subviews] objectAtIndex:i];
        if ([view isMemberOfClass:[VHBReminderView class]]) {
            lastPosition = i;
        }
    }
    
    if (selectedPosition == lastPosition || [assetViewDict count] <= 1) {
        return;
    }
    
    VHBReminderView *nextView;
    for (int i = selectedPosition+1; i <= lastPosition; i++) {
        UIView *view = [[galleryScrollView subviews] objectAtIndex:i];
        if ([view isMemberOfClass:[VHBReminderView class]]) {
            nextView = (VHBReminderView *) view;
            break;
        }
    }
    
    if (nextView) {
        [self selectThumbnail:nextView];
    }
}

- (void)rightSwipeDetected:(UISwipeGestureRecognizer *)recognizer
{
    if (selectedPosition == 0 || [assetViewDict count] <= 1) {
        return;
    }
    
    VHBReminderView *nextView;
    for (int i = selectedPosition-1; i >= 0; i--) {
        UIView *view = [[galleryScrollView subviews] objectAtIndex:i];
        if ([view isMemberOfClass:[VHBReminderView class]]) {
            nextView = (VHBReminderView *) view;
            break;
        }
    }
    
    if (nextView) {
        [self selectThumbnail:nextView];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    moviePlayerController = nil;
    [self setGalleryScrollView:nil];
    [self setPlayButton:nil];
    [self setLargeImageView:nil];
    [self setManagedObjectContext:nil];
    self.fetchedResultsController.delegate = nil;
    [self setFetchedResultsController:nil];
    [self setAssetsLibrary:nil];
    //[self setMenuActionSheet:nil];
    [self setLongTapActionSheet:nil];
    [self setAddMediaActionSheet:nil];
    [self setSelectedView:nil];
    [self setImagePickerController:nil];
    [self setPopoverController:nil];
    [self setAssetViewDict:nil];
    [self setLeftSwipeRecognizer:nil];
    [self setRightSwipeRecognizer:nil];
    [self setPhotoCaptureController:nil];
    [self setVideoCaptureController:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)menuClicked:(id)sender {
    [longTapActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    [photoActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    [videoActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    [longTapActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
    [popoverController dismissPopoverAnimated:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [addMediaActionSheet showFromBarButtonItem:[self getAddButton] animated:YES];
    } else {
        if (self.tabBarController) {
            [addMediaActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [addMediaActionSheet showInView:self.view];
        }
    }
}

- (IBAction)playClicked:(id)sender {
    if ([selectedView.reminder.assetType isEqualToString:ALAssetTypeVideo]) {
        [self playVideo];
    } else if ([selectedView.reminder.assetType isEqualToString:@"YOUTUBE"]) {
        [self playYouTubeVideo];
    }
}

- (void)playYouTubeVideo 
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dRaw(encodeKey, selectedView.reminder.assetPath) stringByReplacingOccurrencesOfString:@"&feature=youtube_gdata_player" withString:@""]]];
}

- (void)playVideo 
{
    moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:dRaw(encodeKey, selectedView.reminder.assetPath)]];
    [moviePlayerController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [moviePlayerController setModalPresentationStyle:UIModalPresentationFullScreen];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController.moviePlayer];
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

- (void)moviePlaybackComplete:(NSNotification *)notification 
{
    [self dismissMoviePlayerViewControllerAnimated];
    [moviePlayerController.moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayerController];
    NSLog(@"Playback Ended");
}

- (UIBarButtonItem *)getAddButton
{
    return [self.tabBarController.navigationItem.rightBarButtonItems objectAtIndex:1];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self removeThumbnail:selectedView.reminder];
                break;
        }
    } else if (actionSheet == addMediaActionSheet) {
        [popoverController dismissPopoverAnimated:YES];
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
        switch (buttonIndex) {
                
            case 0:
                if (!hasCamera || !photoCaptureController) {
                    [self selectPhotoClicked];
                    break;
                }
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [photoActionSheet showFromBarButtonItem:[self getAddButton] animated:YES];
                } else {
                    if (self.tabBarController) {
                        [photoActionSheet showFromTabBar:self.tabBarController.tabBar];
                    } else {
                        [photoActionSheet showInView:self.view];
                    }
                }
                
                
                break;
            case 1:
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [videoActionSheet showFromBarButtonItem:[self getAddButton] animated:YES];
                } else {
                    if (self.tabBarController) {
                        [videoActionSheet showFromTabBar:self.tabBarController.tabBar];
                    } else {
                        [videoActionSheet showInView:self.view];
                    }
                }
                break;
        }
    } else if (actionSheet == photoActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self selectPhotoClicked];
                break;
            case 1:
                [self capturePhotoClicked];
                break;
        }
    } else if (actionSheet == videoActionSheet) {
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
                [self performSegueWithIdentifier:@"pickYouTube" sender:nil];
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

}

- (void)capturePhotoClicked
{
    capturing = YES;
    [self presentViewController:photoCaptureController animated:YES completion:nil];
}

- (void)captureVideoClicked
{
    capturing = YES;
    [self presentViewController:videoCaptureController animated:YES completion:nil];
}


- (void)selectPhotoClicked
{
    imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else {
        self.navigationController.modalPresentationStyle = UIModalPresentationPopover;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        popoverController.delegate = self;

        [popoverController presentPopoverFromBarButtonItem:[self getAddButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)selectVideoClicked
{
    videoPickerController = [QBImagePickerController new];
    videoPickerController.delegate = self;
    videoPickerController.mediaType = QBImagePickerMediaTypeVideo;
    videoPickerController.allowsMultipleSelection = YES;
    videoPickerController.showsNumberOfSelectedAssets = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:videoPickerController animated:YES completion:nil];
    } else {
        popoverController = [[UIPopoverController alloc] initWithContentViewController:videoPickerController];
        popoverController.delegate = self;
        
        [popoverController presentPopoverFromBarButtonItem:[self getAddButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        [self performSegueWithIdentifier:@"pickVideo" sender:self];
//    } else {
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad" bundle:nil];
//        UINavigationController *nav = [storyboard instantiateViewControllerWithIdentifier:@"videoPicker"];
//        VHBYouTubeViewController *videoPicker = [[nav viewControllers] objectAtIndex:0];
//        videoPicker.delegate = self;
//        popoverController = [[UIPopoverController alloc] initWithContentViewController:nav];
//        popoverController.delegate = self;
//        [popoverController presentPopoverFromBarButtonItem:[self getAddButton] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pickYouTube"]) {
        UINavigationController *destNav = segue.destinationViewController;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            destNav.navigationBar.tintColor = [UIColor darkGrayColor];
        }
        
        ((VHBYouTubeViewController *) [destNav.viewControllers objectAtIndex:0]).delegate = self;
    }
}

-(void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [popoverController dismissPopoverAnimated:YES];
    }
}

-(void) qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    for(PHAsset* asset in assets) {
        NSLog(@"%@", asset);
        if(asset.mediaType == PHAssetMediaTypeVideo) {
            NSString* url = [NSString stringWithFormat:@"assets-library://asset/asset.MOV?id=%@&ext=MOV", [asset.localIdentifier substringToIndex:36]];
            
            if ([assetViewDict objectForKey:eRaw(encodeKey, url)]) {
                continue;
            }
            
            [assetsLibrary assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *alasset) {
                VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
                reminder.assetPath = eRaw(encodeKey, url);
                reminder.dateCreated = [NSDate date];
                reminder.assetCreated = [alasset valueForProperty:ALAssetPropertyDate];
                reminder.assetType = [alasset valueForProperty:ALAssetPropertyType];
                NSLog(@"Value is called %@", reminder.assetType);
                
                [VHBLogUtils logEventType:LETRemindAdd withValue:@"Video"];
             
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Failed to get Movie - %@",[myerror localizedDescription]);
            }];
        }
        else if(asset.mediaType == PHAssetMediaTypeImage) {
            NSString* url = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&ext=JPG", [asset.localIdentifier substringToIndex:36]];
                
            if ([assetViewDict objectForKey:eRaw(encodeKey, url)]) {
                continue;
            }
            
            [assetsLibrary assetForURL:[NSURL URLWithString:url] resultBlock:^(ALAsset *alasset) {
                VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
                reminder.assetPath = eRaw(encodeKey, url);
                reminder.assetType = @"IMAGE";
                reminder.dateCreated = [NSDate date];
                reminder.assetCreated = [alasset valueForProperty:ALAssetPropertyDate];
                
                [VHBLogUtils logEventType:LETRemindAdd withValue:@"Photo"];
            } failureBlock:^(NSError *myerror) {
                NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
            }];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [popoverController dismissPopoverAnimated:YES];
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
            
            dispatch_group_t group = dispatch_group_create();
            
            dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                NSLog(@"****Starting First Block");

                [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
                    [PHAssetCreationRequest creationRequestForAssetFromImage:imageToSave];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {

                    dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                        NSLog(@"Starting First Block");

                        if (success){
                            saveSuccess = YES;
                            NSLog(@"****Finished!");
                            NSLog(@"****SaveSuccess = %d", saveSuccess);
                        } else {
                            NSLog(@"****error: %@", error);
                            saveSuccess = NO;
                            NSLog(@"****SaveSuccess = %d", saveSuccess);
                        }
                    });
                }];
            });
            
            
            dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                NSLog(@"****Starting Last Block");
                [NSThread sleepForTimeInterval:1.0];
                NSLog(@"****Running After Sleep");
                if (saveSuccess){
                    
                    PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
                    fetchOptions.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
                    fetchOptions.fetchLimit = 1;
                    
                    PHAsset *result = [[PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions]lastObject];
                    //NSString *imageIdentifier = result.localIdentifier;
                    
                    NSString* url = [NSString stringWithFormat:@"assets-library://asset/asset.JPG?id=%@&ext=JPG", [result.localIdentifier substringToIndex:36]];
                    //PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
                    //[imageManager requestImageDataForAsset:result options:[[PHImageRequestOptions alloc] init] resultHandler:]
                    NSLog(@"asset is : %@", url);
                    
                    VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
                    
                    reminder.assetPath = eRaw(encodeKey, url);
                    reminder.assetType = @"IMAGE";
                    reminder.assetCreated = [result creationDate];
                    reminder.dateCreated = [NSDate date];
                    
                    [VHBLogUtils logEventType:LETRemindCapture withValue:@"Photo"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
                        [appDelegate saveContext];
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                    });
                }
            });
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
        
        // Handle a movie capture
        if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
            NSURL *url = [NSURL URLWithString:[moviePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            dispatch_group_t group = dispatch_group_create();
            
            dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                NSLog(@"****Starting First Block");
                
                // Save to the album
                __block PHObjectPlaceholder *placeholder;
                
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                    placeholder = [createAssetRequest placeholderForCreatedAsset];
                    
                } completionHandler:^(BOOL success, NSError *error) {
                    if (success)
                    {
                        NSLog(@"didFinishRecordingToOutputFileAtURL - success for ios9");
                        
                    }
                    else
                    {
                        NSLog(@"%@", error);
                    }
                }];
            });
            
            
            dispatch_group_notify(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
                NSLog(@"****Starting Last Block");
                [NSThread sleepForTimeInterval:2.0];
                NSLog(@"****Running After Sleep");
                
                PHFetchOptions* fetchOptions = [[PHFetchOptions alloc] init];
                fetchOptions.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]];
                fetchOptions.fetchLimit = 1;
                
                PHAsset *result = [[PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions]lastObject];
                
                NSString* url = [NSString stringWithFormat:@"assets-library://asset/asset.MOV?id=%@&ext=MOV", [result.localIdentifier substringToIndex:36]];
                
                VisualReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
                
                reminder.assetPath = eRaw(encodeKey, url);
                reminder.assetCreated = [result creationDate];
                reminder.dateCreated = [NSDate date];
                //Todo
                reminder.assetType = @"ALAssetTypeVideo";
                
                [VHBLogUtils logEventType:LETRemindCapture withValue:@"Video"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate saveContext];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                });
            });
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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

    reminder.thumbnailPath = eRaw(encodeKey, path);
    reminder.assetType = @"YOUTUBE";
    reminder.dateCreated = [NSDate date];
    reminder.assetPath = eRaw(encodeKey, href);
    reminder.duration = [NSNumber numberWithInt:seconds];
    reminder.title = eRaw(encodeKey, title);
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    
//    [managedObjectContext save:nil];
//    [self loadReminder:reminder];
    
    [VHBLogUtils logEventType:LETRemindAdd withValue:@"YouTube"];
}

- (void)loadFullImage:(VisualReminder *)reminder
{
    if ([reminder.assetType isEqualToString:@"YOUTUBE"]) {
        [self imageLoaded:[UIImage imageWithContentsOfFile:dRaw(encodeKey, reminder.thumbnailPath)]];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        playButton.hidden = NO;
        playButton.userInteractionEnabled = YES;
    } else {
        [assetsLibrary assetForURL:[NSURL URLWithString:dRaw(encodeKey, reminder.assetPath)] resultBlock:^(ALAsset *asset) {
            [self loadFullImageWithAsset:asset];
        } failureBlock:^(NSError *myerror) {
            NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
        }];
    }
}

- (void)loadFullImageWithAsset:(ALAsset *)asset
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        CGImageRef ref = [rep fullResolutionImage];
        
        UIImageOrientation orientation = UIImageOrientationUp;
        NSNumber* orientationValue = [asset valueForProperty:@"ALAssetPropertyOrientation"];
        if (orientationValue != nil) {
            orientation = [orientationValue intValue];
        }
        
        if (ref) {
            UIImage *img = [UIImage imageWithCGImage:ref scale:1 orientation:orientation];
            img = [self resizeImage:img toSize:largeImageView.frame.size];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self imageLoaded:img];
                [self dismissViewControllerAnimated:YES completion:nil];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                playButton.hidden = [ALAssetTypePhoto isEqualToString:[asset valueForProperty:ALAssetPropertyType]];
                playButton.userInteractionEnabled = !playButton.hidden;
            });
        }
    });

}

-(void)imageLoaded:(UIImage *)img
{
    [largeImageView setImage:img];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
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

- (void)updateThumbnails
{
    NSLog(@"%@", @"Updating Thumbnails");
}

- (IBAction)addClicked:(id)sender {
    [self menuClicked:0];
}

- (void)updateThumbnail:(NSIndexPath *)indexPath
{
    NSLog(@"%@ #%@", @"Updating Thumbnail", indexPath);
}

- (void)loadReminder:(VisualReminder *)reminder
{
    if ([assetViewDict objectForKey:dRaw(encodeKey, reminder.assetPath)]) {
        return;
    }
    
    if ([reminder.assetType isEqualToString:@"YOUTUBE"]) {
        NSData *img = [NSData dataWithContentsOfFile:dRaw(encodeKey, reminder.thumbnailPath)];
        UIImage *photo = [UIImage imageWithData:img];
        [self addThumbnail:reminder :photo :reminder.duration];
    } else {
        [assetsLibrary assetForURL:[NSURL URLWithString:dRaw(encodeKey, reminder.assetPath)] resultBlock:^(ALAsset *asset) {
            if (asset) {
                NSNumber *duration;
                if ([reminder.assetType isEqualToString:ALAssetTypeVideo]) {
                    duration = [NSNumber numberWithInt:[[asset valueForProperty:ALAssetPropertyDuration] intValue]];
                }
                
                [self addThumbnail :reminder :[UIImage imageWithCGImage:asset.thumbnail] :duration];
            }
        } failureBlock:^(NSError *myerror) {
            NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
        }];
    }
    
    NSLog(@"%@", @"Add Thumbnail");
}

- (void)addThumbnail:(VisualReminder *)reminder :(UIImage *)thumbnail :(NSNumber *)duration
{
    int dimen = galleryScrollView.bounds.size.height;
    
    VHBReminderView *thumbView = [[VHBReminderView alloc] initWithFrame:CGRectMake((dimen + 1) * assetViewDict.count, 0, dimen, dimen)];
    thumbView.thumbnailView.image = thumbnail;
    thumbView.userInteractionEnabled = YES;
    thumbView.reminder = reminder;
    thumbView.tag = arc4random() + 100 % INT_MAX;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbTapCaptured:)];
    [thumbView addGestureRecognizer:singleTap];  
    
    thumbView.isAccessibilityElement = YES;
    thumbView.accessibilityTraits = UIAccessibilityTraitButton;
    thumbView.accessibilityHint = @"Selects this reminder.";
    if (duration) {
        int totalSeconds = [duration intValue];
        int seconds = totalSeconds % 60; 
        int minutes = (totalSeconds / 60) % 60;
        thumbView.durationView.text = [[NSString alloc] initWithFormat:@"%01i:%02i", minutes, seconds];
        
        if (reminder.title) {
            thumbView.accessibilityLabel = [NSString stringWithFormat:@"%@, %i minutes, %i seconds", dRaw(encodeKey, reminder.title), minutes, seconds];
        } else {
            thumbView.accessibilityLabel = [NSString stringWithFormat:@"Video, %i minutes, %i seconds", minutes, seconds];
        }
    } else {
        thumbView.accessibilityLabel = @"Photo";
    }
    
    [assetViewDict setObject:thumbView forKey:reminder.assetPath];
    [galleryScrollView addSubview:thumbView];
    
    [self layoutGallery];
    
    [thumbView setNeedsDisplay];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self updateHelpVisibility:YES];
    } else {
        [self updateHelpVisibility:NO];
    }
    
    if (!selectedView && !loading) {
        [self selectThumbnail:thumbView];
    }
    [galleryScrollView scrollRectToVisible:thumbView.frame animated:YES];
}

- (void)layoutGallery
{
    int dimen = galleryScrollView.bounds.size.height;
    float contentWidth = dimen * assetViewDict.count + ((assetViewDict.count + 1) * 5);
    float center = galleryScrollView.center.x;
    float left = 0;
    if (contentWidth < galleryScrollView.bounds.size.width) {
        left = center - (contentWidth / 2.0);
    }
    
    int index = 0;
    for (UIView *view in galleryScrollView.subviews) {
        if ([view isMemberOfClass:[VHBReminderView class]]) {
            view.frame = CGRectMake(left + (index * dimen) + ((index + 1) * 5), 0, dimen, dimen);
            index++;
        }
    }
    
    galleryScrollView.contentSize = CGSizeMake(contentWidth, dimen);
    
    
}

- (void)removeThumbnail:(VisualReminder *)reminder
{
    VHBReminderView *view = [assetViewDict objectForKey:reminder.assetPath];
    if (view) {
        VHBReminderView *nextView;
        if (selectedView == view) {
            if (assetViewDict.count > 1) {
                for (VHBReminderView *tempView in [assetViewDict allValues]) {
                    if (tempView != view) {
                        nextView = tempView;
                        break;
                    }
                }
            } else {
                playButton.hidden = YES;
                playButton.userInteractionEnabled = NO;
                largeImageView.image = nil;
            }
        }
        [assetViewDict removeObjectForKey:reminder.assetPath];
        
        [view removeFromSuperview];
        [self layoutGallery];
        if (nextView) {
            [self selectThumbnail:nextView];
        } else {
            selectedView = nil;
        }
        
        if ([reminder.assetType isEqualToString:@"IMAGE"]) {
            [VHBLogUtils logEventType:LETRemindRemove withValue:@"Photo"];
        } else if ([reminder.assetType isEqualToString:@"YOUTUBE"]) {
            [VHBLogUtils logEventType:LETRemindRemove withValue:@"YouTube"];
        } else {
            [VHBLogUtils logEventType:LETRemindAdd withValue:@"Video"];
        }
        [managedObjectContext deleteObject:view.reminder];
        
        [self updateHelpVisibility:YES];
    }
    
    NSLog(@"%@", @"Remove Thumbnail");
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self updateThumbnails];
}



- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    VisualReminder *rem = [controller objectAtIndexPath:newIndexPath];
    
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self loadReminder:rem];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self removeThumbnail:rem];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self updateThumbnail:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            
            break;
    }
}

- (void)largeImageLongPressCaptured:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.tabBarController) {
            [longTapActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [longTapActionSheet showInView:self.view];
        }
    }
}

- (void)thumbTapCaptured:(UITapGestureRecognizer *)gesture
{ 
    VHBReminderView *view = (VHBReminderView *) gesture.view;
    [self selectThumbnail:view];
}

- (void)selectThumbnail:(VHBReminderView *)reminderView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.yOffset = -32;
    
    largeImageView.image = nil;
    playButton.hidden = YES;
    playButton.userInteractionEnabled = NO;
    
    [self loadFullImage:reminderView.reminder];
    
    float width = galleryScrollView.contentSize.width;
    float scrollCenter = galleryScrollView.bounds.size.width / 2.0;
    float point = (width - scrollCenter) - (width - reminderView.center.x);
    point = MIN(point, (width - galleryScrollView.bounds.size.width));
    point = MAX(point, 0);
    selectedView = reminderView;
    selectedPosition = (int)[[galleryScrollView subviews] indexOfObject:selectedView];
    [galleryScrollView setContentOffset:CGPointMake(point, 0) animated:YES];
    NSLog(@"%@", @"Selected Thumbnail");
}


- (UIImage *)resizeImage:(UIImage *)img toSize:(CGSize)newSize {
    UIImage *outputImage = nil;
    CGFloat scaleFactor, width;
    
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

    UIGraphicsBeginImageContext(newSize);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return outputImage;
}


@end
