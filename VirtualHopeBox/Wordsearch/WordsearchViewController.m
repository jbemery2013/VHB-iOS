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

#import <QuartzCore/QuartzCore.h>
#import "WordsearchViewController.h"
#import "WordsearchWord.h"
#import "GradientLayer.h"


@interface WordsearchViewController () {
    CAShapeLayer *layer;
    NSArray *wordList;
    bool complete;
    UIFont *foundFont, *wordFont;
}


@end

@implementation WordsearchViewController
@synthesize boardView;
@synthesize wordView;
@synthesize puzzleCompleteLabel;
@synthesize contactButton;
@synthesize navigationBarItem;
@synthesize segmentedControlButton;
@synthesize segmentedControl;
@synthesize puzzleButton;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutViews];
    CAGradientLayer *bgLayer = [GradientLayer greyGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        segmentedControl.tintColor = nil;
    }
    
    [VHBLogUtils logEventType:LETWordsearchOpen];
    [VHBLogUtils startTimedEvent:LETWordsearchClose];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [VHBLogUtils endTimedEvent:LETWordsearchClose];
}


- (IBAction)segmentValueChanged:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [wordView removeFromSuperview];
            [self.view addSubview:boardView];
            [self.view bringSubviewToFront:puzzleCompleteLabel];
            break;
            //NSLog(@"%@", NSStringFromCGRect(boardView.frame));
        case 1:
            [self loadWordList];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [boardView removeFromSuperview];
                CGRect frame = self.view.frame;
                frame.origin.y = 0;
                [self.view addSubview:wordView];
                wordView.frame = frame;
                NSLog(@"%@", NSStringFromCGRect(wordView.frame));
            }
            break;
    }
}

- (void)loadWordList
{
    
    wordList = [[boardView getBoard].words sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        WordsearchWord *wordOne = (WordsearchWord *) obj1;
        WordsearchWord *wordTwo = (WordsearchWord *) obj2;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || wordOne.found == wordTwo.found) {
            return [wordOne.text compare:wordTwo.text];
        } else {
            return wordOne.found ? NSOrderedDescending : NSOrderedAscending;
        }
    }];
    
    [wordView reloadData];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        wordView.frame = self.view.frame;
        [wordView setNeedsDisplay];
    }
    
}

- (void)wordFound:(WordsearchWord *)word
{
    int wordsLeft = 0;
    for (WordsearchWord *tmpWord in [boardView getBoard].words) {
        if (tmpWord.found) {
            continue;
        }
        wordsLeft++;
    }
    
    NSString *title = [NSString stringWithFormat:@"Words (%i)", wordsLeft];
    [segmentedControl setTitle:title forSegmentAtIndex:1];
    [self loadWordList];
}

- (void)puzzleCompleted
{
    complete = true;
    boardView.userInteractionEnabled = false;
    
    puzzleCompleteLabel.frame = self.view.bounds;
    puzzleButton.frame = self.view.bounds;
    
    [self.view addSubview:puzzleCompleteLabel];
    [self.view addSubview:puzzleButton];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         boardView.alpha = 0.0;
                         wordView.alpha = 0.0;
                         puzzleCompleteLabel.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.puzzleButton);
                     }];
    
    
    [VHBLogUtils logEventType:LETWordsearchCompleted];
}

- (void)layoutViews
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        float boardWidth = self.view.bounds.size.width * 0.8;
        boardView.frame = CGRectMake(-1, -1, boardWidth, self.view.bounds.size.height + 2);
        wordView.frame = CGRectMake(boardWidth, 0, self.view.bounds.size.width - boardWidth, self.view.bounds.size.height);
        boardView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        boardView.layer.borderWidth = 1;
    } else {
        boardView.frame = self.view.bounds;
        wordView.frame = self.view.bounds;
    }
    puzzleCompleteLabel.center = self.view.center;
    
}
- (IBAction)loadNewPuzzle:(id)sender {
    [self initPuzzle:YES];
}

- (void)initPuzzle:(BOOL)animated {
    complete = false;
    
    if (animated) {
        [UIView animateWithDuration:.5 animations:^{
            puzzleCompleteLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self initPuzzle];
        }];
    } else {
        [self initPuzzle];
    }
}

- (void)initPuzzle
{
    [boardView removeFromSuperview];
    [puzzleCompleteLabel removeFromSuperview];
    [puzzleButton removeFromSuperview];
    
    float cols = 8;
    float rows = 10;
    
    NSLog(@"Cols %f, Rows %f", cols, rows);
    
    WordsearchBoard *board = [[WordsearchBoard alloc] initWithRows:rows columns:cols];
    for (int i = 0; i < 2; i++) {
        WordsearchBoard *alternateBoard = [[WordsearchBoard alloc] initWithRows:rows columns:cols];
        if (board.complexity < alternateBoard.complexity) {
            board = alternateBoard;
        }
    }
    
    for (int i = 0; i < [board.cells count]; i++) {
        if ([(NSString *)[board.cells objectAtIndex:i] characterAtIndex:0] != 32) {
            continue;
        }
        
        unichar randInt = (arc4random() % (25)) + 65;
        
        [board.cells replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%c", randInt]];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        boardView.frame = self.view.bounds;
    }
    
    [boardView setBoard:board];
    
    boardView.delegate = self;
    boardView.alpha = 0.0;
    
    [self.view addSubview:boardView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         boardView.alpha = 1.0;
                         wordView.alpha = 1.0;
                     }];
    
    NSString *title = [NSString stringWithFormat:@"Words (%lu)", (unsigned long)[[boardView getBoard].words count]];
    [segmentedControl setTitle:title forSegmentAtIndex:1];
    
    boardView.userInteractionEnabled = YES;
    complete = false;
    
    [self loadWordList];
    [layer removeAllAnimations];
    [layer removeFromSuperlayer];
    [boardView setNeedsDisplay];
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"New Puzzle Started");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [contactButton setAccessibilityLabel:NSLocalizedString(@"Support Contacts", @"")];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [navigationBarItem setRightBarButtonItems:[NSArray arrayWithObjects:contactButton, segmentedControlButton, nil] animated:YES];
    } else {
        [navigationBarItem setRightBarButtonItem:contactButton];
    }
    foundFont = [UIFont systemFontOfSize:20];
    wordFont = [UIFont boldSystemFontOfSize:20];
    
    self.wordView.backgroundView = nil;
    self.wordView.backgroundColor = [UIColor clearColor];
    
    [self loadNewPuzzle:nil];
    
    wordView.allowsSelection = NO;
    wordView.delegate = self;
    wordView.dataSource = self;
    
}

- (void)viewDidUnload
{
    [self setBoardView:nil];
    [self setWordView:nil];
    [self setPuzzleCompleteLabel:nil];
    wordList = nil;
    wordFont = nil;
    foundFont = nil;
    layer = nil;
    [self setContactButton:nil];
    [self setNavigationBarItem:nil];
    [self setSegmentedControlButton:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self layoutViews];
    [boardView setNeedsDisplay];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (boardView == nil || [boardView getBoard] == nil) {
        return 0;
    }
    
    return [wordList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    WordsearchWord *word = [wordList objectAtIndex:[indexPath row]];
    cell.textLabel.text = word.text;
    if (word.found) {
        cell.textLabel.font = foundFont;
        cell.textLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@: Found", word.text];
        //cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //cell.accessoryView.alpha = 0.4;
    } else {
        cell.textLabel.font = wordFont;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.accessibilityLabel = [NSString stringWithFormat:@"%@: Not Found", word.text];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

@end
