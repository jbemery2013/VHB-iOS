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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MahjongBoard.h"
#import "MahjongTileSlotView.h"

@protocol MahjongBoardViewDelegate <NSObject>

- (void)puzzleComplete;
- (void)puzzleFailed;
- (void)tileSelected:(MahjongTileSlotView *)slotView;
- (void)tileUnselected:(MahjongTileSlotView *)slotView;
- (void)puzzleLoaded;

@end

@interface MahjongBoardView : UIView 

@property (assign, nonatomic) int selectedTile;
@property (weak, nonatomic) MahjongBoard *board;
@property id <MahjongBoardViewDelegate> delegate;
@property (assign, nonatomic) CGRect visibleBounds;
@property (assign, nonatomic) BOOL tileAnimating;
@property (setter = setHighlightEnabled:, getter = getHighlightEnabled) BOOL highlightEnabled;

- (BOOL)isTileMatch:(MahjongTileSlot *)slotOne otherSlot:(MahjongTileSlot *)slotTwo;
- (void)hideTile:(MahjongTileSlotView *)slot;
- (MahjongTileSlotView *)getSelectedTile;
- (void)loadBoard;
- (void)resetBoard;
- (void)updateTiles;
- (UIImage *)getScreenshot;
- (void)updateTransform;
@end
