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

#import "VHBAudioReminderViewController.h"
#import "GradientLayer.h"

@interface VHBAudioReminderViewController () {
    BOOL recording;
    BOOL playing;
}

@end

NSString *const VHBAudioReminderTypeMusic = @"MUSIC";
NSString *const VHBAudioReminderTypeRecording = @"RECORDING";

@implementation VHBAudioReminderViewController

@synthesize addMediaActionSheet, longTapActionSheet, recordingActionSheet;
@synthesize musicPickerController, recordingPickerController;
@synthesize managedObjectContext;
@synthesize longTapReminder;
@synthesize longTapGestureRecognizer;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize musicBadge, messageBadge;
@synthesize delegate;
@synthesize recorderView;
@synthesize recordingPlayerView;
@synthesize currentRecordingURL;
@synthesize helpView;

- (id)init
{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load
{
    addMediaActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Media" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Music", @"Recordings", nil];
    addMediaActionSheet.delegate = self;
    
    longTapActionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Reminder" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove" otherButtonTitles: nil];
    longTapActionSheet.delegate = self;
    
    //Removed Select due to sandboxed nature of iOS apps, cant find anything recorded outside of VHB
    recordingActionSheet = [[UIActionSheet alloc] initWithTitle:@"Recordings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: /*@"Select", */@"Record", nil];
    recordingActionSheet.delegate = self;
    
    longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCaptured:)];
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    musicBadge = [UIImage imageNamed:@"Music.png"];
    messageBadge = [UIImage imageNamed:@"mic.png"];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];

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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor colorWithWhite:.25 alpha:1]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.fetchedResultsController.delegate = self;
    [self loadAudio];
    
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    [self updateHelpVisibility:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"VHBAudioReminderCell" bundle:nil] forCellReuseIdentifier:@"audioCell"];
    [self.tableView addGestureRecognizer:longTapGestureRecognizer];
    [self reloadData];
    
    self.recordingPlayerView.accessibilityViewIsModal = YES;
    self.recorderView.accessibilityViewIsModal = YES;
}

- (void)reloadData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self purgeOrUpdateReferences];
    [self save];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self loadAudio];
}

- (void)loadAudio
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AudioReminder" inManagedObjectContext:self.managedObjectContext];
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

- (void)updateHelpVisibility:(BOOL)animated
{
    float duration = 0;
    if (animated) {
        duration = .3;
    }
    
    if (_fetchedResultsController.fetchedObjects.count > 0 && self.tableView.alpha < 1) {
        self.tableView.userInteractionEnabled = YES;
        [UIView animateWithDuration:duration animations:^{
            self.tableView.alpha = 1;
            self.helpView.alpha = 0;
        }];
    } else if (_fetchedResultsController.fetchedObjects.count == 0 && self.helpView.alpha < 1) {
        
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:duration animations:^{
            self.tableView.alpha = 0;
            self.helpView.alpha = 1;
        }];
    }
}

- (void)purgeOrUpdateReferences
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AudioReminder" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:20];
    NSSortDescriptor *artistDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:artistDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *fetch = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];

	NSError *error = nil;
	if (![fetch performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    for (AudioReminder *reminder in [fetch fetchedObjects]) {
        if (reminder.filepath) {
            continue;
        }
        
        NSLog(@"%@", reminder.title);
        uint64_t mpID = strtoull([reminder.persistentID UTF8String], NULL, 0);
        MPMediaPredicate *idPredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithUnsignedLongLong:mpID] forProperty:MPMediaItemPropertyPersistentID comparisonType:MPMediaPredicateComparisonEqualTo];
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        [query addFilterPredicate:idPredicate];
        if (query.items.count == 0) {
            NSLog(@"Can't Find Song");
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            
            MPMediaPredicate *titlePredicate = [MPMediaPropertyPredicate predicateWithValue:reminder.title forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonEqualTo];
            [query addFilterPredicate:titlePredicate];
            if (reminder.artist) {
                MPMediaPredicate *artistPredicate = [MPMediaPropertyPredicate predicateWithValue:reminder.artist forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonEqualTo];
                [query addFilterPredicate:artistPredicate];
            }
            
            if (query.items.count > 0) {
                NSLog(@"Found same song with alternative ID");
                MPMediaItem *song = [query.items objectAtIndex:0];
                reminder.persistentID = [NSString stringWithFormat:@"%@", [song valueForProperty:MPMediaItemPropertyPersistentID]];
                reminder.missing = [NSNumber numberWithBool:NO];
            } else {
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Song Missing" message:@"The selected song could not be found on this device. If it was recently modified or synced, please add it again via the [+] button." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                //[alert show];
                reminder.missing = [NSNumber numberWithBool:YES];
            }
        } else {
            NSLog(@"Song Found!");
            MPMediaItem *song = [query.items objectAtIndex:0];
            NSString *title = [song valueForProperty:MPMediaItemPropertyTitle];
            if (![dRaw(encodeKey, reminder.title) isEqualToString:title]) {
                reminder.title = eRaw(encodeKey, title);
            }
            
            NSString *artist = [song valueForProperty:MPMediaItemPropertyArtist];
            if (![dRaw(encodeKey, reminder.artist) isEqualToString:artist]) {
                reminder.artist = eRaw(encodeKey, artist);
            }
            
            reminder.missing = [NSNumber numberWithBool:NO];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Audio Reminders";
}

- (void)viewDidUnload
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [self setAddMediaActionSheet:nil];
    [self setLongTapActionSheet:nil];
    [self setMusicPickerController:nil];
    [self setRecordingPickerController:nil];
    [self setLongTapGestureRecognizer:nil];
    [self setLongTapReminder:nil];
    [self setManagedObjectContext:nil];
    [self setFetchedResultsController:nil];
    [self setMusicBadge:nil];
    [self setMessageBadge:nil];
    [self setDelegate:nil];
    [self setRecorderView:nil];
    [self setRecordingPlayerView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == longTapActionSheet) {
        switch (buttonIndex) {
            case 0:
                if (!longTapReminder) {
                    return;
                }
                
                if ([longTapReminder.type isEqualToString:VHBAudioReminderTypeMusic]) {
                    [VHBLogUtils logEventType:LETRemindRemove withValue:@"Music"];
                } else {
                    [VHBLogUtils logEventType:LETRemindRemove withValue:@"Voice"];
                }
                
                [managedObjectContext deleteObject:longTapReminder];
                [self save];
                
                [self updateHelpVisibility:YES];
                
                break;
        }
    } else if (actionSheet == addMediaActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self addMusicClicked];
                break;
            case 1:
                [self addMessageClicked];
                break;
        }
    } else if (actionSheet == recordingActionSheet) {
        switch (buttonIndex) {
//            case 0:
//                [self selectMessageClicked];
//                break;
            case 0:
                [self recordMessageClicked];
                break;
        }
    }
}

- (UIBarButtonItem *)getAddButton
{
    return [self.tabBarController.navigationItem.rightBarButtonItems objectAtIndex:1];
}


- (void)addMusicClicked
{
    musicPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    musicPickerController.delegate = self;
    musicPickerController.allowsPickingMultipleItems = YES;
    
    [self presentViewController:musicPickerController animated:YES completion:nil];
}

- (void)addMessageClicked
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.tabBarController) {
            [recordingActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [recordingActionSheet showInView:self.view];
        }
    } else {
        if (self.tabBarController) {
            [recordingActionSheet showFromBarButtonItem:[self getAddButton] animated:YES];
        } else {
            [recordingActionSheet showInView:self.view];
        }
    }
}

- (void)selectMessageClicked
{
    recordingPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    recordingPickerController.delegate = self;
    recordingPickerController.allowsPickingMultipleItems = YES;
    
    [self presentViewController:recordingPickerController animated:YES completion:nil];
}

- (void)recordMessageClicked
{
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if(granted) {
            recorderView.delegate = self;
            [self.navigationController.view addSubview:recorderView];
            recorderView.frame = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 - 62, 200, 124);
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, recorderView.recordButton);
            [recorderView.recordButton becomeFirstResponder];
            NSLog(@"%@", [NSValue valueWithCGRect:recorderView.frame]);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                            message:@"Creating a recording requires access to your device's microphone.\n\n Please enable Microphone access in Settings / VirtualHopeBox / Microphone"
                                           delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            });
        }
    }];
}

- (void)audioRecorderDidFinishRecording:(NSURL *)audioFile title:(NSString *)title
{
    AudioReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"AudioReminder" inManagedObjectContext:managedObjectContext];
    reminder.dateCreated = [NSDate date];
    reminder.title = eRaw(encodeKey, title);
    reminder.artist = eRaw(encodeKey, @"My Recordings");
    reminder.filepath = eRaw(encodeKey, [audioFile relativeString]);
    reminder.type = VHBAudioReminderTypeRecording;
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
//    [managedObjectContext save:nil];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Recording saved.");
    [VHBLogUtils logEventType:LETRemindCapture withValue:@"Voice"];
}

- (void)save
{
//    NSError *error;
    
    VHBAppDelegate *appDelegate = (VHBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
    //TODO:checkbkack
    NSError *error;
    [managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [addMediaActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [longTapActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [recordingActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
    [recorderView stopClicked:nil];
    [recordingPlayerView stopClicked:nil];
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AudioReminder" inManagedObjectContext:self.managedObjectContext];
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
            AudioReminder *reminder = [fetch.fetchedObjects objectAtIndex:0];
            if ([reminder.missing boolValue]) {
                NSLog(@"Inactive item found with same ID. Reactivating");
                reminder.missing = [NSNumber numberWithBool:NO];
            }
            continue;
        }
        
        NSLog(@"New item. Adding.");
        
        AudioReminder *reminder = [NSEntityDescription insertNewObjectForEntityForName:@"AudioReminder" inManagedObjectContext:managedObjectContext];
        reminder.dateCreated = [NSDate date];
        reminder.title = eRaw(encodeKey, [item valueForProperty:MPMediaItemPropertyTitle]);
        reminder.artist = eRaw(encodeKey, [item valueForProperty:MPMediaItemPropertyArtist]);
        reminder.persistentID = persistentID;
        reminder.type = (mediaPicker == musicPickerController) ? VHBAudioReminderTypeMusic : VHBAudioReminderTypeRecording;
        if ([reminder.type isEqualToString:VHBAudioReminderTypeMusic]) {
            [VHBLogUtils logEventType:LETRemindAdd withValue:@"Music"];
        } else {
            [VHBLogUtils logEventType:LETRemindAdd withValue:@"Voice"];
        }
        
    }
    
    [self save];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self updateHelpVisibility:YES];
    } else {
        [self updateHelpVisibility:NO];
    }
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
    static NSString *CellIdentifier = @"audioCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VHBAudioReminderCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)longPressCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint p = [gesture locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (!indexPath) {
        return;
    }
    
    longTapReminder = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.tabBarController) {
            [longTapActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [longTapActionSheet showInView:self.view];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (recorderView.window) {
        return;
    }
    
    AudioReminder *reminder = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if (reminder.filepath) {
        [recordingPlayerView loadAudioWithURL:[NSURL URLWithString:dRaw(encodeKey, reminder.filepath)] title:dRaw(encodeKey, reminder.title)];
        [self.navigationController.view addSubview:recordingPlayerView];
        recordingPlayerView.frame = CGRectMake(self.view.frame.size.width / 2 - 140, self.view.frame.size.height / 2 - 90, 290, 180);
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, recordingPlayerView.playButton);
        [recordingPlayerView.playButton becomeFirstResponder];
    } else {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            uint64_t mpID = strtoull([reminder.persistentID UTF8String], NULL, 0);
            MPMediaPredicate *idPredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithUnsignedLongLong:mpID] forProperty:MPMediaItemPropertyPersistentID comparisonType:MPMediaPredicateComparisonEqualTo];
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            [query addFilterPredicate:idPredicate];
            if (query.items.count > 0) {
                MPMediaItem *song = [query.items objectAtIndex:0];
                MPMusicPlayerController *ipodPlayer = [MPMusicPlayerController applicationMusicPlayer];
                [ipodPlayer setQueueWithItemCollection:[MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:song]]];
                [ipodPlayer prepareToPlay];
                [ipodPlayer play];
            }
        });
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
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
    [self updateHelpVisibility:YES];
    [delegate rowsChanged];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    AudioReminder *reminder = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    UILabel *title = (UILabel *)[cell viewWithTag:1];
    title.text = dRaw(encodeKey, reminder.title);
    UILabel *artist = (UILabel *)[cell viewWithTag:2];
    artist.text = reminder.artist ? dRaw(encodeKey, reminder.artist) : @"Unknown Artist";
    UIImageView *badge = (UIImageView *)[cell viewWithTag:3];
    badge.image = ([reminder.type isEqualToString:VHBAudioReminderTypeMusic]) ? musicBadge : messageBadge;
    badge.accessibilityLabel = ([reminder.type isEqualToString:VHBAudioReminderTypeMusic]) ? @"Music" : @"Recording";
}

- (IBAction)menuClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.tabBarController) {
            [addMediaActionSheet showFromTabBar:self.tabBarController.tabBar];
        } else {
            [addMediaActionSheet showInView:self.view];
        }
    } else {
        [longTapActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        [recordingActionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        
        if (self.tabBarController) {
            [addMediaActionSheet showFromBarButtonItem:[self getAddButton] animated:YES];
        } else {
            [addMediaActionSheet showInView:self.view];
        }
    }
}

@end
