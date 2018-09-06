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

#import "WordsearchBoard.h"
#import "WordsearchWord.h"

@implementation WordsearchBoard

static NSMutableArray *wordList;

@synthesize cells, words, complexity, rows, columns;

NSMutableArray *indices;

- (id) init
{
    return [self initWithRows:10 columns:10];
}

- (id) initWithRows:(int)rowCount columns:(int)colCount
{
    self = [super init];
    if (self != nil) {
        if (wordList == nil)
        {
            wordList = [self loadWords];
        }
        complexity = 0;
        rows = rowCount;
        columns = colCount;
        words = [[NSMutableArray alloc] init];
        cells = [[NSMutableArray alloc] initWithCapacity:(rows * columns)];
        [self generateBoard];
    }
    return self;
}

- (WordsearchWord *)wordAtStartPosition:(int)startPosition endPosition:(int)endPosition
{
    for (WordsearchWord *word in words) {
        if (word.found) {
            continue;
        }
        
        if ((word.startPosition == startPosition && word.endPosition == endPosition) || (word.endPosition == startPosition && word.startPosition == endPosition)) {
            word.found = YES;
            return word;
        }
    }
    return nil;
}

- (NSString *) description
{
    NSMutableString *line = [[NSMutableString alloc] init];
    [line appendString:@"\n"];
    for (WordsearchWord *word in words) {
        [line appendFormat:@"%@, %i\n", word.text, word.startPosition];
    }
    for (int i = 0; i < [cells count]; i++) {
        [line appendString:(NSString *)[cells objectAtIndex:i]];
        if (i % rows == rows - 1) {
            [line appendString:@"\n"];
        }
    }
    [line appendFormat:@"\nTotal Complexit: %i", complexity];
    return line;
}

- (NSMutableArray *)loadWords 
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"txt"];
    NSString *wordFile = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:NULL];
    return [[NSMutableArray alloc] initWithArray:[wordFile componentsSeparatedByString:@"\n"]];
}

- (void)generateBoard
{
    for (int i = 0; i < (rows * columns); i++) {
        [cells addObject:@" "];
    }
    [self shuffle:wordList];
    indices = [self generateRandomIndices:(rows * columns)];
    
    for (NSString *text in wordList) {
        WordsearchWord *word = [self placeWord:text];
        if (word == nil) {
            continue;
        }
        
        [words addObject:word];
        
        if (words.count == 15) {
            break;
        }
    }
}

- (WordsearchWord *)placeWord:(NSString *)text
{
    long textLength = [text length];
    if (textLength > columns && textLength > rows)
    {
        return nil;
    }
    
    int bestPosition = -1;
    WSDirection bestDirection = -1;
    int bestScore = -1;
    for (NSNumber *index in indices) {
        int row = [index intValue] / columns;
        int col = [index intValue] % columns;
        
        for (int direction = NorthEast; direction <= South; direction++) {
            int score = [self placementScoreWithWord:text direction:direction row:row column:col];
            if (score > bestScore) {
                bestScore = score;
                bestPosition = [index intValue];
                bestDirection = direction;
            }
        }
    }
    
    if (bestScore >= 0) {
        complexity += bestScore;
        WordsearchWord *word = [[WordsearchWord alloc] init];
        word.text = text;
        word.startPosition = bestPosition;
        [self placeWord:word direction:bestDirection];
        
        return word;
    }
    return nil;
}

- (void)placeWord:(WordsearchWord *)word direction:(WSDirection)direction
{
    int row = word.startPosition / columns;
    int col = word.startPosition % columns;
    for (int i = 0; i < [word.text length]; i++) {
        int position = [self getPositionWithRow:row column:col];
        
        NSString *charString = [[NSString alloc] initWithFormat:@"%c",[word.text characterAtIndex:i]];
        [cells replaceObjectAtIndex:position withObject:charString];
        
        if (i == [word.text length]-1) {
            word.endPosition = [self getPositionWithRow:row column:col];
            return;
        }
        
        if ([self isNorth:direction]) {
            row--;
        } else if ([self isSouth:direction]) {
            row++;
        }
        
        if ([self isWest:direction]) {
            col--;
        } else if ([self isEast:direction]) {
            col++;
        }
    }
}

- (int)placementScoreWithWord:(NSString *)text direction:(WSDirection)direction row:(int)row column:(int)col
{
    if ([self spaceAtRow:row column:col direction:direction] < [text length]) {
        return -1;
    }
    
    int score = 0;
    int curRow = row;
    int curCol = col;
    for (int i = 0; i < [text length]; i++) {
        unichar letter = [text characterAtIndex:i];
        unichar existingLetter = [(NSString *)[cells objectAtIndex:[self getPositionWithRow:curRow column:curCol]] characterAtIndex:0];
        if (existingLetter != 32) {
            if (existingLetter != letter) {
                return -1;
            } else {
                score++;
            }
        }
        
        if ([self isNorth:direction]) {
            curRow--;
        } else if ([self isSouth:direction]) {
            curRow++;
        }
        
        if ([self isWest:direction]) {
            curCol--;
        } else if ([self isEast:direction]) {
            curCol++;
        }
    }
    
    return score;
}

- (int)spaceAtRow:(int)row column:(int)col direction:(WSDirection)direction
{
    switch (direction) {
        case South:
            return rows - row;
        case SouthWest:
            return MIN(rows - row, col);
        case SouthEast:
            return MIN(rows - row, columns - col);
        case West:
            return col;
        case East:
            return columns - col;
        case North:
            return row;
        case NorthWest:
            return MIN(row, col);
        case NorthEast:
            return MIN(row, columns - col);
        default:
            return -1;
    }
}

- (int) getPositionWithRow:(int)row column:(int)column
{
    return (row * columns) + column;
}

- (bool) isNorth:(WSDirection)direction
{
    return (direction == NorthWest || direction == North || direction == NorthEast);
}

- (bool) isSouth:(WSDirection)direction
{
    return (direction == SouthWest || direction == South || direction == SouthEast);
}

- (bool) isEast:(WSDirection)direction
{
    return (direction == NorthEast || direction == East || direction == SouthEast);
}

- (bool) isWest:(WSDirection)direction
{
    return (direction == NorthWest || direction == West || direction == SouthWest);
}

- (NSMutableArray *) generateRandomIndices:(int)count
{
    NSMutableArray *randomIndexes = [[NSMutableArray alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++) {
        [randomIndexes addObject:[NSNumber numberWithInt:i]];
    }
    
    [self shuffle:randomIndexes];
    return randomIndexes;
}

- (void) shuffle:(NSMutableArray *)array
{  
    long count = [array count];
    for (int i = 0; i < count; i++) {
        int randInt = (arc4random() % (count - i)) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:randInt];
    }
}

- (NSString *) stringAtPosition:(int)position
{
    return (NSString *)[cells objectAtIndex:position];
}

- (NSString *) stringAtRow:(int)row column:(int)column
{
    return (NSString *)[cells objectAtIndex:(row * columns + column)];
}

@end
