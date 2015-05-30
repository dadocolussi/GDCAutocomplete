//
// Copyright (c) 2015 Dado Colussi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "GDCAutocompleteFooterView.h"


static const CGFloat cornerRadius = 8.0;


@implementation GDCAutocompleteFooterView


- (BOOL)isFlipped
{
	return YES;
}


- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	NSPoint upperLeft = NSMakePoint(0.0, 0.0);
	NSPoint upperRight = NSMakePoint(bounds.size.width, 0.0);
	NSPoint lowerLeft = NSMakePoint(0.0, bounds.size.height);
	NSPoint lowerRight = NSMakePoint(bounds.size.width, bounds.size.height);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	
	// Top line
	[path moveToPoint:upperLeft];
	[path lineToPoint:upperRight];
	
	// Right vertical line
	[path lineToPoint:NSMakePoint(lowerRight.x, lowerRight.y - cornerRadius)];
	
	// Lower right curve
	[path curveToPoint:NSMakePoint(lowerRight.x - cornerRadius, lowerRight.y) controlPoint1:lowerRight controlPoint2:lowerRight];
	
	// Bottom line
	[path lineToPoint:NSMakePoint(lowerLeft.x + cornerRadius, lowerLeft.y)];
	
	// Lower left curve
	[path curveToPoint:NSMakePoint(lowerLeft.x, lowerLeft.y - cornerRadius) controlPoint1:lowerLeft controlPoint2:lowerLeft];
	
	// Left vertical line
	[path closePath];
	
	[[NSColor clearColor] set];
	NSRectFill(bounds);
	[[NSColor colorWithWhite:0.96 alpha:1.0] set];
	[path fill];
}


@end
