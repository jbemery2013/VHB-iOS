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

#import "MahjongTileSlotView.h"

@interface MahjongTileSlotView() {

}
@end

@implementation MahjongTileSlotView

@synthesize tileSlot, selected, highlighted, highlightColor, selectionColor, tileImage;

- (void)dealloc
{
    highlightColor = nil;
    selectionColor = nil;
    tileImage = nil;
    tileSlot = nil;
}

- (id)initWithTileSlot:(MahjongTileSlot *)slot
{
    self = [super init];
    if (self) {
        tileSlot = slot;
        highlightColor = [UIColor colorWithRed:0.4 green:.8 blue:0.6 alpha:0.3];
        selectionColor = [UIColor colorWithRed:0.3 green:0.7 blue:1.0 alpha:0.3];
        self.backgroundColor = [UIColor clearColor];
        
        [self loadImage];
    }
    return self;
}

- (void)loadImage
{
    NSString *file = [NSString stringWithFormat:@"%i", [tileSlot.tile imageId]];
    tileImage = [UIImage imageNamed:file];
}

- (void)drawRect:(CGRect)rect
{
    if (!tileSlot.tile.visible) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    [tileImage drawInRect:[self bounds]];
    //CGContextDrawImage(context, [self bounds], tileImage.CGImage)
    if (selected || highlighted) {
        [highlightColor setFill];
        if (selected) {
            [selectionColor setFill];
        }
        
        UIRectFillUsingBlendMode([self bounds], kCGBlendModeSourceAtop);
    }
    CGContextRestoreGState(context);
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityHint
{
    return @"Double tap to select.";
}

- (NSString *)accessibilityLabel
{
    return selected ? [NSString stringWithFormat:@"%@, Selected", self.tileSlot.tile.name] : self.tileSlot.tile.name;
}

@end
