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


#import "SearchFieldController.h"
#import "Country.h"


@interface SearchFieldController ()
@property (copy, nonatomic) NSString *searchString;
- (void)deferredRefreshSuggestedItemsForAutocomplete:(GDCAutocomplete*)ac;
@end


@implementation SearchFieldController


- (void)deferredRefreshSuggestedItemsForAutocomplete:(GDCAutocomplete*)ac
{
	self.filter = [NSPredicate predicateWithFormat:@"self.countryName contains [cd] %@", self.searchString];
	ac.suggestedItems = self.filteredItems.arrangedObjects;
	
	// Notice that we explicitly show the autocomplete window. This has the effect
	// of popping the autocomplete window open automatically as the user starts typing.
	[ac showWindow:nil];
}


- (void)autocomplete:(GDCAutocomplete*)ac refreshSuggestedItemsForString:(NSString*)s
{
	if (!ac.window.isVisible)
	{
		NSText *fieldEditor = [(id)self.view currentEditor];
		
		// Show the autocomplete window immediately only if the current search string
		// in the field editor matches with the most recent filtering.
		if ([fieldEditor.string isEqualToString:self.searchString])
		{
			[ac showWindow:nil];
		}
		else
		{
			// Don't show previous suggestions until we've refreshed the suggestions.
			[ac.window orderOut:nil];
		}
	}
	
	// Cancel previously scheduled refresh.
	SEL sel = @selector(deferredRefreshSuggestedItemsForAutocomplete:);
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:sel object:ac];
	
	// Take a COPY of the current input string.
	self.searchString = s;
	
	// Schedule a deferred refresh of the suggested items.
	[self performSelector:sel withObject:ac afterDelay:0.5];
}


- (NSString*)autocomplete:(GDCAutocomplete*)ac titleForItem:(id)item
{
	Country *c = item;
	return c.countryName;
}


- (void)autocomplete:(GDCAutocomplete*)ac didSelectItem:(id)item
{
	self.allItems.selectedObjects = @[item];
}


@end
