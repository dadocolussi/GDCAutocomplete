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


#import <Cocoa/Cocoa.h>

#import <GDCAutocomplete/GDCAutocompleteDelegate.h>
#import <GDCAutocomplete/GDCAutocompleteHeaderView.h>
#import <GDCAutocomplete/GDCAutocompleteFooterView.h>


FOUNDATION_EXPORT double GDCAutocompleteVersionNumber;
FOUNDATION_EXPORT const unsigned char GDCAutocompleteVersionString[];


@interface GDCAutocomplete : NSWindowController <NSWindowDelegate, NSTextViewDelegate>


// Delegate to assist the autocomplete.
// Required.
@property (weak, nonatomic) IBOutlet id<GDCAutocompleteDelegate> delegate;


// This should reference an NSControl object that will be autocompleted.
// Use -attachToControl: to set the control to complete.
// Required.
@property (weak, nonatomic, readonly) IBOutlet NSControl *controlToComplete;


// Custom header and footer views.
// Optional.
@property (strong, nonatomic) IBOutlet NSView *customHeaderView;
@property (strong, nonatomic) IBOutlet NSView *customFooterView;


// Assign a custom NSCell if you need to change how the suggested items are displayed.
// Optional.
@property (strong, nonatomic) IBOutlet NSCell *cell;


// This is the list of currently suggested items. Update this as the user input changes.
@property (strong, nonatomic) NSArray *suggestedItems;


// Search mode means that suggested items are highlighted as the mouse moves
// over the items and that the field editor never udpates to reflect currently
// highlighted item. This OFF by default, except when completing an NSSearchField.
@property (assign, nonatomic) BOOL searchMode;


- (void)attachToControl:(NSControl*)control;
- (void)detach;


@end
