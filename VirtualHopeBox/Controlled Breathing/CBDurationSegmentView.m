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

#import "CBDurationSegmentView.h"

@implementation CBDurationSegmentView

@synthesize lineColor;
@synthesize duration = _duration;
@synthesize segmentDuration = _segmentDuration;
@synthesize lineMargin;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initDuration:(float)duration
{
    _duration = duration;
    _segmentDuration = 1.0;
    [self setNeedsDisplay];
}

- (void)setDuration:(float)duration
{
    _duration = duration;
    [self setNeedsDisplay];
}

- (float)getDuration
{
    return _duration;
}

- (void)setSegmentDuration:(float)segmentDuration
{
    _segmentDuration = segmentDuration;
    [self setNeedsDisplay];
}

- (float)getSegmentDuration
{
    return _segmentDuration;
}

- (void)drawRect:(CGRect)rect
{
    if (_duration == 0 || _segmentDuration == 0) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineWidth(context, 2.0);
    [lineColor set];
    float segments = _duration / _segmentDuration;
    float segmentHeight = self.frame.size.height / segments;
    
    if (segments < floor(segments) + 0.1) {
        segments--;
    }
    
    for (int i = 1; i <= floor(segments); i++) {
        float top = self.frame.size.height - (segmentHeight * i);
        
        CGContextMoveToPoint(context, lineMargin, top);
        CGContextAddLineToPoint(context, (self.bounds.size.width / 2.0) - 10, top);
        
        [[NSString stringWithFormat:@"%i", i] drawInRect:CGRectMake((self.bounds.size.width / 2.0) - 4, top-10, 30, 30) withFont:[UIFont systemFontOfSize:15]];
        
        CGContextMoveToPoint(context, (self.bounds.size.width / 2.0) + 10, top);
        CGContextAddLineToPoint(context, self.bounds.size.width - lineMargin, top);
    }
    
    //
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end
