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
#import "CBSelectAudioViewController.h"
#import "GradientLayer.h"

@interface CBSelectAudioViewController ()

@end

@implementation CBSelectAudioViewController
@synthesize longTapActionSheet;
@synthesize musicPickerController;
@synthesize managedObjectContext;
@synthesize longTapSong;
@synthesize longTapGestureRecognizer;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize addButton;

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
    
    [self.navigationItem setRightBarButtonItem:addButton];
    
    longTapActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Music" otherButtonTitles: nil];
    longTapActionSheet.delegate = self;
    
    musicPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    musicPickerController.delegate = self;
    
    longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCaptured:)];
    [self.tableView addGestureRecognizer:longTapGestureRecognizer];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CBMusicTableCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        [self purgeOrUpdateReferences];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self loadSongs];
        });
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [self save];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.tableView.bounds;
    UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
    [view.layer insertSublayer:bgLayer atIndex:0];
    self.tableView.backgroundView = view;
    self.fetchedResultsController.delegate = self;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    [super viewWillDisappear:animated];
}

- (void)loadSongs
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CBSong" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *artistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES];
    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:artistDescriptor, titleDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"missing == 0"];
    [fetchRequest setPredicate:activePredicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![_fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    [self.tableView reloadData];
}

- (void)purgeOrUpdateReferences
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CBSong" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *artistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:artistDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
	NSError *error = nil;
	if (![fetch performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    for (CBSong *song in [fetch fetchedObjects]) {
        NSLog(@"%@", song.title);
        uint64_t mpID = strtoull([song.persistentID UTF8String], NULL, 0);
        MPMediaPredicate *idPredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithUnsignedLongLong:mpID] forProperty:MPMediaItemPropertyPersistentID comparisonType:MPMediaPredicateComparisonEqualTo];
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        [query addFilterPredicate:idPredicate];
        if (query.items.count == 0) {
            NSLog(@"Can't Find Song");
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            
            MPMediaPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:song.title forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonEqualTo];
            [query addFilterPredicate:titlePredicate];
            if (song.artist) {
                MPMediaPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:song.artist forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonEqualTo];
                [query addFilterPredicate:artistPredicate];
            }
            
            if (query.items.count > 0) {
                NSLog(@"Found same song with alternative ID");
                MPMediaItem *item = [query.items objectAtIndex:0];
                song.persistentID = [NSString stringWithFormat:@"%@", [item valueForProperty:MPMediaItemPropertyPersistentID]];
                song.missing = [NSNumber numberWithBool:NO];
            } else {
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Song Missing" message:@"The selected song could not be found on this device. If it was recently modified or synced, please add it again via the [+] button." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                //[alert show];
                song.missing = [NSNumber numberWithBool:YES];
            }
        } else {
            NSLog(@"Song Found!");
            MPMediaItem *item = [query.items objectAtIndex:0];
            NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
            if (![song.title isEqualToString:title]) {
                song.title = title;
            }
            
            NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
            if (![song.artist isEqualToString:artist]) {
                song.artist = artist;
            }
            
            song.missing = [NSNumber numberWithBool:NO];
        }
    }
    [self save];
}

- (void)viewDidUnload
{
    [self setLongTapActionSheet:nil];
    [self setMusicPickerController:nil];
    [self setLongTapGestureRecognizer:nil];
    [self setLongTapSong:nil];
    [self setManagedObjectContext:nil];
    [self setFetchedResultsController:nil];
    [self setAddButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapActionSheet) {
        switch (buttonIndex) {
            case 0:
                if (!longTapSong) {
                    return;
                }
                [managedObjectContext deleteObject:longTapSong];
                [self save];
                break;
        }
    }
}

- (void)save
{
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    NSError *error;
//    [managedObjectContext save:&error];
//    if (error) {
//        NSLog(@"%@", error);
//    }
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CBSong" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *artistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:artistDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    for (MPMediaItem *item in mediaItemCollection.items) {
        NSString *persistentID = [NSString stringWithFormat:@"%@", [item valueForProperty:MPMediaItemPropertyPersistentID]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"persistentID like[c] %@", persistentID];
        [fetchRequest setPredicate:predicate];
        
        NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        NSError *error = nil;
        if (![fetch performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if (fetch.fetchedObjects.count > 0) {
            CBSong *reminder = [fetch.fetchedObjects objectAtIndex:0];
            if ([reminder.missing boolValue]) {
                NSLog(@"Inactive item found with same ID. Reactivating");
                reminder.missing = [NSNumber numberWithBool:NO];
            }
            continue;
        }
        
        NSLog(@"New item. Adding.");
        
        CBSong *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"CBSong" inManagedObjectContext:managedObjectContext];
        reminder.dateCreated = [NSDate date];
        reminder.title = [item valueForProperty:MPMediaItemPropertyTitle];
        reminder.artist = [item valueForProperty:MPMediaItemPropertyArtist];
        reminder.persistentID = persistentID;
    }
    
    [self save];
    [self dismissViewControllerAnimated:YES completion:^{
        [self loadSongs];
    }];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self fetchedResultsController] fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CBMusicTableCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Music";
}

- (void)longPressCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (!indexPath) {
        return;
    }
    
    longTapSong = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.tabBarController) {
            [longTapActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [longTapActionSheet showInView:self.view];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBSong *reminder = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    uint64_t mpID = strtoull([reminder.persistentID UTF8String], NULL, 0);
    MPMediaPredicate *idPredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithUnsignedLongLong:mpID] forProperty:MPMediaItemPropertyPersistentID comparisonType:MPMediaPredicateComparisonEqualTo];
    MPMediaQuery *query = [MPMediaQuery songsQuery];
    [query addFilterPredicate:idPredicate];
    if (query.items.count > 0) {
        MPMediaItem *song = [query.items objectAtIndex:0];
        MPMusicPlayerController *ipodPlayer = [MPMusicPlayerController iPodMusicPlayer];
        [ipodPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:song]]];
        [ipodPlayer play]; 
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            //[tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CBSong *reminder = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    title.text = reminder.title;
    UILabel *artist = (UILabel *)[cell viewWithTag:2];
    artist.text = reminder.artist ? reminder.artist : @"Unknown Artist";
}

- (IBAction)addClicked:(id)sender {
    [self presentViewController:musicPickerController animated:YES completion:nil];
}
@end
