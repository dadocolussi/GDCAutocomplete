//
// Copyright (c) 2015-2016 Dado Colussi
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


#import "GDCAutocomplete.h"
#import "GDCAutocompleteWindow.h"
#import "GDCAutocompleteItemsView.h"
#import "GDCAutocompleteDelegate.h"
#import "GDCAutocompleteHeaderView.h"
#import "GDCAutocompleteFooterView.h"
#import "GDCAutocompleteFieldEditorDelegateInterceptor.h"


static const CGFloat SpacingBetweenControlAndWindow = 8.0;
static char *AttachedControlEnabledContext = "enabled";
static char *AttachedControlHiddenContext = "hidden";
static char *FieldEditorDelegateContext = "delegate";
static char *AttachedControlWindowContext = "window";


@interface NSView (Contains)
- (BOOL)containsSubview:(NSView*)view;
@end

@implementation NSView (Contains)
- (BOOL)containsSubview:(NSView*)view
{
	for (NSView *v in self.subviews)
	{
		if (v == view)
		{
			return YES;
		}
		
		if ([v containsSubview:view])
		{
			return YES;
		}
	}
	
	return NO;
}
@end


@interface GDCAutocomplete () <NSTextViewDelegate, GDCAutocompleteItemsViewDelegate>


@property (strong, nonatomic) GDCAutocompleteFieldEditorDelegateInterceptor *interceptor;
@property (strong, nonatomic) NSText *fieldEditor;
@property (strong, nonatomic) NSView *containerView;
@property (strong, nonatomic) NSView *headerView;
@property (strong, nonatomic) NSView *footerView;
@property (strong, nonatomic) NSScrollView *scrollView;
@property (strong, nonatomic) GDCAutocompleteItemsView *itemsView;
@property (strong, nonatomic) NSWindow *controlWindow;
@property (strong, nonatomic) NSLayoutConstraint *scrollTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *scrollBottomConstraint;
@property (assign, nonatomic) BOOL isAttached;
@property (copy, nonatomic) NSString *originalInput;
@property (assign, nonatomic) BOOL autocompleteSubviews;


- (void)setupViews;
- (void)attachToControl:(NSControl*)control;
- (void)detach;
- (void)refreshSuggestedItems;
- (NSString*)titleForItem:(id)item;


@end


@implementation GDCAutocomplete


- (instancetype)initWithWindow:(NSWindow*)window
{
	if ((self = [super initWithWindow:[[GDCAutocompleteWindow alloc] init]]) != nil)
	{
		self.window.delegate = self;
		[self setupViews];
	}

	return self;
}


- (void)awakeFromNib
{
	if (self.controlToComplete != nil)
	{
		[self attachToControl:self.controlToComplete];
	}
}


#pragma mark -


- (void)createContainerView
{
	self.containerView = [[NSView alloc] initWithFrame:NSZeroRect];
	[self.window.contentView addSubview:self.containerView];
}


- (void)setupContainerViewConstraints
{
	self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.containerView
														   attribute:NSLayoutAttributeTop
														   relatedBy:NSLayoutRelationEqual
															  toItem:self.window.contentView
														   attribute:NSLayoutAttributeTop
														  multiplier:1.0
															constant:0.0];
	NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.containerView
															  attribute:NSLayoutAttributeBottom
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.window.contentView
															  attribute:NSLayoutAttributeBottom
															 multiplier:1.0
															   constant:0.0];
	NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.containerView
															attribute:NSLayoutAttributeLeft
															relatedBy:NSLayoutRelationEqual
															   toItem:self.window.contentView
															attribute:NSLayoutAttributeLeft
														   multiplier:1.0
															 constant:0.0];
	NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.containerView
															 attribute:NSLayoutAttributeRight
															 relatedBy:NSLayoutRelationEqual
																toItem:self.window.contentView
															 attribute:NSLayoutAttributeRight
															multiplier:1.0
															  constant:0.0];
	[self.window.contentView addConstraint:top];
	[self.window.contentView addConstraint:bottom];
	[self.window.contentView addConstraint:left];
	[self.window.contentView addConstraint:right];
}


- (void)createHeaderView
{
	self.headerView = [[GDCAutocompleteHeaderView alloc] initWithFrame:NSZeroRect];
	[self.containerView addSubview:self.headerView];
}


- (void)setupHeaderViewConstraints
{
	self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.headerView
															  attribute:NSLayoutAttributeHeight
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1.0
															   constant:5.0];
	NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.headerView
														   attribute:NSLayoutAttributeTop
														   relatedBy:NSLayoutRelationEqual
															  toItem:self.containerView
														   attribute:NSLayoutAttributeTop
														  multiplier:1.0
															constant:0.0];
	NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.headerView
															attribute:NSLayoutAttributeLeft
															relatedBy:NSLayoutRelationEqual
															   toItem:self.containerView
															attribute:NSLayoutAttributeLeft
														   multiplier:1.0
															 constant:0.0];
	NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.headerView
															 attribute:NSLayoutAttributeRight
															 relatedBy:NSLayoutRelationEqual
																toItem:self.containerView
															 attribute:NSLayoutAttributeRight
															multiplier:1.0
															  constant:0.0];
	[self.containerView addConstraint:height];
	[self.containerView addConstraint:top];
	[self.containerView addConstraint:left];
	[self.containerView addConstraint:right];
}


- (void)setCustomHeaderView:(NSView*)v
{
	NSAssert(self.customHeaderView == nil, @"Custom header view is already set");
	_customHeaderView = v;
	
	if (self.customHeaderView != nil)
	{
		self.headerView.hidden = YES;
		[self.containerView addSubview:self.customHeaderView];
		self.customHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
		NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.customHeaderView
																  attribute:NSLayoutAttributeHeight
																  relatedBy:NSLayoutRelationEqual
																	 toItem:nil
																  attribute:NSLayoutAttributeNotAnAttribute
																 multiplier:1.0
																   constant:self.customHeaderView.bounds.size.height];
		NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.customHeaderView
															   attribute:NSLayoutAttributeTop
															   relatedBy:NSLayoutRelationEqual
																  toItem:self.containerView
															   attribute:NSLayoutAttributeTop
															  multiplier:1.0
																constant:0.0];
		NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.customHeaderView
																attribute:NSLayoutAttributeLeft
																relatedBy:NSLayoutRelationEqual
																   toItem:self.containerView
																attribute:NSLayoutAttributeLeft
															   multiplier:1.0
																 constant:0.0];
		NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.customHeaderView
																 attribute:NSLayoutAttributeRight
																 relatedBy:NSLayoutRelationEqual
																	toItem:self.containerView
																 attribute:NSLayoutAttributeRight
																multiplier:1.0
																  constant:0.0];
		[self.containerView addConstraint:height];
		[self.containerView addConstraint:top];
		[self.containerView addConstraint:left];
		[self.containerView addConstraint:right];
		[self.containerView removeConstraint:self.scrollTopConstraint];
		self.scrollTopConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
																attribute:NSLayoutAttributeTop
																relatedBy:NSLayoutRelationEqual
																   toItem:self.customHeaderView
																attribute:NSLayoutAttributeBottom
															   multiplier:1.0
																 constant:0.0];
		[self.containerView addConstraint:self.scrollTopConstraint];
	}
	else
	{
		self.customHeaderView.hidden = NO;
	}
}


- (void)createFooterView
{
	self.footerView = [[GDCAutocompleteFooterView alloc] initWithFrame:NSZeroRect];
	[self.containerView addSubview:self.footerView];
}


- (void)setupFooterViewConstraints
{
	self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.footerView
															  attribute:NSLayoutAttributeHeight
															  relatedBy:NSLayoutRelationEqual
																 toItem:nil
															  attribute:NSLayoutAttributeNotAnAttribute
															 multiplier:1.0
															   constant:5.0];
	NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.footerView
														   attribute:NSLayoutAttributeBottom
														   relatedBy:NSLayoutRelationEqual
															  toItem:self.containerView
														   attribute:NSLayoutAttributeBottom
														  multiplier:1.0
															   constant:0.0];
	NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.footerView
															attribute:NSLayoutAttributeLeft
															relatedBy:NSLayoutRelationEqual
															   toItem:self.containerView
															attribute:NSLayoutAttributeLeft
														   multiplier:1.0
															 constant:0.0];
	NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.footerView
															 attribute:NSLayoutAttributeRight
															 relatedBy:NSLayoutRelationEqual
																toItem:self.containerView
															 attribute:NSLayoutAttributeRight
															multiplier:1.0
															  constant:0.0];
	[self.containerView addConstraint:height];
	[self.containerView addConstraint:bottom];
	[self.containerView addConstraint:left];
	[self.containerView addConstraint:right];
}


- (void)setCustomFooterView:(NSView*)v
{
	NSAssert(self.customFooterView == nil, @"Custom footer view is already set");
	_customFooterView = v;
	
	if (self.customFooterView != nil)
	{
		self.footerView.hidden = YES;
		[self.containerView addSubview:self.customFooterView];
		self.customFooterView.translatesAutoresizingMaskIntoConstraints = NO;
		NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.customFooterView
																  attribute:NSLayoutAttributeHeight
																  relatedBy:NSLayoutRelationEqual
																	 toItem:nil
																  attribute:NSLayoutAttributeNotAnAttribute
																 multiplier:1.0
																   constant:self.customFooterView.bounds.size.height];
		NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.customFooterView
																  attribute:NSLayoutAttributeBottom
																  relatedBy:NSLayoutRelationEqual
																  toItem:self.containerView
																  attribute:NSLayoutAttributeBottom
																 multiplier:1.0
																   constant:0.0];
		NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.customFooterView
																attribute:NSLayoutAttributeLeft
																relatedBy:NSLayoutRelationEqual
																   toItem:self.containerView
																attribute:NSLayoutAttributeLeft
															   multiplier:1.0
																 constant:0.0];
		NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.customFooterView
																 attribute:NSLayoutAttributeRight
																 relatedBy:NSLayoutRelationEqual
																	toItem:self.containerView
																 attribute:NSLayoutAttributeRight
																multiplier:1.0
																  constant:0.0];
		[self.containerView addConstraint:height];
		[self.containerView addConstraint:bottom];
		[self.containerView addConstraint:left];
		[self.containerView addConstraint:right];
		[self.containerView removeConstraint:self.scrollBottomConstraint];
		self.scrollBottomConstraint = [NSLayoutConstraint constraintWithItem:self.scrollView
																   attribute:NSLayoutAttributeBottom
																   relatedBy:NSLayoutRelationEqual
																	  toItem:self.customFooterView
																   attribute:NSLayoutAttributeTop
																  multiplier:1.0
																	constant:0.0];
		[self.containerView addConstraint:self.scrollBottomConstraint];
	}
	else
	{
		self.customFooterView.hidden = NO;
	}
}


- (void)createScrollView
{
	self.scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
	self.scrollView.autohidesScrollers = YES;
	self.scrollView.hasHorizontalScroller = NO;
	self.scrollView.hasVerticalScroller = YES;
	self.scrollView.scrollerStyle = NSScrollerStyleOverlay;
	self.scrollView.horizontalScrollElasticity = NSScrollElasticityNone;
	self.scrollView.verticalScrollElasticity = NSScrollElasticityNone;
	self.scrollView.drawsBackground = NO;
	self.scrollView.borderType = NSNoBorder;
	[self.containerView addSubview:self.scrollView];
}


- (void)setupScrollViewConstraints
{
	self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.scrollView
														   attribute:NSLayoutAttributeTop
														   relatedBy:NSLayoutRelationEqual
															  toItem:self.headerView
														   attribute:NSLayoutAttributeBottom
														  multiplier:1.0
															constant:0.0];
	NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.scrollView
															  attribute:NSLayoutAttributeBottom
															  relatedBy:NSLayoutRelationEqual
																 toItem:self.footerView
															  attribute:NSLayoutAttributeTop
															 multiplier:1.0
															   constant:0.0];
	NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.scrollView
															attribute:NSLayoutAttributeLeft
															relatedBy:NSLayoutRelationEqual
															   toItem:self.containerView
															attribute:NSLayoutAttributeLeft
														   multiplier:1.0
															 constant:0.0];
	NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.scrollView
															 attribute:NSLayoutAttributeRight
															 relatedBy:NSLayoutRelationEqual
																toItem:self.containerView
															 attribute:NSLayoutAttributeRight
															multiplier:1.0
															  constant:0.0];
	[self.containerView addConstraint:top];
	[self.containerView addConstraint:bottom];
	[self.containerView addConstraint:left];
	[self.containerView addConstraint:right];
	self.scrollTopConstraint = top;
	self.scrollBottomConstraint = bottom;
}


- (void)createItemsView
{
	self.itemsView = [[GDCAutocompleteItemsView alloc] initWithFrame:NSZeroRect];
	self.itemsView.target = self;
	self.itemsView.action = @selector(autocompleteViewDidSelectItem:);
	self.itemsView.delegate = self;
	self.scrollView.documentView = self.itemsView;
}


- (void)setupItemsViewConstraints
{
	self.itemsView.translatesAutoresizingMaskIntoConstraints = NO;
	NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.itemsView
															attribute:NSLayoutAttributeLeft
															relatedBy:NSLayoutRelationEqual
															   toItem:self.scrollView
															attribute:NSLayoutAttributeLeft
														   multiplier:1.0
															 constant:0.0];
	NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.itemsView
															 attribute:NSLayoutAttributeRight
															 relatedBy:NSLayoutRelationEqual
																toItem:self.scrollView
															 attribute:NSLayoutAttributeRight
															multiplier:1.0
															  constant:0.0];
	[self.scrollView addConstraint:left];
	[self.scrollView addConstraint:right];
}


- (void)setupViews
{
	[self createContainerView];
	[self createHeaderView];
	[self createFooterView];
	[self createScrollView];
	[self createItemsView];
	[self setupContainerViewConstraints];
	[self setupHeaderViewConstraints];
	[self setupFooterViewConstraints];
	[self setupScrollViewConstraints];
	[self setupItemsViewConstraints];
}


- (void)attachToControl:(NSControl*)control
{
	NSAssert(!self.isAttached, @"Already attached to a control");
	NSAssert(control != nil, @"Cannot attach to nil control");
	self.controlToComplete = control;
	[self.controlToComplete addObserver:self
						   forKeyPath:@"enabled"
							  options:0
							  context:AttachedControlEnabledContext];
	[self.controlToComplete addObserver:self
						   forKeyPath:@"hidden"
							  options:0
							  context:AttachedControlHiddenContext];
	[self.controlToComplete addObserver:self
							 forKeyPath:@"window"
								options:NSKeyValueObservingOptionInitial
								context:AttachedControlWindowContext];
	[self.itemsView bind:@"content" toObject:self withKeyPath:@"suggestedItems" options:nil];
	
	if ([self.controlToComplete isKindOfClass:[NSSearchField class]])
	{
		self.searchMode = YES;
	}
	
	if ([self.controlToComplete isKindOfClass:[NSTableView class]])
	{
		self.autocompleteSubviews = YES;
	}
	
	self.isAttached = YES;
}


- (void)detach
{
	NSAssert(self.isAttached, @"Already detached");
	
	if (self.controlWindow != nil)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSWindowDidResignKeyNotification
													  object:self.controlWindow];
	}
	
	[self.controlWindow removeChildWindow:self.window];
	[self.itemsView unbind:@"content"];
	[self.controlToComplete removeObserver:self forKeyPath:@"window" context:AttachedControlWindowContext];
	[self.controlToComplete removeObserver:self forKeyPath:@"hidden" context:AttachedControlHiddenContext];
	[self.controlToComplete removeObserver:self forKeyPath:@"enabled" context:AttachedControlEnabledContext];
}


#pragma mark -


// This is invoked when an item is selected with mouse
- (void)autocompleteViewDidSelectItem:(id)sender
{
	id item = self.itemsView.selectedItem;
	[self.delegate autocomplete:self didSelectItem:item];
	
	if (self.searchMode)
	{
		[self hideWindow:sender];
	}
	else
	{
		self.fieldEditor.string = [self titleForItem:item];
	}
	
	[self.controlToComplete.window makeFirstResponder:self.controlToComplete];
}


- (void)setSearchMode:(BOOL)likeMenu
{
	_searchMode = likeMenu;
	self.itemsView.highlightingTracksMouse = likeMenu;
}


- (NSCell*)cell
{
	return self.itemsView.cell;
}


- (void)setCell:(NSCell*)cell
{
	self.itemsView.cell = cell;
}


+ (BOOL)automaticallyNotifiesObserversOfSuggestedItems
{
	return NO;
}


- (void)setFieldEditor:(NSText*)fieldEditor
{
	if (self.fieldEditor != nil)
	{
		[self.fieldEditor removeObserver:self
							  forKeyPath:@"delegate"
								 context:FieldEditorDelegateContext];
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSViewFrameDidChangeNotification
													  object:self.fieldEditor];
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSTextDidChangeNotification
													  object:self.fieldEditor];
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:NSTextDidEndEditingNotification
													  object:self.fieldEditor];
	}
	
	_fieldEditor = fieldEditor;
	
	if (self.fieldEditor != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(fieldEditorFrameDidChangeNotification:)
													 name:NSViewFrameDidChangeNotification
												   object:self.fieldEditor];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(fieldEditorTextDidChange:)
													 name:NSTextDidChangeNotification
												   object:self.fieldEditor];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(fieldEditorTextDidEndEditing:)
													 name:NSTextDidEndEditingNotification
												   object:self.fieldEditor];
		[fieldEditor addObserver:self
					  forKeyPath:@"delegate"
						 options:NSKeyValueObservingOptionInitial
						 context:FieldEditorDelegateContext];
	}
}


- (void)setSuggestedItems:(NSArray*)items
{
	[self willChangeValueForKey:@"suggestedItems"];
	_suggestedItems = items;
	[self didChangeValueForKey:@"suggestedItems"];
	[self layout];
	
	if (self.suggestedItems.count > 0)
	{
		if (self.searchMode)
		{
			[self.itemsView clearHighlighting];
		}
		else
		{
			[self.itemsView highlightIndex:0];
		}
	}
	else
	{
		[self hideWindow:nil];
	}
}


- (void)refreshSuggestedItems
{
	NSString *s = self.fieldEditor.string;
	[self.delegate autocomplete:self refreshSuggestedItemsForString:s];
}


- (NSString*)titleForItem:(id)item
{
	NSString *title = nil;
	
	if ([self.delegate respondsToSelector:@selector(autocomplete:titleForItem:)])
	{
		title = [self.delegate autocomplete:self titleForItem:item];
	}
	else if ([item isKindOfClass:[NSString class]])
	{
		title = item;
	}
	else
	{
		title = [item description];
	}
	
	return title;
}


- (void)updateFieldEditor
{
	if (self.searchMode)
	{
		return;
	}
	
	if (self.originalInput == nil)
	{
		return;
	}
	
	id item = self.itemsView.selectedItem;
	
	if (item != nil)
	{
		NSString *input = self.originalInput;
		NSString *title = [self titleForItem:item];
		
		if ([title hasPrefix:input])
		{
			self.fieldEditor.string = title;
			self.fieldEditor.selectedRange = NSMakeRange(input.length, title.length - input.length);
		}
	}
	else
	{
		// Restore the original input
		NSText *fieldEditor = self.fieldEditor;
		fieldEditor.string = self.originalInput;
	}
}


- (CGFloat)contentHeight
{
	NSView *h = self.customHeaderView != nil ? self.customHeaderView : self.headerView;
	NSView *f = self.customFooterView != nil ? self.customFooterView : self.footerView;
	CGFloat height = h.frame.size.height;
	height += self.itemsView.frame.size.height;
	height += f.frame.size.height;
	return height;
}


- (void)layout
{
	NSAssert(self.controlToComplete != nil, @"Autocomplete is not set to complete any control");
	
	[self.window.contentView layoutSubtreeIfNeeded];
	NSRect fieldEditorRect = self.fieldEditor.bounds;
	NSRect fieldEditorRectRelativeToWindow = [self.fieldEditor convertRect:fieldEditorRect toView:nil];
	NSRect fieldEditorRectRelativeToScreen = [self.fieldEditor.window convertRectToScreen:fieldEditorRectRelativeToWindow];
	NSRect frame = self.window.frame;
	
	// Respect minimum and maximum width.
	if (fieldEditorRectRelativeToScreen.size.width < self.window.minSize.width)
	{
		frame.size.width = self.window.minSize.width;
	}
	else if (fieldEditorRectRelativeToScreen.size.width > self.window.maxSize.width)
	{
		frame.size.width = self.window.maxSize.width;
	}
	else
	{
		frame.size.width = fieldEditorRectRelativeToScreen.size.width;
	}
	
	// Set window height to match content.
	frame.size.height = [self contentHeight];

	// Respect maximum height.
	if (self.itemsView.frame.size.height > self.window.maxSize.height)
	{
		frame.size.height = self.window.maxSize.height;
	}
	
	// Adjust the window origin (lower-left corner).
	frame.origin.x = fieldEditorRectRelativeToScreen.origin.x;
	frame.origin.y = fieldEditorRectRelativeToScreen.origin.y - frame.size.height - SpacingBetweenControlAndWindow;
	
	// Apply calculated frame if it differs from current frame.
	if (!NSEqualRects(self.window.frame, frame))
	{
		if ([self.delegate respondsToSelector:@selector(autocomplete:proposedRect:)])
		{
			frame = [self.delegate autocomplete:self proposedRect:frame];
		}
		
		[self.window setFrame:frame display:YES];
	}
}


- (void)fieldEditorFrameDidChangeNotification:(NSNotification*)notification
{
	[self layout];
}


- (void)controlWindowDidResignKey:(NSNotification*)notification
{
	[self hideWindow:nil];
}


- (void)showWindow:(id)sender
{
	if (self.suggestedItems.count > 0 && !NSEqualRects(self.window.frame, NSZeroRect))
	{
		if (!self.searchMode)
		{
			[self updateFieldEditor];
		}
		
		[self.controlWindow addChildWindow:self.window ordered:NSWindowAbove];
        [self.window orderFront:nil];
		[self.window makeFirstResponder:self.itemsView];
	}
	else
	{
		[self hideWindow:sender];
	}
}


- (void)hideWindow:(id)sender
{
	if (self.window.isVisible)
	{
		[self.window orderOut:nil];
		[self.controlWindow removeChildWindow:self.window];
	}
}


- (void)fieldEditorTextDidChange:(NSNotification*)notification
{
	if (self.interceptor == nil)
	{
		return;
	}
	
	NSAssert(self.delegate != nil, @"Cannot autocomplete without delegate");
	NSAssert(notification.object == self.fieldEditor, @"Unexpected field editor");
	self.originalInput = self.fieldEditor.string;
    [self refreshSuggestedItems];
	
	if (self.fieldEditor.string.length > 0)
	{
		if (self.suggestedItems.firstObject == nil)
		{
			[self hideWindow:nil];
		}
	}
	else
	{
		[self hideWindow:nil];
	}
}


- (void)fieldEditorTextDidEndEditing:(NSNotification*)notification
{
	if (self.interceptor == nil)
	{
		return;
	}
	
	self.originalInput = nil;
	int movement = [[[notification userInfo] valueForKey:@"NSTextMovement"] intValue];
	
	// Check if editing ended with a keystroke that would apply a suggested item.
	if (movement == NSReturnTextMovement || movement == NSTabTextMovement || movement == NSBacktabTextMovement)
	{
		id item = self.itemsView.selectedItem;
		
		if (item != nil)
		{
			[self.delegate autocomplete:self didSelectItem:item];
		}
	}
	
	[self hideWindow:nil];
}


- (void)itemsView:(GDCAutocompleteItemsView*)view willDisplayCell:(NSCell*)cell atIndex:(NSUInteger)index
{
	id item = cell.representedObject;
	NSString *title = [self titleForItem:item];
	cell.objectValue = title;
}


- (void)itemsView:(GDCAutocompleteItemsView*)view updateFieldEditorForItemAtIndex:(NSUInteger)index
{
	if (self.window.isVisible && !self.searchMode)
	{
		[self updateFieldEditor];
	}
}


// Called by field editor via FieldEditorDelegateInterceptor.
- (BOOL)textView:(NSTextView*)aTextView doCommandBySelector:(SEL)aSelector
{
	if (aSelector == @selector(cancelOperation:) && !self.window.isVisible)
	{
		// Handle cancelOperation: to dismiss the window only when it's visible.
		// Otherwise let the real delegate handle it.
		return NO;
	}
	else if (aSelector == @selector(moveUp:) && !self.window.isVisible)
	{
		return NO;
	}
	else if (aSelector == @selector(moveDown:) && !self.window.isVisible)
	{
        if (self.suggestedItems.firstObject == nil)
        {
            return NO;
        }
        
        [self showWindow:nil];
        return YES;
	}
	
	return [self tryToPerform:aSelector with:aTextView];
}


- (void)deleteBackward:(id)sender
{
    [self.fieldEditor deleteBackward:sender];
    [self.itemsView clearHighlighting];
}


- (void)cancelOperation:(id)sender
{
	[self.itemsView clearHighlighting];
	[self hideWindow:sender];
}


- (void)complete:(id)sender
{
	if (self.window.isVisible)
	{
		[self.itemsView clearHighlighting];
		[self hideWindow:nil];
	}
	else
	{
		[self refreshSuggestedItems];
		[self showWindow:sender];
		[self layout];
		
		if (self.itemsView.selectedItem == nil)
		{
			[self.itemsView highlightIndex:0];
		}
	}
}


- (void)moveDown:(id)sender
{
	if (self.window.isVisible)
	{
		[self.itemsView moveDown:sender];
	}
}


- (void)moveUp:(id)sender
{
	if (self.window.isVisible)
	{
		[self.itemsView moveUp:sender];
	}
}


- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context
{
	if (context == FieldEditorDelegateContext)
	{
		NSAssert(self.fieldEditor == object, @"Unexpected field editor");
		id d = [object valueForKeyPath:keyPath];
		
		if (d != nil && d == self.interceptor)
		{
			// Ignore recursive invocation.
		}
		else if (d == self.controlToComplete)
		{
			// This applies to controls such as NSTextField, NSSearchField, and cell-based NSTableView.
			self.interceptor = [[GDCAutocompleteFieldEditorDelegateInterceptor alloc] initWithAutocomplete:self delegate:d];
			self.fieldEditor.delegate = self.interceptor;
		}
		else if ([self.controlToComplete containsSubview:object])
		{
			// This applies to controls such as view-based NSTableView.
			self.interceptor = [[GDCAutocompleteFieldEditorDelegateInterceptor alloc] initWithAutocomplete:self delegate:d];
			self.fieldEditor.delegate = self.interceptor;
		}
		else if (d != nil)
		{
			// Field editor is being used for a control we're not completing.
			self.interceptor = nil;
		}
		else
		{
			// Leave self.interceptor intact when d == nil.
		}
	}
	else if (context == AttachedControlHiddenContext)
	{
		if (![[object valueForKey:keyPath] boolValue])
		{
			[self hideWindow:nil];
		}
	}
	else if (context == AttachedControlEnabledContext)
	{
		if (![[object valueForKey:keyPath] boolValue])
		{
			[self hideWindow:nil];
		}
	}
	else if (context == AttachedControlWindowContext)
	{
		NSWindow *w = [object valueForKeyPath:keyPath];
		
		if (w == self.controlWindow)
		{
			// No change.
			return;
		}
		
		if (self.controlWindow != nil)
		{
			// Cleanup.
			self.fieldEditor = nil;
			[[NSNotificationCenter defaultCenter] removeObserver:self
															name:NSWindowDidResignKeyNotification
														  object:self.controlWindow];
			
			if (self.window.parentWindow != nil)
			{
				[self.controlWindow removeChildWindow:self.window];
			}
			
			self.controlWindow = nil;
		}
		
		if (w != nil)
		{
			// Setup.
			self.controlWindow = w;
			self.fieldEditor = [w fieldEditor:YES forObject:self.controlToComplete];
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(controlWindowDidResignKey:)
														 name:NSWindowDidResignKeyNotification
													   object:self.controlWindow];
		}
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


@end
