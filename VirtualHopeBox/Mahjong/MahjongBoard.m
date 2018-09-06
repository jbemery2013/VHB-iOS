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

#import "MahjongBoard.h"

@interface MahjongBoard() {
    int maxDepth, maxRightDepth, maxTopDepth, height, width, minCol, minRow;
    BOOL invalid; // For cacheing measurements. Invalid if recalculation is necessary.
}

@end

@implementation MahjongBoard

@synthesize freeTileSlots;
@synthesize puzzle;
@synthesize tileSlots;

- (id)initWithPuzzle:(MahjongPuzzle *)puzzleToLoad
{
    self = [super init];
    if (self != nil) {
        tileSlots = [[NSMutableArray alloc] init];
        puzzle = puzzleToLoad;
        [self loadPuzzle];
    }
    return self;
}

- (void)loadPuzzle
{
    if (puzzle == nil) {
        return;
    }
    
    if (tileSlots == nil) {
        tileSlots = [[NSMutableArray alloc] init];
    } else {
        [tileSlots removeAllObjects];
    }
    
    NSArray *tileStrings = [puzzle.default_state componentsSeparatedByString:@"|"];
    NSArray *tileData;

    MahjongTileSlot *slot;
    MahjongTile *tile;
    
    for (int i = 0; i < [tileStrings count]; i++) {
        NSString *tileString = [tileStrings objectAtIndex:i];

        slot = [[MahjongTileSlot alloc] init];
        tile = [[MahjongTile alloc] init];
        tileData = [tileString componentsSeparatedByString:@","];
        slot.row = [[tileData objectAtIndex:0] intValue];
        slot.column = [[tileData objectAtIndex:1] intValue];
        slot.layer = [[tileData objectAtIndex:2] intValue];
        tile.matchValue = [[tileData objectAtIndex:3] intValue];
        tile.matchSubValue = [[tileData objectAtIndex:4] intValue];
        tile.visible = YES;
        slot.tile = tile;
        [tileSlots addObject:slot];
    }
    
    invalid = true;
}

- (BOOL)hasVisibleTiles
{
    for (MahjongTileSlot *freeTileSlot in [self getFreeTileSlots]) {
        if (freeTileSlot.tile.visible) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasMovesLeft
{
    NSMutableSet *tileMatchSet = [[NSMutableSet alloc] init];
    for (MahjongTileSlot *freeTileSlot in [self getFreeTileSlots]) {
        NSNumber *matchValue = [NSNumber numberWithInt:[freeTileSlot.tile matchValue]];
        if ([tileMatchSet containsObject:matchValue]) {
            return YES;
        }
        [tileMatchSet addObject:[NSNumber numberWithInt:[freeTileSlot.tile matchValue]]];
    }
    return NO;
}

- (NSString *) getCurrentState
{
    NSMutableString *state = [[NSMutableString alloc] init];
    for (MahjongTileSlot *tileSlot in tileSlots) {
        [state appendString:(tileSlot.tile.visible ? @"1" : @"0")];
    }
    return state;
}

- (BOOL)isSlotFree:(MahjongTileSlot *)slot
{
    MahjongTile *tile = slot.tile;
    if (!tile.visible) {
        return NO;
    }
    
    if (invalid) {
        [self recalculate];
    }
    
    for (MahjongTileSlot *freeSlot in freeTileSlots) {
        if ([slot isEqual:freeSlot]) {
            return YES;
        }
    }
    return NO;
    
}

- (void)invalidate
{
    invalid = true;
}

- (NSArray *)getFreeTileSlots
{
    if (invalid) {
        [self recalculate];
    }
    
    return freeTileSlots;
}

- (void)recalculate
{
    [self calculateMeasurements];
    [self evaluateFreeSlots];
    invalid = false;
}

- (void)evaluateFreeSlots
{
    if (freeTileSlots == nil) {
        freeTileSlots = [[NSMutableArray alloc] init];
    } else {
        [freeTileSlots removeAllObjects];
    }
    
    BOOL blockedLeft, blockedRight, freeTile;
    
    for (MahjongTileSlot *slot in tileSlots) {
        if (!slot.tile.visible) {
            continue;
        }
        
        blockedLeft = false;
        blockedRight = false;
        freeTile = YES;
        
        
        for (MahjongTileSlot *otherSlot in tileSlots) {
            
            if (!otherSlot.tile.visible || [otherSlot isEqual:slot]) {
                continue;
            }
            
            // If a tile exists on the layer above the current tile and any part of it overlaps
            // then this slot isn't free
            if (otherSlot.layer == slot.layer + 1 && (otherSlot.column >= slot.column - 1 && otherSlot.column <= slot.column + 1) && (otherSlot.row >= slot.row - 1 && otherSlot.row <= slot.row + 1)) {
                freeTile = NO;
                break;
            }
            
            // If a tile touches both the right and left side of the current tile then it is not free
            if (otherSlot.layer == slot.layer && (otherSlot.row >= slot.row - 1 && otherSlot.row <= slot.row + 1)) {
                if (otherSlot.column == slot.column - 2) {
                    blockedLeft = true;
                }
                
                if (otherSlot.column == slot.column + 2) {
                    blockedRight = true;
                }
                
                if (blockedLeft && blockedRight) {
                    freeTile = NO;
                    break;
                }
            }
        }
        
        if (freeTile) {
            [freeTileSlots addObject:slot];
        }
        
    }
    
//NSLog(@"%@", freeTileSlots);
}

- (void)calculateMeasurements
{
    maxDepth = 0;
    maxRightDepth = 0;
    maxTopDepth = 0;
    minRow = INT_MAX;
    minCol = INT_MAX;
    
    int maxCol = 0;
    int maxRow = 0;
    
    for (MahjongTileSlot *slot in tileSlots) {
        if (!slot.tile.visible) {
            continue;
        }
        
        if (slot.layer > maxDepth) {
            maxDepth = slot.layer;
        }
        
        if (slot.column >= maxCol) {
            if (slot.layer > maxRightDepth) {
                maxRightDepth = slot.layer;
            }
            maxCol = slot.column;
        }
        
        if (slot.row > maxRow) {
            maxRow = slot.row;
        }
        
        if (slot.column < minCol) {
            minCol = slot.column;
        }
        
        if (slot.row <= minRow) {
            if (slot.layer > maxTopDepth) {
                maxTopDepth = slot.layer;
            }
            minRow = slot.row;
        }
    }
    
    height = maxRow - minRow + 2;
    width = maxCol - minCol + 2;
}

- (int)getMaxDepth
{
    if (invalid) {
        [self recalculate];
    }
    
    return maxDepth;
}

- (int)getRightmostMaxDepth
{
    if (invalid) {
        [self recalculate];
    }
    
    return maxRightDepth;
}

- (int)getTopmostMaxDepth
{
    if (invalid) {
        [self recalculate];
    }
    
    return maxTopDepth;
}

- (int)getHeight
{
    if (invalid) {
        [self recalculate];
    }
    
    return height;
}

- (int)getWidth
{
    if (invalid) {
        [self recalculate];
    }
    
    return width;
}

- (int)getMinColumn
{
    if (invalid) {
        [self recalculate];
    }
    
    return minCol;
}

- (int)getMinRow
{
    if (invalid) {
        [self recalculate];
    }
    
    return minRow;
}

@end
