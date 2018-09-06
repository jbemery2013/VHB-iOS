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

#import "SudokuBoardView.h"
#import "DefaultsWrapper.h"

@interface SudokuBoardView () {
    UIColor *noteColor, *lockedSelectionColor, *lockColor, *markColor, *selectedMarkColor, *selectedNoteHighlightColor, *highlightColor, *lockedHighlightColor, *selectionColor, *rowColColor, *debugColor, *gridColor, *verifyBackgroundColor, *lockBackgroundColor;
    NSArray *accessibilityObjects;
    SudokuCell *currentCell;
    CGRect currentCellRect;
}

@end

@implementation SudokuBoardView

@synthesize board = _board;
@synthesize cellRects;
@synthesize selectedCellIndex, highlightValue;
@synthesize highlightEnabled, verifyEnabled;
@synthesize valueFont, noteFont;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValues:NO];
    }
    return self;
}

- (id)initForScreenshot:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValues:YES];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initValues:NO];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initValues:NO];
    }
    return self;
}

- (void)setBoard:(SudokuBoard *)obj
{
    _board = obj;
    selectedCellIndex = -1;
    highlightValue = -1;
}

- (void) initValues:(BOOL)forScreenshot
{
    
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.backgroundColor = [UIColor blackColor];
    highlightEnabled = decryptBoolForKey(@"highlight");
    selectedNoteHighlightColor = [UIColor colorWithRed:1 green:0.325 blue:0.051 alpha:1.0];
    debugColor = [UIColor colorWithWhite:0 alpha:0.06];
    gridColor = [UIColor colorWithWhite:0.0 alpha:1];
    lockColor = [UIColor colorWithWhite:0.2 alpha:1];
    noteColor = [UIColor blackColor];
    selectedMarkColor = [UIColor blackColor];
    markColor = [UIColor blackColor];
    highlightColor = [UIColor colorWithRed:1 green:0.325 blue:0.051 alpha:1.0];
    lockedHighlightColor = [UIColor colorWithRed:1 green:0.325 blue:0.051 alpha:1];
    lockedSelectionColor = [UIColor colorWithWhite:0.75 alpha:1];
    rowColColor = [UIColor colorWithRed:0.784 green:0.855 blue:0.902 alpha:1.0];
    selectionColor = [UIColor whiteColor];
    verifyBackgroundColor = [UIColor colorWithRed:0.722 green:0.412 blue:0.412 alpha:1.0];
    lockBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.085];
    selectedCellIndex = -1;
    highlightValue = -1;
    
    if (!forScreenshot) {
        NSMutableArray *aObjs = [[NSMutableArray alloc] initWithCapacity:81];
        
        for (int i = 0; i < 81; i++) {
            [aObjs insertObject:[[UIAccessibilityElement alloc] initWithAccessibilityContainer:self] atIndex:i];
        }
        accessibilityObjects = [[NSArray alloc] initWithArray:aObjs];
    }
}

-(SudokuCell *)getSelectedCell
{
    if (selectedCellIndex == -1) {
        return nil;
    }
    
    return [_board.cells objectAtIndex:selectedCellIndex];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //for (SudokuCell *cell in _board.cells) {
    //}
    
    if (cellRects == nil || [cellRects count] == 0) {
        [self evaluateCells];
    }
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, CGRectInset(rect, 7, 7));
    
    [self drawSelectionRowAndColumnHinting:context];
    
    for (int i = 0; i < 81; i++) {
        currentCell = [_board.cells objectAtIndex:i];
        
        if (currentCell.locked) {
            [lockBackgroundColor setFill];
            currentCellRect = [[cellRects objectForKey:[NSNumber numberWithInt:i]] CGRectValue];
            CGContextFillRect(context, currentCellRect);
        }
    }
    
    [self drawCellSelection:context];
    
    if (verifyEnabled) {
        for (int i = 0; i < 81; i++) {
            currentCell = [_board.cells objectAtIndex:i];
            if (!currentCell.locked && currentCell.marks.count == 1 && ![currentCell isCorrect]) {
                [verifyBackgroundColor setFill];
                currentCellRect = [[cellRects objectForKey:[NSNumber numberWithInt:i]] CGRectValue];
                CGContextFillRect(context, currentCellRect);
            }
        }
    }
    
    [self drawText:rect];
    
    [self drawGrid:rect context:context];
}

-(void)drawCellSelection:(CGContextRef)context
{
    if (selectedCellIndex >= 0) {
        NSValue *val = [cellRects objectForKey:[NSNumber numberWithInt:selectedCellIndex]];
        CGRect rect = [val CGRectValue];
        
        if ([self getSelectedCell].locked) {
            [lockedSelectionColor set];
        } else {
            [selectionColor set];
        }
        CGContextFillRect(context, rect);
    }
}

-(void)drawSelectionRowAndColumnHinting:(CGContextRef)context
{
    if (selectedCellIndex >= 0) {
        NSValue *val = [cellRects objectForKey:[NSNumber numberWithInt:selectedCellIndex]];
        CGRect rect = [val CGRectValue];
        [rowColColor setFill];
        
        CGContextFillRect(context, CGRectMake(7, rect.origin.y, self.bounds.size.width - 14, rect.size.height));
        CGContextFillRect(context, CGRectMake(rect.origin.x, 7, rect.size.width, self.bounds.size.height - 14));
    }
}

-(void)drawText:(CGRect)rect
{
    for (int i = 0; i < 81; i++) {
        SudokuCell *cell = [_board.cells objectAtIndex:i];
        NSValue *val = [cellRects objectForKey:[NSNumber numberWithInt:i]];
        CGRect cellRect = [val CGRectValue];
        CGRect shiftedCellRect = CGRectOffset(cellRect, 0, cellRect.size.height / 9);
        NSString *solution = [NSString stringWithFormat:@"%i", cell.solution.intValue];
        
        BOOL selected = i == selectedCellIndex;
        
        if (cell.locked) {
            if (highlightEnabled && cell.solution.intValue == highlightValue) {
                [lockedHighlightColor set];
            } else {
                [lockColor set];
            }
            [solution drawInRect:shiftedCellRect withFont:valueFont lineBreakMode:NSLineBreakByTruncatingTail  alignment:NSTextAlignmentCenter];
        } else {
            /*#ifdef DEBUG
             [debugColor set];
             [solution drawInRect:shiftedCellRect withFont:valueFont lineBreakMode:UILineBreakModeTailTruncation  alignment:UITextAlignmentCenter];
             #endif*/
            
            if ([cell.marks count] >= 1) {
                if ([cell.marks count] == 1) {
                    NSString *mark = [NSString stringWithFormat:@"%@", [cell.marks anyObject]];
                    if (selected) {
                        [selectedMarkColor set];
                    } else {
                        if (highlightEnabled && ((NSNumber *)[cell.marks anyObject]).intValue == highlightValue) {
                            [highlightColor set];
                        } else {
                            [markColor set];
                        }
                    }
                    
                    [mark drawInRect:shiftedCellRect withFont:valueFont lineBreakMode:NSLineBreakByTruncatingTail  alignment:NSTextAlignmentCenter];
                } else {
                    float subCellHeight = cellRect.size.height / 3.0;
                    float subCellWidth = cellRect.size.width / 3.0;
                    float leftTx = 0;
                    float topTx = 0;
                    
                    for (int j = 0; j < 9; j++) {
                        NSNumber *number = [NSNumber numberWithInt:j+1];
                        
                        if (j % 3 == 0 && j != 0) {
                            leftTx = 0;
                            topTx += subCellHeight - 1;
                        }
                        
                        if (highlightEnabled && number.intValue == highlightValue) {
                            if (selected) {
                                [selectedNoteHighlightColor set];
                            } else {
                                [highlightColor set];
                            }
                            
                        } else {
                            [noteColor set];
                        }
                        
                        if ([cell.marks containsObject:number]) {
                            [[NSString stringWithFormat:@"%@", number] drawInRect:CGRectMake(cellRect.origin.x + leftTx, cellRect.origin.y + topTx - 1, subCellWidth, subCellHeight) withFont:noteFont lineBreakMode:NSLineBreakByTruncatingTail  alignment:NSTextAlignmentCenter];
                        }
                        
                        leftTx += subCellWidth;
                    }
                }
            }
        }
    }
}

-(void)layoutSubviews
{
    [self evaluateCells];
}

-(void)evaluateCells
{
    if (cellRects == nil) {
        cellRects = [[NSMutableDictionary alloc] init];
        
    }
    
    [cellRects removeAllObjects];
    
    int width = [self bounds].size.width;
    int height = [self bounds].size.height;
    
    float cellWidth = (width - 28) / 9.0;
    float cellHeight = (height - 28) / 9.0;
    
    valueFont = [UIFont fontWithName:@"Helvetica-Bold" size:((height - 28) / (14))];
    noteFont = nil;
    
    float topTx = 7;
    float leftTx = 7;
    for (int i = 0; i < 81; i++) {
        if (i % 9 == 0) {
            leftTx = 7;
            topTx += 1;
            if (i != 0) {
                topTx += cellHeight;
            }
        }
        
        if (i % 27 == 0) {
            topTx += 2;
        }
        
        if (i % 3 == 0) {
            leftTx += 3;
        } else {
            leftTx += 1;
        }
        
        CGRect cellRect = CGRectMake(leftTx, topTx, cellWidth, cellHeight);
        int row = i / 9;
        int col = i % 9;
        int leftShift = (col % 3 == 0) ? -2 : -1;
        int topShift = (row % 3 == 0) ? -3 : -1;
        int widthShift = (col % 3 == 0) ? 2 : 1;
        int heightShift = (row % 3 == 0) ? 3 : 1;
        cellRect.origin.x = cellRect.origin.x + leftShift;
        cellRect.origin.y = cellRect.origin.y + topShift;
        cellRect.size.height = cellRect.size.height + heightShift;
        cellRect.size.width = cellRect.size.width + widthShift;
        
        if (noteFont == nil) {
            noteFont = [UIFont fontWithName:@"Helvetica-Bold" size:(cellRect.size.height) / 3];
        }
        
        [cellRects setObject:[NSValue valueWithCGRect:cellRect] forKey:[NSNumber numberWithInt:i]];
        UIAccessibilityElement *elem = (UIAccessibilityElement *)[accessibilityObjects objectAtIndex:i];
        CGRect aRect = cellRect;
        aRect = CGRectOffset(aRect, -5, 59);
        elem.accessibilityFrame = aRect;
        
        leftTx += cellWidth;
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    verifyEnabled = NO;
    
    if (_board.puzzle.complete.boolValue) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    
    for (int i = 0; i < 81; i++) {
        NSValue *val = [cellRects objectForKey:[NSNumber numberWithInt:i]];
        SudokuCell *cell = [_board.cells objectAtIndex:i];
        if (cell.locked) {
            continue;
        }
        
        if (CGRectContainsPoint([val CGRectValue], location)) {
            selectedCellIndex = i;
            [self setNeedsDisplay];
            return;
        }
    }
    
    // highlightValue = -1;
    selectedCellIndex = -1;
    [self setNeedsDisplay];
}

- (void)drawGrid:(CGRect)rect context:(CGContextRef)context
{
    int width = rect.size.width;
    int height = rect.size.height;
    float cellWidth = (width - 28) / 9.0;
    float cellHeight = (height - 28) / 9.0;
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, gridColor.CGColor);
    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapSquare);
    
    float leftTx = 7;
    float topTx = 7;
    
    for (int i = 0; i <= 9; i++) {
        if (i % 3 == 0) {
            CGContextSetLineWidth(context, 3);
            CGContextMoveToPoint(context, leftTx, 7);
            CGContextAddLineToPoint(context, leftTx, height - 7);
            CGContextStrokePath(context);
            
            CGContextMoveToPoint(context, 7, topTx);
            CGContextAddLineToPoint(context, width - 7, topTx);
            CGContextStrokePath(context);
            
            leftTx += cellWidth + 3;
            topTx += cellHeight + 3;
            continue;
        }
        
        CGContextSetLineWidth(context, 1);
        
        CGContextMoveToPoint(context, leftTx, 7);
        CGContextAddLineToPoint(context, leftTx, height - 7);
        CGContextStrokePath(context);
        
        CGContextMoveToPoint(context, 7, topTx);
        CGContextAddLineToPoint(context, width - 7, topTx);
        CGContextStrokePath(context);
        
        leftTx += cellWidth + 1;
        topTx += cellHeight + 1;
    }
}


- (UIImage*)getScreenshot
{
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return ret;
    
}

- (NSInteger)accessibilityElementCount
{
    return accessibilityObjects.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    UIAccessibilityElement *elem = [accessibilityObjects objectAtIndex:index];
    SudokuCell *cell = [_board.cells objectAtIndex:index];
    
    NSString *marks = @"";
    int count = 0;
    for (NSNumber *number in cell.marks) {
        if (count > 0) {
            marks = [marks stringByAppendingString:@", "];
        }
        marks = [marks stringByAppendingString:[number stringValue]];
        count++;
    }
    
    if (cell.locked) {
        marks = [cell.solution stringValue];
    }
    
    NSString *selected = @"";
    if ([self getSelectedCell] == cell) {
        selected = @"Selected";
    }
    
    long row = (index / 9) + 1;
    int col = (index % 9) + 1;
    
    if (cell.locked) {
        elem.accessibilityLabel = [NSString stringWithFormat:@"Row %li, Column %i: %@, Locked, %@", row, col, marks, selected];
    } else {
        elem.accessibilityLabel = [NSString stringWithFormat:@"Row %li, Column %i: %@, Unlocked, %@", row, col, marks, selected];
        elem.accessibilityHint = @"Double tap to select.";
    }
    
    if (verifyEnabled && !cell.isCorrect) {
        elem.accessibilityLabel = [NSString stringWithFormat:@"%@, Incorrect", elem.accessibilityLabel];
    }
    
    return elem;
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [accessibilityObjects indexOfObject:element];
}

- (BOOL)isAccessibilityElement
{
    return NO;
}

@end
