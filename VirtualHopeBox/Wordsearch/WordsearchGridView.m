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

#import "WordsearchWord.h"
#import "WordsearchGridView.h"

@interface WordsearchGridView () {
    WordsearchBoard *board;
    int selectionStart, selectionEnd, sizeMod;
    float cellWidth, cellHeight, unscaledCellWidth, unscaledCellHeight, touchStartX, touchStartY;
    NSMutableArray *accessibilityElements;
    UIColor *selectionColor, *foundColor;
    CGLayerRef textLayer, selectionLayer;
    CGRect prevRect;
}

@end

@implementation WordsearchGridView

@synthesize delegate;

- (void)setBoard:(WordsearchBoard *)obj
{
    selectionColor = [UIColor colorWithRed:0.0 green:0.3 blue:.8 alpha:1];
    foundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    selectionStart = -1;
    selectionEnd = -1;
    sizeMod = 8;
    board = obj;
    textLayer = nil;
    selectionLayer = nil;
    
    if (!accessibilityElements) {
        accessibilityElements = [[NSMutableArray alloc] init];
        UIAccessibilityElement *elem;
        for (int row = 0; row < board.rows; row++) {
            for (int col = 0; col < board.columns; col++) {
                elem = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
                elem.accessibilityHint = @"Double tap and drag to select a horizontal, vertical or diagonal line";
                [accessibilityElements addObject:elem];
            }
        }
    }
    
    UIAccessibilityElement *elem;
    for (int row = 0; row < board.rows; row++) {
        for (int col = 0; col < board.columns; col++) {
            elem = [accessibilityElements objectAtIndex:(row * board.columns + col)];
            elem.accessibilityLabel = [NSString stringWithFormat:@"%@,", [board stringAtRow:row column:col]];
        }
    }
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)dealloc
{
    delegate = nil;
    CGLayerRelease(textLayer);
    CGLayerRelease(selectionLayer);
}

- (WordsearchBoard *)getBoard 
{
    return board;
}

- (void)layoutSubviews
{
    float width = self.bounds.size.width * self.contentScaleFactor;
    float height = self.bounds.size.height * self.contentScaleFactor;
    cellWidth = width / board.columns;
    cellHeight = height / board.rows;
    unscaledCellWidth = self.bounds.size.width / board.columns;
    unscaledCellHeight = self.bounds.size.height / board.rows;
    textLayer = nil;
    prevRect = CGRectNull;
    
    UIAccessibilityElement *elem;
    CGRect cell;

    for (int row = 0; row < board.rows; row++) {
        for (int col = 0; col < board.columns; col++) {
            cell = CGRectMake(col * unscaledCellWidth, row * unscaledCellHeight, unscaledCellWidth, unscaledCellHeight);
            cell = [self.superview convertRect:cell toView:nil];
            elem = [accessibilityElements objectAtIndex:(row * board.columns + col)];
            elem.accessibilityFrame = cell;
            
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawSelection:context start:selectionStart end:selectionEnd color:selectionColor scaled:NO];
    
    float scale = self.contentScaleFactor;
    CGRect scaledBounds = CGRectMake(0, 0, self.bounds.size.width * scale, self.bounds.size.height * scale);
    
    if (!selectionLayer) {
        selectionLayer = CGLayerCreateWithContext(context, scaledBounds.size, NULL);
        CGContextRef layerContext = CGLayerGetContext(selectionLayer);
        UIGraphicsPushContext(layerContext);
        
//         #ifdef DEBUG
//         for (WordsearchWord *word in board.words) {
//             [self drawSelection:layerContext start:word.startPosition end:word.endPosition color:[UIColor colorWithRed:1.0 green:0.4 blue:1 alpha:0.15] scaled:YES];
//         }
//         #endif
        
        for (WordsearchWord *word in board.words) {
            if (!word.found) {
                continue;
            }
            [self drawSelection:layerContext start:word.startPosition end:word.endPosition color:foundColor scaled:YES];
        }
        
        UIGraphicsPopContext();
    }
    
    if (!textLayer) {
        textLayer = CGLayerCreateWithContext(context, scaledBounds.size, NULL);
        CGContextRef layerContext = CGLayerGetContext(textLayer);
        UIGraphicsPushContext(layerContext);
        
        
        int textTopMargin = self.bounds.size.height * (0.015 * scale);
        
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:(scaledBounds.size.height / (board.rows + sizeMod))];
        [[UIColor colorWithWhite:0.9 alpha:1] set];
        for (int row = 0; row < board.rows; row++) {
            for (int col = 0; col < board.columns; col++) {
                NSString *text = [board stringAtRow:row column:col];
                [text drawInRect:CGRectMake(col * cellWidth, row * cellHeight + textTopMargin, cellWidth, cellHeight + textTopMargin) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];

            }
        }
        UIGraphicsPopContext();
    }
    
    CGContextDrawLayerInRect(context, self.bounds, selectionLayer);
    CGContextDrawLayerInRect(context, self.bounds, textLayer);
    
}

- (void) drawSelection:(CGContextRef)context start:(int)start end:(int)end color:(UIColor *)color scaled:(BOOL)applyScale
{
    if (start < 0 || end < 0 || start == end) {
        return;
    }
    
    float width = applyScale ? cellWidth : unscaledCellWidth;
    float height = applyScale ? cellHeight : unscaledCellHeight;
    
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    int topMargin = -(height * .03);
    CGContextSetLineWidth(context, height * 0.65);
    
    int startRow = start / board.columns;
    int startCol = start % board.columns;
    int endRow = end / board.columns;
    int endCol = end % board.columns;
    float halfWidth = width / 2;
    float halfHeight = height / 2;
    
    CGContextMoveToPoint(context, startCol * width + halfWidth, startRow * height + halfHeight + topMargin);
    CGContextAddLineToPoint(context, endCol * width + halfWidth, endRow * height + halfHeight + topMargin);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGRect bounds = [self bounds];
    
    touchStartX = location.x;
    touchStartY = location.y;
    
    int row = board.rows * location.y / bounds.size.height;
    int col = board.columns * location.x / bounds.size.width;
    
    selectionStart = row * board.columns + col;
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Selection Started: %@", [board stringAtPosition:selectionStart]]);
    
    //NSLog(@"Start %i, %i", row, col);
}

#define RADIAN_SNAP 0.785398f

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    CGRect bounds = [self bounds];
    
    float deltaX = touchStartX - location.x;
    float deltaY = touchStartY - location.y;
    float radians = atan2(deltaY, deltaX);
    float distance = hypotf(deltaX, deltaY);
    float vertStep = (bounds.size.height / board.rows);
    float horiStep = (bounds.size.width / board.columns);
    float diagStep = hypotf(horiStep, vertStep);
    
    float stepDist = 0;
    int startRow = selectionStart / board.columns;
    int startCol = selectionStart % board.columns;
    int endCol = startCol;
    int endRow = startRow;
    int steps = 0;
    int colShift = 0;
    int rowShift = 0;
    
    if (radians <= (.5 * RADIAN_SNAP) && radians >= -(.5 * RADIAN_SNAP)) {
//        NSLog(@"Left");
        stepDist = horiStep;
        colShift = -1;
    } else if (radians > (.5 * RADIAN_SNAP) && radians < (1.5 * RADIAN_SNAP)) {
//        NSLog(@"Up Left");
        stepDist = diagStep;
        colShift = -1;
        rowShift = -1;
    } else if (radians >= (1.5 * RADIAN_SNAP) && radians <= (2.5 * RADIAN_SNAP)) {
//        NSLog(@"Up");
        stepDist = vertStep;
        rowShift = -1;
    } else if (radians > (2.5 * RADIAN_SNAP) && radians < (3.5 * RADIAN_SNAP)) {
//        NSLog(@"Up Right");
        stepDist = diagStep;
        colShift = 1;
        rowShift = -1;
    } else if (radians >= (3.5 * RADIAN_SNAP) || radians <= -(3.5 * RADIAN_SNAP)) {
//        NSLog(@"Right");
        stepDist = horiStep;
        colShift = 1;
    } else if (radians < -(2.5 * RADIAN_SNAP) && radians > -(3.5 * RADIAN_SNAP)) {
//        NSLog(@"Down Right");
        stepDist = diagStep;
        colShift = 1;
        rowShift = 1;
    } else if (radians <= -(1.5 * RADIAN_SNAP) && radians >= -(2.5 * RADIAN_SNAP)) {
//        NSLog(@"Down");
        stepDist = vertStep;
        rowShift = 1;
    } else {
//        NSLog(@"Down Left");
        stepDist = diagStep;
        colShift = -1;
        rowShift = 1;
    }
    
    steps = floor((distance + (.5 * stepDist)) / stepDist);
//    NSLog(@"Steps %d", steps);
    
    if (colShift != 0 && rowShift != 0) {
        endCol = MAX(MIN(colShift * steps + startCol, board.columns - 1), 0);
        endRow = MAX(MIN(rowShift * steps + startRow, board.rows - 1), 0);
        int colStepDelta = abs(startCol - endCol);
        int rowStepDelta = abs(startRow - endRow);
//        NSLog(@"colStepDel %d, rowStepDel %d", colStepDelta, rowStepDelta);
        int stepDelta = MIN(colStepDelta, rowStepDelta);
        endCol = MAX(MIN(colShift * stepDelta + startCol, board.columns - 1), 0);
        endRow = MAX(MIN(rowShift * stepDelta + startRow, board.rows - 1), 0);
    } else if (colShift != 0) {
        endCol = MAX(MIN(colShift * steps + startCol, board.columns - 1), 0);
    } else if (rowShift != 0) {
        endRow = MAX(MIN(rowShift * steps + startRow, board.rows - 1), 0);
    }
    
//    NSLog(@"selecEnd: %d, selecStart: %d", selectionEnd, selectionStart);
    
    int endIndex = endRow * board.columns + endCol;
    
    if (endIndex == selectionEnd || endIndex == selectionStart) {
        return;
    }
    
    int tRow, tCol, pos;
    NSString *notice = [board stringAtPosition:selectionStart];
    for (int i = 1; i <= steps; i++) {
        tRow = startRow + (i * rowShift);
        tCol = startCol + (i * colShift);
        pos = (tRow * board.columns) + tCol;
        notice = [NSString stringWithFormat:@"%@, %@", notice, [board stringAtPosition:pos]];
    }
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, notice);
    
    selectionEnd = endIndex;
    
    int minRow = MIN(startRow, endRow);
    int minCol = MIN(startCol, endCol);
    int maxRow = MAX(startRow, endRow);
    int maxCol = MAX(startCol, endCol);
    
//    NSLog(@"SRow: %d, ERow: %d, SCol: %d, ECol: %d", startRow, endRow, startCol, endCol);
    
    CGRect touchRect = CGRectMake((minCol - 2) * unscaledCellWidth, (minRow - 2) * unscaledCellHeight, (maxCol + 2 - minCol) * unscaledCellWidth, (maxRow + 2 - minRow) * unscaledCellHeight);
    CGRect redrawRect = touchRect;
    if (!CGRectIsNull(prevRect)) {
        redrawRect = CGRectUnion(touchRect, prevRect);
    }
    
    NSLog(@"redrect %@", NSStringFromCGRect(redrawRect));
    
    prevRect = touchRect;
    [self setNeedsDisplay];
}

- (void) addSelection:(WordsearchWord *)word
{
    CGContextRef layerContext = CGLayerGetContext(selectionLayer);
    [self drawSelection:layerContext start:word.startPosition end:word.endPosition color:foundColor scaled:YES];
}

/*
 * Update the accessibility label for each cell of a found word to
 * reflect that the cell is part of an existing find
 */
- (void)updateWordAccessibility:(WordsearchWord *)word
{
    int rowShift = 0;
    int colShift = 0;

    int startRow = word.startPosition / board.columns;
    int startCol = word.startPosition % board.columns;
    int endRow = word.endPosition / board.columns;
    int endCol = word.endPosition % board.columns;
    
    if (startRow > endRow) {
        rowShift = -1;
    } else if (startRow < endRow) {
        rowShift = 1;
    }
    
    if (startCol > endCol) {
        colShift = -1;
    } else if (startCol < endCol) {
        colShift = 1;
    }
    
    int row, col, pos;
    UIAccessibilityElement *elem;
    for (int i = 0; i < word.text.length; i++) {
        row = startRow + (i * rowShift);
        col = startCol + (i * colShift);
        pos = (row * board.columns) + col;
        elem = [accessibilityElements objectAtIndex:pos];
        elem.accessibilityLabel = [NSString stringWithFormat:@"%@, Part of word %@", elem.accessibilityLabel, word.text];
    }

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    prevRect = CGRectNull;
    
    WordsearchWord *word = [board wordAtStartPosition:selectionStart endPosition:selectionEnd];
    if (word != nil) {
        NSLog(@"Word Found: %@", word.text);
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"Selection Ended. Word Found: %@", word.text]);
        
        [self updateWordAccessibility:word];
        
        [delegate wordFound:word];
        [self addSelection:word];
        
        BOOL complete = TRUE;
        for (WordsearchWord *tempWord in board.words) {
            if (tempWord.found) {
                continue;
            }
            
            complete = FALSE;
            break;
        }
        
        if (complete) {
            [delegate puzzleCompleted];
        }
    } else {
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, @"Selection Ended. No word found");
    }
    
    [self setNeedsDisplay];
    
    selectionStart = -1;
    selectionEnd = -1;
}

- (BOOL)isAccessibilityElement
{
    return NO;
}

- (NSInteger)accessibilityElementCount
{
    return accessibilityElements.count;
}

- (NSInteger)indexOfAccessibilityElement:(id)element
{
    return [accessibilityElements indexOfObject:element];
}

- (id)accessibilityElementAtIndex:(NSInteger)index
{
    return [accessibilityElements objectAtIndex:index];
}

@end
