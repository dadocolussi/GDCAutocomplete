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


#import "GDCAutocompleteItemsView.h"
#import "GDCAutocomplete.h"


static char *ContentBindingContext = "content";


@interface GDCAutocompleteItemsView ()


@property (strong, nonatomic) NSTrackingArea *trackingArea;
@property (strong, nonatomic) NSMutableDictionary *bindingInfos;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (assign, nonatomic) NSUInteger highlightedItemIndex;
@property (strong, nonatomic) NSVisualEffectView *selectionEffectView;


- (NSCell*)preparedCellForRow:(NSUInteger)row;


@end


@implementation GDCAutocompleteItemsView


- (instancetype)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil)
	{
		self.ignoresMultiClick = YES;
		self.bindingInfos = [[NSMutableDictionary alloc] init];
		self.highlightedItemIndex = NSUIntegerMax;
		NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:@""];
		textCell.lineBreakMode = NSLineBreakByTruncatingTail;
		textCell.drawsBackground = NO;
		textCell.font = [NSFont menuFontOfSize:0];
		self.cell = textCell;
		NSRect fontRect = [textCell.font boundingRectForFont];
		self.rowHeight = ceil(fontRect.size.height + 2.0);
		self.highlightingTracksMouse = NO;
		
		NSVisualEffectView *v = [[NSVisualEffectView alloc] initWithFrame:NSZeroRect];
		v.blendingMode = NSVisualEffectBlendingModeBehindWindow;
		v.material = NSVisualEffectMaterialSelection;
		v.state = NSVisualEffectStateActive;
		v.emphasized = YES;
		self.selectionEffectView = v;
	}
	
	return self;
}


- (void)viewWillMoveToSuperview:(NSView*)newSuperview
{
	[self.selectionEffectView removeFromSuperview];
	[super viewWillMoveToSuperview:newSuperview];
    [newSuperview addSubview:self.selectionEffectView positioned:NSWindowBelow relativeTo:self];
}


- (void)setContent:(NSArray*)content
{
	_content = content;
    CGFloat h = self.content.count * self.rowHeight;

	if (self.heightConstraint == nil)
	{
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:h];
        [self.enclosingScrollView addConstraint:self.heightConstraint];
	}
    else
    {
        self.heightConstraint.constant = h;
    }
}


- (id)selectedItem
{
	if (self.highlightedItemIndex < self.content.count)
	{
		id item = self.content[self.highlightedItemIndex];
		return item;
	}
	
	return nil;
}


- (BOOL)allowsVibrancy
{
	return NO;
}


- (BOOL)isOpaque
{
	return NO;
}


- (BOOL)isFlipped
{
	return YES;
}


- (NSCell*)preparedCellForRow:(NSUInteger)row
{
	NSCell *cell = self.cell;
	cell.representedObject = [self.content objectAtIndex:row];
	cell.backgroundStyle = NSBackgroundStyleNormal;
	if (row == self.highlightedItemIndex)
	{
		cell.backgroundStyle = self.selectionEffectView.interiorBackgroundStyle;
	}
	[self.delegate itemsView:self willDisplayCell:cell atIndex:row];
	if (cell.objectValue == nil)
	{
		cell.stringValue = [cell.representedObject description];
	}
	return cell;
}


- (void)updateFieldEditor
{
	[self.delegate itemsView:self updateFieldEditorForItemAtIndex:self.highlightedItemIndex];
}


- (void)highlightIndex:(NSUInteger)i
{
	if (i == self.highlightedItemIndex)
	{
		return;
	}
	
	if (self.highlightedItemIndex < NSUIntegerMax)
	{
		[self setNeedsDisplayInRect:[self rectOfRow:self.highlightedItemIndex]];
	}
	
	self.highlightedItemIndex = i;
	
	if (self.highlightedItemIndex < NSUIntegerMax)
	{
		NSRect rect = [self rectOfRow:self.highlightedItemIndex];
		[self setNeedsDisplayInRect:rect];
		self.selectionEffectView.frame = [self convertRect:rect toView:self.superview];
	}
	else
	{
		self.selectionEffectView.frame = NSZeroRect;
	}
	
	[self updateFieldEditor];
}


- (void)clearHighlighting
{
	[self highlightIndex:NSUIntegerMax];
}


#pragma mark Mouse


- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	
	if (self.highlightingTracksMouse)
	{
		[self removeTrackingArea:self.trackingArea];
		NSTrackingAreaOptions options =
		NSTrackingMouseEnteredAndExited |
		NSTrackingMouseMoved |
		NSTrackingActiveAlways |
		NSTrackingInVisibleRect;
		self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
														 options:options
														   owner:self
														userInfo:nil];
		[self addTrackingArea:self.trackingArea];
	}
}


- (BOOL)acceptsFirstMouse:(NSEvent*)event
{
	return YES;
}


- (void)mouseExited:(NSEvent*)event
{
	if (self.highlightingTracksMouse)
	{
		[self clearHighlighting];
	}
}


- (void)mouseMoved:(NSEvent*)event
{
	if (self.highlightingTracksMouse)
	{
		NSPoint winp = [event locationInWindow];
		NSPoint viewp = [self convertPoint:winp fromView:nil];
		NSUInteger row = [self rowOfPoint:viewp];
		
		if (row != self.highlightedItemIndex)
		{
			[self highlightIndex:row];
		}
	}
}


- (void)mouseDown:(NSEvent*)event
{
	// Don't call super, because it would swallow the mouse up event.
}


- (void)mouseUp:(NSEvent*)event
{
	NSUInteger row = [self rowOfPoint:[self convertPoint:[event locationInWindow] fromView:nil]];
	
	if (row < NSUIntegerMax)
	{
		[self highlightIndex:row];
		[NSApp sendAction:self.action to:self.target from:self];
	}
	else
	{
		[super mouseUp:event];
	}
}


- (void)moveDown:(id)sender
{
	if (self.highlightedItemIndex == NSUIntegerMax)
	{
		[self highlightIndex:0];
	}
	else if (self.highlightedItemIndex + 1 >= self.content.count)
	{
		// Ignore
	}
	else
	{
		// We assume that every item can be highlighted.
		[self highlightIndex:self.highlightedItemIndex + 1];
		[self scrollRectToVisible:[self rectOfRow:self.highlightedItemIndex]];
	}
}


- (void)moveUp:(id)sender
{
	if (self.highlightedItemIndex == NSUIntegerMax)
	{
		return;
	}
	else if (self.highlightedItemIndex == 0)
	{
		[self clearHighlighting];
	}
	else
	{
		[self highlightIndex:self.highlightedItemIndex - 1];
		[self scrollRectToVisible:[self rectOfRow:self.highlightedItemIndex]];
	}
}


#pragma mark Geometry and drawing


- (NSUInteger)rowOfPoint:(NSPoint)point
{
	if (!NSPointInRect(point, self.bounds))
	{
		return NSUIntegerMax;
	}
	
	NSUInteger n = self.content.count;
	return ((CGFloat)n *  point.y / self.bounds.size.height);
}


- (NSRect)rectOfRow:(NSUInteger)row
{
	NSRect rowRect = NSMakeRect(0.0,
								row * self.rowHeight,
								self.bounds.size.width,
								self.rowHeight);
	return rowRect;
}



- (NSRect)titleRectOfRow:(NSUInteger)row
{
	NSRect fontRect = self.cell.font.boundingRectForFont;
	CGFloat h = fontRect.size.height;
	NSRect rowRect = [self rectOfRow:row];
	NSRect titleRect = NSInsetRect(rowRect, 0.0, (self.rowHeight - h) / 2.0);
	return titleRect;
}


- (void)drawRow:(NSUInteger)rowIndex clipRect:(NSRect)rowRect
{
	NSCell *cell = [self preparedCellForRow:rowIndex];
	NSAssert(cell != nil, @"Autocomplete cannot draw without a cell");
	NSRect rect = [self titleRectOfRow:rowIndex];
	[cell drawWithFrame:rect inView:self];
}


- (void)drawRect:(NSRect)rect
{
	NSUInteger n = self.content.count;
    NSRect b = NSIntersectionRect(self.frame, rect);
	if (n == 0)
	{
		// Nothing to display, draw transparent.
		[[NSColor clearColor] setFill];
		NSRectFill(b);
	}
	else
	{
		for (NSUInteger row = 0; row < n; row++)
		{
			NSRect rowRect = [self rectOfRow:row];
			
			if (NSIntersectsRect(rowRect, rect))
			{
				[self drawRow:row clipRect:rowRect];
			}
		}
	}
}


#pragma mark Bindings and KVO


- (NSDictionary*)infoForBinding:(NSString *)binding
{
	NSDictionary *info = [self.bindingInfos objectForKey:binding];
	
	if (info == nil)
	{
		info = [super infoForBinding:binding];
	}
	
	return info;
}


- (void)bind:(NSString*)binding toObject:(id)observable withKeyPath:(NSString*)keyPath options:(NSDictionary*)options
{
	if ([binding isEqualToString:@"content"])
	{
		if ([self infoForBinding:binding] != nil)
		{
			[self unbind:@"binding"];
		}
		
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  observable, NSObservedObjectKey,
							  keyPath, NSObservedKeyPathKey,
							  options, NSOptionsKey,
							  nil];
		[self.bindingInfos setObject:info forKey:binding];
		[observable addObserver:self
					 forKeyPath:keyPath
						options:NSKeyValueObservingOptionInitial
						context:ContentBindingContext];
	}
	else
	{
		[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	}
}


- (void)unbind:(NSString*)binding
{
	if ([binding isEqualToString:@"content"])
	{
		NSDictionary *info = [self infoForBinding:binding];
		NSAssert(info != nil, @"Binding not found: content");
		id observable = [info objectForKey:NSObservedObjectKey];
		id keyPath = [info objectForKey:NSObservedKeyPathKey];
		[observable removeObserver:self forKeyPath:keyPath context:ContentBindingContext];
	}
	else
	{
		[super unbind:binding];
	}
}


- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context
{
	if (context == ContentBindingContext)
	{
		NSString *binding = [NSString stringWithCString:ContentBindingContext encoding:NSASCIIStringEncoding];
		NSDictionary *info = [self infoForBinding:binding];
		NSDictionary *options = [info objectForKey:NSOptionsKey];
		id value = [object valueForKeyPath:keyPath];
		
		if (value == nil || value == [NSNull null])
		{
			self.content = [options objectForKey:NSNullPlaceholderBindingOption];
		}
		else if (value == NSNotApplicableMarker)
		{
			self.content = [options objectForKey:NSNotApplicablePlaceholderBindingOption];
		}
		else if (value == NSNoSelectionMarker)
		{
			self.content = [options objectForKey:NSNoSelectionPlaceholderBindingOption];
		}
		else if (value == NSMultipleValuesMarker)
		{
			self.content = [options objectForKey:NSMultipleValuesPlaceholderBindingOption];
		}
		
		if ([value isKindOfClass:[NSArray class]])
		{
			self.content = value;
		}
		else
		{
			value = nil;
		}
		
		self.needsLayout = YES;
		self.needsDisplay = YES;
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


@end

