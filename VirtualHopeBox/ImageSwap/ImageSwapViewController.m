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

#import "ImageSwapViewController.h"
#import "GradientLayer.h"
#import "DefaultsWrapper.h"

@interface ImageSwapViewController () {
    ALAssetsLibrary *assetsLibrary;
    UIActionSheet *menuSheet, *difficultySheet;
    bool dismissing;
}

@end

@implementation ImageSwapViewController
@synthesize menuButton;
@synthesize contactsButton;
@synthesize puzzleView;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    menuSheet = [[UIActionSheet alloc] initWithTitle:@"Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"New Puzzle" otherButtonTitles:@"Show Hint", @"Change Difficulty", nil];
    difficultySheet = [[UIActionSheet alloc] initWithTitle:@"Change Difficulty" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Easy", @"Medium", @"Hard", nil];
    
    puzzleView.delegate = self;
    
    
    [contactsButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:contactsButton, menuButton, nil];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    assetsLibrary = appDelegate.assets;
    managedObjectContext = appDelegate.managedObjectContext;

    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [menuSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [difficultySheet dismissWithClickedButtonIndex:-1 animated:YES];
    
    [VHBLogUtils endTimedEvent:LETPhotoPuzzleClose];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!puzzleView.image) {
        [self loadReminder];
    }
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [VHBLogUtils logEventType:LETPhotoPuzzleOpen];
    [VHBLogUtils startTimedEvent:LETPhotoPuzzleClose];
}

- (void)puzzleComplete:(int)turns
{
    [VHBLogUtils logEventType:LETPhotoPuzzleCompleted];
    [self loadReminder];
}

- (void)scramblingComplete
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)loadReminder
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    int count = (int)self.fetchedResultsController.fetchedObjects.count;
    if (count > 0) {
        VisualReminder *reminder = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:arc4random() % count inSection:0]];
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
                    UIImage *img = [UIImage imageWithCGImage:ref scale:1 orientation:orientation];
                    puzzleView.image = img;
                    [puzzleView initPuzzle];
                    [UIView animateWithDuration:.5 animations:^{
                        puzzleView.alpha = 1.0;
                    }];
                }
            }
        } failureBlock:^(NSError *myerror) {
            NSLog(@"Failed to get Image - %@",[myerror localizedDescription]);
        }];
    } else {
        [self performSegueWithIdentifier:@"empty" sender:self];
//        puzzleView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"splash" ofType:@"png"]];
//        [puzzleView initPuzzle];
//        [UIView animateWithDuration:.5 animations:^{
//            puzzleView.alpha = 1.0;
//        }];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidUnload
{
    [self setPuzzleView:nil];
    [self setMenuButton:nil];
    [self setContactsButton:nil];
    [self setFetchedResultsController:nil];
    [self setManagedObjectContext:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"VisualReminder" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetType == %@", @"IMAGE"];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];

    fetchedResultsController = aFetchedResultsController;
    
    return fetchedResultsController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return YES;
    return NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    int index = (int)buttonIndex;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && buttonIndex > 0) {
    }
    
    NSLog(@"Clicked");
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (actionSheet == menuSheet) {
        switch (index) {
            case 0:
            {
                [UIView animateWithDuration:.5 animations:^{
                    puzzleView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self loadReminder];
                }];
                break;
            }
            case 1:
                [puzzleView showHint];
                break;
            case 2:
                [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    [difficultySheet showInView:self.view];
                } else {
                    [difficultySheet showFromBarButtonItem:menuButton animated:YES];
                }
                break;
        }
    } else if (actionSheet == difficultySheet && buttonIndex >= 0 && buttonIndex <= 2) {
        //[defaults setObject:[NSNumber numberWithInt:index] forKey:@"image_swap_difficulty"];
        //[defaults synchronize];
        encryptIntForKey(@"image_swap_difficulty", index);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [UIView animateWithDuration:.5 animations:^{
            puzzleView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [puzzleView initPuzzle:index];
            [UIView animateWithDuration:.5 animations:^{
                puzzleView.alpha = 1.0;
            }];
        }];
    }
}

                 
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (dismissing) {
        return;
    }
    
    NSLog(@"Dismissed");
    if (buttonIndex == 2 && actionSheet == menuSheet) {
        
    }
    
    dismissing = NO;
}

- (IBAction)menuClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [menuSheet showInView:self.view];
    } else {
        [menuSheet showFromBarButtonItem:menuButton animated:YES];
    }
}

@end
