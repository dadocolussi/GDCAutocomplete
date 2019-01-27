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


@class GDCAutocomplete;


@protocol GDCAutocompleteDelegate <NSWindowDelegate>


@required


// This message is sent to the delegate every time the field editor input string is changed.
// To update the suggested items, set ac.suggestedItems = newSuggestedItems. You may also
// update the suggested items asynchronously any time with ac.suggestedItems = mySuggestedItems.
- (void)autocomplete:(GDCAutocomplete*)ac refreshSuggestedItemsForString:(NSString*)s;


// This message is sent to the delegate when the user selects a suggested item.
- (void)autocomplete:(GDCAutocomplete *)ac didSelectItem:(id)item;


@optional


// This message is sent to the delegate when autocomplete needs the human-readable
// title for an item. If the delegate doesn't implement this, [item description] will
// be used.
- (NSString*)autocomplete:(GDCAutocomplete*)ac titleForItem:(id)item;


// This message is sent to the delegate when autocomplete is doing layout.
// The delegate can override proposedRect by returning another rect. Return
// the proposed rectangle by returning it. Return NSZeroRect to disable showing
// autocomplete.
- (NSRect)autocomplete:(GDCAutocomplete*)ac proposedRect:(NSRect)proposedRect;


@end
