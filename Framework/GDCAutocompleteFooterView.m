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


@implementation GDCAutocompleteFooterView


- (BOOL)isFlipped
{
	return YES;
}


- (void)drawRect:(NSRect)rect
{
	NSRect bounds = [self bounds];
	CGFloat cornerRadius = self.bounds.size.height;
	NSPoint lowerLeft = NSMakePoint(0.0, bounds.size.height);
	NSPoint lowerRight = NSMakePoint(bounds.size.width, bounds.size.height);
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint(bounds.size.width, bounds.size.height - cornerRadius)];
	[path curveToPoint:NSMakePoint(bounds.size.width - cornerRadius, bounds.size.height)
		 controlPoint1:lowerRight controlPoint2:lowerRight];
	[path lineToPoint:NSMakePoint(cornerRadius, bounds.size.height)];
	[path curveToPoint:NSMakePoint(0.0, bounds.size.height - cornerRadius)
		 controlPoint1:lowerLeft controlPoint2:lowerLeft];
	[path closePath];
	
	[[NSColor clearColor] set];
	NSRectFill(bounds);
	[[NSColor colorWithWhite:0.96 alpha:1.0] set];
	[path fill];
}


@end
