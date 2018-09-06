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

#import "MahjongBoardView.h"

@interface MahjongBoardView() {
    NSMutableArray *accessibleTiles;
    int minCol, minRow, maxRightDepth, maxTopDepth;
    CGPoint centerPoint;
}

@end

@implementation MahjongBoardView

@synthesize board, selectedTile, delegate, visibleBounds, tileAnimating, highlightEnabled = _highlightEnabled;

-(void)layoutSubviews
{
    NSArray *rects = [self measureTiles];
    CGRect rect;
    MahjongTileSlotView *view;
    
    for (int i = 0; i < [[self subviews] count]; i++) {
        rect = [[rects objectAtIndex:i] CGRectValue];
        view = [self.subviews objectAtIndex:i];
        if (!view.tileSlot.tile.visible) {
            continue;
        }
        view.frame = rect;
    }
}


- (NSArray *)measureTiles
{    
    float stepWidth = 70.0f;
    float stepHeight = 100.0f;
    
    float tileWidth = stepWidth * 2.0f;
    float tileHeight = stepHeight * 2.0f;
    
    float rightIso = 20.0f;
    float topIso = 20.0f;
    float leftIsoStep = 10.0f;
    float topIsoStep = 10.0f;
    
    float maxTopIso = maxTopDepth * topIso;
    
    float topShift = 0;
    float leftShift = 0;
    
    
    float minLeft = MAXFLOAT, maxRight = 0, minTop = MAXFLOAT, maxBottom = 0;
    
    NSMutableArray *rects = [[NSMutableArray alloc] init];
    
    CGRect emptyRect = CGRectMake(0, 0, 0, 0);
    for (MahjongTileSlotView *view in self.subviews) {
        if (!view.tileSlot.tile.visible) {
            [rects addObject:[NSValue valueWithCGRect:emptyRect]];
            continue;
        }
        
        MahjongTileSlot *slot = view.tileSlot;
        
        float col = slot.column - minCol;//[board getMinColumn];
        float row = slot.row - minRow;//[board getMinRow];
        float left = leftShift + ((col * stepWidth) - (col * leftIsoStep));
        float top = topShift + ((row * stepHeight) - (row * topIsoStep) + maxTopIso);
        
        float leftLayerOffset = rightIso * slot.layer;
        float topLayerOffset = topIso * slot.layer;
        
        CGRect rect = CGRectMake(left + leftLayerOffset, top - topLayerOffset, tileWidth, tileHeight);
        [rects addObject:[NSValue valueWithCGRect:rect]];
        
        if (rect.origin.x < minLeft) {
            minLeft = rect.origin.x;
        }
        
        if (rect.origin.x + rect.size.width > maxRight) {
            maxRight = rect.origin.x + rect.size.width;
        }
        
        if (rect.origin.y < minTop) {
            minTop = rect.origin.y;
        }
        
        if (rect.origin.y + rect.size.height > maxBottom) {
            maxBottom = rect.origin.y + rect.size.height;
        }
    }
    
    self.visibleBounds = CGRectMake(minLeft, minTop, maxRight - minLeft, maxBottom - minTop);
    
    return rects;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    for (MahjongTileSlotView *view in self.subviews) {
        if ([[view.layer presentationLayer] hitTest:point] && [board isSlotFree:view.tileSlot]) {
            return view;
        }
    }
    
    return nil;
}

- (void)loadBoard
{
    if (!board) {
        return;
    }
    
    accessibleTiles = [[NSMutableArray alloc] init];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    selectedTile = -1;
    
    NSMutableArray *tileStore = [[NSMutableArray alloc] init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        MahjongTileSlot *slot;
        MahjongTileSlotView *slotView;
        for (int i = 0; i < [board.tileSlots count]; i++) {
            slot = [board.tileSlots objectAtIndex:i];
            slotView = [[MahjongTileSlotView alloc] initWithTileSlot:slot];
            slotView.tag = i;
            [tileStore addObject:slotView];
        
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            for (MahjongTileSlotView *view in tileStore) {
                [self addSubview:view];
            }
            
            for (MahjongTileSlotView *view in self.subviews) {
                if (_highlightEnabled && [board isSlotFree:view.tileSlot]) {
                    view.highlighted = YES;
                }
            }
            
            minCol = [board getMinColumn];
            minRow = [board getMinRow];
            maxTopDepth = [board getTopmostMaxDepth];
            maxRightDepth = [board getRightmostMaxDepth];
            
            [self measureTiles];
            self.bounds = CGRectMake(visibleBounds.origin.x, visibleBounds.origin.y, visibleBounds.size.width, visibleBounds.size.height);
            
            
            [self updateTransform];
            
            centerPoint = self.center;
            
            for (MahjongTileSlotView *view in self.subviews) {
                [view setNeedsDisplay];
            }
            
            [self updateTiles];
            
            [delegate puzzleLoaded];
        });
    });
}

- (MahjongTileSlotView *)getSelectedTile
{
    if (selectedTile < 0) {
        return nil;
    }
    
    return [self.subviews objectAtIndex:selectedTile];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *view = [[touches anyObject] view];
    if ([view isKindOfClass:[MahjongTileSlotView class]]) {
        MahjongTileSlotView *slotView = (MahjongTileSlotView *) view;
        
        if (![board isSlotFree:slotView.tileSlot]) {
            return;
        }
        
        MahjongTileSlotView *currentSelection = [self getSelectedTile];
        
        self.selectedTile = -1;
        
        if (currentSelection != nil && currentSelection == slotView) {
            currentSelection.selected = !slotView.selected;
            
            [currentSelection setNeedsDisplay];
            [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
            
            [UIView animateWithDuration:0.0
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{currentSelection.transform = CGAffineTransformIdentity;}
                             completion:^(BOOL finished){}
             ];
        } else {
            if (currentSelection != nil && [self isTileMatch:slotView.tileSlot otherSlot:currentSelection.tileSlot]) {
                [UIView animateWithDuration:0.0
                                      delay:0.0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{
                                     slotView.transform = CGAffineTransformIdentity;
                                     currentSelection.transform = CGAffineTransformIdentity;}
                                 completion:^(BOOL finished){}
                ];
                [currentSelection setNeedsDisplay];
                [slotView setNeedsDisplay];
                
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                
                [self hideTile:slotView];
                [self hideTile:currentSelection];
                
                CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                shrinkAnimation.toValue = [NSNumber numberWithDouble:0.01];
                shrinkAnimation.duration = 0.5;
                shrinkAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                shrinkAnimation.fillMode=kCAFillModeForwards;
                shrinkAnimation.removedOnCompletion=NO;
                [shrinkAnimation setDelegate:self];
                self.tileAnimating = YES;

                [slotView.layer addAnimation:shrinkAnimation forKey:@"shrink"];
                [currentSelection.layer addAnimation:shrinkAnimation forKey:@"shrink"];
                
                self.selectedTile = -1;
                
                [self performSelector:@selector(notifyMatch) withObject:nil afterDelay:1.5];
                
                return;
            } else {
                slotView.selected = YES;
                currentSelection.selected = NO;
                self.selectedTile = (int)slotView.tag;
                
                [currentSelection setNeedsDisplay];
                [slotView setNeedsDisplay];
                
                [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
                
                [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
                    slotView.transform = CGAffineTransformMakeScale(.9, .9);
                } completion:^(BOOL finished) {
                    
                }];
                
                [UIView animateWithDuration:0.0
                                      delay:0.0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^{currentSelection.transform = CGAffineTransformIdentity;}
                                 completion:^(BOOL finished){}
                 ];
            }
        }
    }
}

- (void)setHighlightEnabled:(BOOL)value
{
    _highlightEnabled = value;
    [self updateTiles];
}

- (BOOL)getHighlightEnabled
{
    return _highlightEnabled;
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    if (tileAnimating) {
        tileAnimating = NO;
        [board invalidate];
        [self measureTiles];
        
        [self updateTiles];
        
        BOOL visibleTiles = [board hasVisibleTiles];
        if (!visibleTiles || ![board hasMovesLeft]) {
            if (!visibleTiles) {
                if (delegate) {
                    [delegate puzzleComplete];
                }
            } else {
                [self resetBoard];
                if (delegate) {
                    [delegate puzzleFailed];
                }
            }
            return;
        }
        
        [self measureTiles];
        [UIView animateWithDuration:1 animations:^{
            [self updateTransform];
        }];
        
        [board.puzzle setCurrent_state:[board getCurrentState]];
    }
}

- (void)resetBoard
{
    MahjongTileSlotView *selectedTileView = [self getSelectedTile];
    if (selectedTileView != nil) {
        [UIView animateWithDuration:.1 animations:^{
            selectedTileView.transform = CGAffineTransformIdentity;
        }];
        selectedTile = -1;
        selectedTileView.selected = NO;
        [selectedTileView setNeedsDisplay];
    }
    
    CABasicAnimation *popAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    popAnimation.fromValue = [NSNumber numberWithDouble:0.001];
    popAnimation.toValue = [NSNumber numberWithDouble:1.0];
    popAnimation.duration = 0.5;
    popAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    popAnimation.fillMode=kCAFillModeForwards;
    popAnimation.removedOnCompletion=NO;
    
    BOOL highlighted;
    
    NSMutableSet *hiddenViews = [[NSMutableSet alloc] init];
    for (MahjongTileSlotView *view in self.subviews) {    
        if (view.hidden != NO) {
            view.hidden = NO;
            view.tileSlot.tile.visible = YES;
            [hiddenViews addObject:view];
        }
        view.selected = NO;
    }
    
    [board invalidate];
    
    NSMutableSet *highlightChangeViews = [[NSMutableSet alloc] init];
    for (MahjongTileSlotView *view in self.subviews) {
        highlighted = _highlightEnabled && [board isSlotFree:view.tileSlot];
        if (view.highlighted != highlighted) {
            view.highlighted = highlighted;
            [highlightChangeViews addObject:view];
        }
    }
    
    for (MahjongTileSlotView *view in hiddenViews) {
        [view setNeedsDisplay];
    }
    
    for (MahjongTileSlotView *view in highlightChangeViews) {
        [view setNeedsDisplay];
    }
    
    [self measureTiles];
    
    // Force the redraw to happen before these animations are started.
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    
    float timeoffset = 0;
    for (MahjongTileSlotView *view in hiddenViews) {
        view.highlighted = _highlightEnabled && [board isSlotFree:view.tileSlot];
        if ([view.layer animationForKey:@"shrink"] == nil) {
            continue;
        }
        popAnimation.beginTime = CACurrentMediaTime() + timeoffset;
        [view.layer addAnimation:popAnimation forKey:@"pop"];
        timeoffset += .05;
    }
    
    [self notifyReset];
    [UIView animateWithDuration:1 animations:^{
        [self updateTransform];
    } completion:^(BOOL finished) {
        [self updateTiles];
    }];
}

- (void)notifyMatch
{
    if ([board.puzzle.complete boolValue]) {
        return;
    }
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Pair removed from board.");
}

- (void)notifyReset
{
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Puzzle reset");
}

- (void)updateTiles
{
    BOOL changed, highlighted, hidden, free;
    [accessibleTiles removeAllObjects];
    for (MahjongTileSlotView *view in self.subviews) {
        changed = false;
        free = [board isSlotFree:view.tileSlot];
        highlighted = _highlightEnabled && free;
        hidden = ![view.tileSlot.tile visible];
        if (view.highlighted != highlighted) {
            changed = true;
            view.highlighted = highlighted;
        }
        
        if (free) {
            [accessibleTiles addObject:view];
        }
        
        if (view.hidden != hidden) {
            changed = true;
            view.hidden = hidden;
        }
        
        if (changed) {
            [view setNeedsDisplay];
        }
    }
}

- (void)updateTransform
{
    float widthRatio = self.superview.frame.size.width / visibleBounds.size.width;
    float heightRatio = self.superview.frame.size.height / visibleBounds.size.height;
    float fitRatio = (widthRatio < heightRatio) ? widthRatio : heightRatio;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (fitRatio > .8) {
            fitRatio = .8;
        }
    } else {
        if (fitRatio > .6) {
            fitRatio = .6;
        }
    }
    
    CGPoint newCenter = CGPointMake((self.bounds.size.width - visibleBounds.size.width) / 2.0 - visibleBounds.origin.x, (self.bounds.size.height - visibleBounds.size.height) / 2.0 - visibleBounds.origin.y);
    
    newCenter = CGPointApplyAffineTransform(newCenter, CGAffineTransformMakeScale(fitRatio, fitRatio));
    newCenter.x = (self.superview.frame.size.width / 2.0) + newCenter.x;
    newCenter.y = (self.superview.frame.size.height / 2.0) + newCenter.y;
    self.center = newCenter;                
    self.transform = CGAffineTransformMakeScale(fitRatio, fitRatio);
}

- (void)hideTile:(MahjongTileSlotView *)slot
{
    slot.tileSlot.tile.visible = NO;
    slot.highlighted = NO;
    slot.selected = NO;
}

- (BOOL)isTileMatch:(MahjongTileSlot *)slot otherSlot:(MahjongTileSlot *)otherSlot
{
    return [slot.tile matchValue] == [otherSlot.tile matchValue];
}

- (UIImage*)getScreenshot 
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return ret;
    
}

- (BOOL)isAccessibilityElement
{
    return NO;
}

- (NSInteger)accessibilityElementCount
{
    return accessibleTiles.count;
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [accessibleTiles indexOfObject:element];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [accessibleTiles objectAtIndex:index];
}

@end
