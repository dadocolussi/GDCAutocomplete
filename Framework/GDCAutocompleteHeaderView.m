//
// Copyright (c) 2015-2019 Dado Colussi
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


#import "GDCAutocompleteHeaderView.h"


static const CGFloat cornerRadius = 8.0;


@implementation GDCAutocompleteHeaderView


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
	
	// Upper left curve
	[path moveToPoint:NSMakePoint(upperLeft.x, upperLeft.y + cornerRadius)];
	[path curveToPoint:NSMakePoint(cornerRadius, 0.0) controlPoint1:upperLeft controlPoint2:upperLeft];
	
	// Top line
	[path lineToPoint:NSMakePoint(upperRight.x - cornerRadius, upperRight.y)];
	
	// Top right curve
	[path curveToPoint:NSMakePoint(upperRight.x, upperRight.y + cornerRadius) controlPoint1:upperRight controlPoint2:upperRight];
	
	// Right vertical line
	[path lineToPoint:lowerRight];
	
	// Bottom line
	[path lineToPoint:lowerLeft];
	
	// Left vertical line
	[path closePath];
	
	[[NSColor clearColor] set];
	NSRectFill(bounds);
	[[NSColor colorWithWhite:0.96 alpha:1.0] set];
	[path fill];
}


@end
