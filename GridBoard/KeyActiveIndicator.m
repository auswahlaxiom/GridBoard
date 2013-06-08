//
//  KeyActiveIndicator.m
//  Keys
//
//  Created by Zach Fleischman on 5/14/13.
//  Copyright (c) 2013 Zach Fleischman. All rights reserved.
//

#import "KeyActiveIndicator.h"

@implementation KeyActiveIndicator


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isActive = false;
        _isFirst = false;
        _note = -1;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


-(void)setIsActive:(BOOL)isActive
{
    _isActive = isActive;
    [self setNeedsDisplay];
}


-(void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;

    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2.0);
    CGContextSetRGBStrokeColor(c, 0, 0, 0, 1);
    if(self.isFirst) {
        CGContextSetRGBFillColor(c, 0, 255, 0, 1);
    } else if(self.isActive) {
        CGContextSetRGBFillColor(c, 0, 100, 255, 1);
    } else {
        CGContextSetRGBFillColor(c, 0, 0, 0, 0);
    }
    CGRect drawingRect = CGRectInset(rect, 3, 3);
    // Draw a green solid circle
    CGContextFillEllipseInRect(c, drawingRect);
    CGContextStrokeEllipseInRect(c, drawingRect);
}


//stolen from internet, makes touches go "through" to the button below
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *subview = [super hitTest:point withEvent:event];
    if ( subview != self )
        return subview;
    else
        return nil;
}

@end
