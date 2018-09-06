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

#import "ImageSwapPuzzleView.h"
#import "DefaultsWrapper.h"

@interface ImageSwapPuzzleView() {
    float tileWidth, tileHeight, spacing;
    BOOL scrambling;
    int scrambleThread;
    int moveCount;
}

@end

@implementation ImageSwapPuzzleView

@synthesize pulseAnimation, swapAnimation;
@synthesize selectedIndex;
@synthesize puzzle;
@synthesize image;
@synthesize hintView;
@synthesize delegate;
@synthesize highlightView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //[self initPuzzle];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //[self initPuzzle];
    }
    return self;
}

- (void)initPuzzle
{
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self initPuzzle:decryptIntForKey(@"image_swap_difficulty")];
}

- (void)initPuzzle:(Difficulty)difficulty;
{
    moveCount = 0;
    
    int rows = 3;
    int columns = 3;
    switch (difficulty) {
        case kMedium:
            rows = 4;
            columns = 4;
            break;
        case kHard:
            rows = 5;
            columns = 5;
            break;
        default:
            break;
    }
    
    puzzle = [[ImageSwapPuzzle alloc] initWithRows:rows columns:columns];
    spacing = 3;
    //image = 
    [self loadPuzzle];
    pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    pulseAnimation.toValue = [NSNumber numberWithFloat:0.98];
    pulseAnimation.duration = 0.5;
    pulseAnimation.autoreverses = YES;
    pulseAnimation.repeatCount = INFINITY;
    swapAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    swapAnimation.duration = 1.0;
}

- (void)loadPuzzle {
	if (puzzle == nil){
		return; 
	}
    
    selectedIndex = -1;
    
    float widthInset = (spacing * (puzzle.columns + 1)) / 2.0;
    float heightInset = (spacing * (puzzle.rows + 1)) / 2.0;
    
    CGRect bound = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    bound = CGRectInset(bound, widthInset, heightInset);
    bound = CGRectOffset(bound, -widthInset, -heightInset);
    
    tileWidth = bound.size.width / (float) puzzle.columns;
    tileHeight = bound.size.height / (float) puzzle.rows;
    
    UIGraphicsBeginImageContextWithOptions(bound.size, NO, 1.0f);
    
    float widthScale = bound.size.width / image.size.width;
    float heightScale = bound.size.height / image.size.height;
    float scale = widthScale > heightScale ? widthScale : heightScale;
    CGSize scaledSize = image.size;
    scaledSize.width = scale * scaledSize.width;
    scaledSize.height = scale * scaledSize.height;
    
    float leftDiff = -(scaledSize.width - (bound.size.width)) / 2.0;
    float topDiff = -(scaledSize.height - bound.size.height) / 2.0;
    
    [image drawInRect:CGRectMake(leftDiff, topDiff, scaledSize.width, scaledSize.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    hintView = [[UIImageView alloc] initWithImage:image];
    hintView.alpha = 0.0;
    hintView.frame = CGRectInset(self.bounds, spacing, spacing);
    //hintView.center = self.center;
    
    tileWidth = bound.size.width / (float) puzzle.columns;
    tileHeight = bound.size.height / (float) puzzle.rows;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (ImageSwapTile *tile in puzzle.tiles) {
        ImageSwapTileView *tileView = [[ImageSwapTileView alloc] initWithImage:[self imageForTile:tile.currentPosition]];
        tileView.tile = tile;
        tileView.tag = tile.solvedPosition+1;
        [self addSubview:tileView];
    }
    
    [self addSubview:hintView];
    
    UIImage *highlightImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"highlightTile" ofType:@"png"]];
    highlightImage = [highlightImage stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    highlightView = [[UIImageView alloc] initWithImage:highlightImage];
    highlightView.frame = CGRectMake(0.0f, 0.0f, tileWidth, tileHeight);
    highlightView.userInteractionEnabled = NO;
    
    [self layoutSubviews];
    [self setNeedsDisplay];
    
    scrambleThread = arc4random();
    [self scrambleTilesWithDelay:1.0 thread:scrambleThread];
}

- (void)showHint
{
    if (scrambling) {
        return;
    }
    
    [UIView animateWithDuration:.5 animations:^{
        hintView.alpha = 0.8;
    }];
}

- (UIImage *)imageForTile:(int)index
{
    int row = index / puzzle.columns;
    int col = index % puzzle.columns;
    
    CGRect tileRect = CGRectMake(col * tileWidth, row * tileHeight, tileWidth, tileHeight);
    CGImageRef tileImageRef = CGImageCreateWithImageInRect(image.CGImage, tileRect);
    UIImage *tileImage = [UIImage imageWithCGImage:tileImageRef];
    CGImageRelease(tileImageRef);
    
    return tileImage;
}

- (void)layoutSubviews
{
    int row, col;
    float leftOffset, topOffset;
    
    for (UIView *view in self.subviews) {
        if ([view isMemberOfClass:[ImageSwapTileView class]]) {
            ImageSwapTileView *tileView = (ImageSwapTileView *) view;
            row = tileView.tile.currentPosition / puzzle.columns;
            col = tileView.tile.currentPosition % puzzle.columns;

            leftOffset = (tileWidth * col) + ((col + 1) * spacing);
            topOffset = (tileHeight * row) + ((row + 1) * spacing);
            tileView.frame = CGRectMake(leftOffset, topOffset, tileWidth, tileHeight);
        } else {
            
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (scrambling) {
        return;
    }
    
    if (![hintView isHidden]) {
        [UIView animateWithDuration:.5 animations:^{
            hintView.alpha = 0.0;
        }];
    }
    
    UITouch *touch = [touches anyObject];
    //CGPoint location = [touch locationInView:self];
    
    if (touch.view && [touch.view isMemberOfClass:[ImageSwapTileView class]] && selectedIndex == -1) {
        selectedIndex = (int)touch.view.tag;
        
        highlightView.frame = touch.view.frame;
        [self addSubview:highlightView];
        [highlightView setNeedsDisplay];
        [highlightView.layer addAnimation:pulseAnimation forKey:@"pulse"];
        
    } else if (touch.view && [touch.view isMemberOfClass:[ImageSwapTileView class]]) {
        if (touch.view.tag == selectedIndex) {
            selectedIndex = -1;
            [self resetHighlight];
            return;
        }
        
        ImageSwapTileView *formerView = (ImageSwapTileView *) [self viewWithTag:selectedIndex];
        ImageSwapTileView *latterView = (ImageSwapTileView *) touch.view;
        
        [self swapTile:formerView otherTile:latterView duration:0.6];
        
        selectedIndex = -1;
        moveCount++;
    }
}

- (void)swapTile:(ImageSwapTileView *)formerView otherTile:(ImageSwapTileView *)latterView duration:(float)swapDuration
{
    CGPoint formerCenter = formerView.center;
    CGPoint latterCenter = latterView.center;
    
    [UIView animateWithDuration:(0.25*swapDuration) animations:^{
        highlightView.alpha = 0.0;
        latterView.alpha = 0.0;
    }];
    [UIView animateWithDuration:(0.5*swapDuration) delay:.1 options:0 animations:^{
        formerView.center = latterCenter;
    } completion:^(BOOL finished) {
        [self resetHighlight];
        
        int formerIndex = formerView.tile.currentPosition;
        formerView.tile.currentPosition = latterView.tile.currentPosition;
        latterView.tile.currentPosition = formerIndex;
        latterView.center = formerCenter;
        
        [UIView animateWithDuration:(0.25*swapDuration) animations:^{
            latterView.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
        if (!scrambling && [puzzle isComplete]) {
            scrambleThread = arc4random();
            [self puzzleCompleted :scrambleThread];
        }
    }];
}

- (void)puzzleCompleted:(int)threadId
{
    NSLog(@"Puzzle Completed - %i Moves", moveCount);
    scrambling = YES;    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        ImageSwapTileView *tileView;
        float duration = .5;//MIN((4.0 / puzzle.tiles.count), 0.35);
        for (int i = 1; i <= puzzle.tiles.count; i++) {
            if (scrambleThread != threadId) {
                tileView = nil;
                break;
            }
            
            tileView = (ImageSwapTileView *) [self viewWithTag:i];
            int row = tileView.tile.currentPosition / puzzle.columns;
            int col = tileView.tile.currentPosition % puzzle.columns;
            float centerIndex = (puzzle.rows - 1) / 2;
            float rowMod = spacing * (centerIndex - row);
            float colMod = spacing * (centerIndex - col);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:duration animations:^{
                    CGPoint cen = tileView.center;
                    cen.x = cen.x + colMod;
                    cen.y = cen.y + rowMod;
                    tileView.center = cen;
                    //tileView.alpha = 0.0;
                }];
            });
            //[NSThread sleepForTimeInterval:((duration / 4) + .1)];
        }
        [NSThread sleepForTimeInterval:2.0];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.alpha = 0.0;
            }];
            scrambling = NO;
        });
        
        if (scrambleThread == threadId) {
            [NSThread sleepForTimeInterval:0.5];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.alpha = 0.0;
                [self.delegate puzzleComplete:moveCount];


            });
        }
    });
}

- (void)scrambleTilesWithDelay:(float)delay thread:(int)threadId
{
    scrambling = YES;    
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    
    dispatch_async(queue, ^{
        ImageSwapTileView *formerView, *latterView;
        [NSThread sleepForTimeInterval:delay];
        for (int i = 1; i <= puzzle.tiles.count; i++) {
            if (scrambleThread != threadId) {
                formerView = nil;
                latterView = nil;
                break;
            }
            
            int index = arc4random() % puzzle.tiles.count + 1;
            int randIndex;
            
            formerView = (ImageSwapTileView *) [self viewWithTag:index];
            do {
                randIndex = arc4random() % puzzle.tiles.count + 1;
            } while (randIndex == index);
            latterView = (ImageSwapTileView *) [self viewWithTag:randIndex];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self swapTile:formerView otherTile:latterView duration:MIN((4.0 / puzzle.tiles.count), 0.35)];
            });
            [NSThread sleepForTimeInterval:(MIN((4.0 / puzzle.tiles.count), 0.35) + .1)];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            scrambling = NO;
            [self.delegate scramblingComplete];
        });
    });}

- (void)resetHighlight
{
    [highlightView removeFromSuperview];
    [highlightView.layer removeAllAnimations];
    highlightView.alpha = 1.0;
}

@end
