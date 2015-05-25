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


#import "GDCAutocompleteWindow.h"
#import "GDCAutocomplete.h"


@implementation GDCAutocompleteWindow


#pragma mark Initialization


- (instancetype)init
{
	self = [self initWithContentRect:NSZeroRect
						   styleMask:NSBorderlessWindowMask
							 backing:NSBackingStoreBuffered
							   defer:YES];

	if (self != nil)
	{
		NSSize defaultMaxSize = NSMakeSize(300.0, 200.0);
		self.maxSize = defaultMaxSize;
		self.releasedWhenClosed = NO;
		self.hasShadow = YES;
		self.opaque = NO;
		self.movableByWindowBackground = NO;
		self.excludedFromWindowsMenu = YES;
		self.backgroundColor = [NSColor clearColor];
		[self makeFirstResponder:self.contentView];
	}
	
	return self;
}


- (BOOL)canBecomeKeyWindow
{
	return NO;
}


- (BOOL)canBecomeMainWindow
{
	return NO;
}


- (BOOL)isKeyWindow
{
	return YES;
}


@end
