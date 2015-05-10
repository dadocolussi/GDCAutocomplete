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


#import "TableViewController.h"
#import "Country.h"


@interface TableViewController ()
@property (strong, nonatomic) NSArray *sourceItems;
@end


@implementation TableViewController


- (void)awakeFromNib
{
	// Populate the table with some initial data.
	[self.items addObject:[Country countryWithName:@"France" capital:@"Paris"]];
	[self.items addObject:[Country countryWithName:@"Germany" capital:@"Berlin"]];
	[self.items addObject:[Country countryWithName:@"Italy" capital:@"Rome"]];
	[self.items addObject:[Country countryWithName:@"Spain" capital:@"Madrid"]];
	[self.items addObject:[Country countryWithName:@"United Kingdom" capital:@"London"]];
}


- (NSArray*)sourceItems
{
	
	if (_sourceItems == nil)
	{
		NSMutableArray *items = [NSMutableArray array];
		[items addObject:[Country countryWithName:@"Austria" capital:@"Vienna"]];
		[items addObject:[Country countryWithName:@"Belgium" capital:@"Bruxelles"]];
		[items addObject:[Country countryWithName:@"Bulgaria" capital:@"Sofia"]];
		[items addObject:[Country countryWithName:@"Croatia" capital:@"Zagreb"]];
		[items addObject:[Country countryWithName:@"Cyprus" capital:@"Nicosia"]];
		[items addObject:[Country countryWithName:@"Czech Republic" capital:@"Prague"]];
		[items addObject:[Country countryWithName:@"Denmark" capital:@"Copenhagen"]];
		[items addObject:[Country countryWithName:@"Estonia" capital:@"Tallinn"]];
		[items addObject:[Country countryWithName:@"Finland" capital:@"Helsinki"]];
		[items addObject:[Country countryWithName:@"France" capital:@"Paris"]];
		[items addObject:[Country countryWithName:@"Germany" capital:@"Berlin"]];
		[items addObject:[Country countryWithName:@"Greece" capital:@"Athens"]];
		[items addObject:[Country countryWithName:@"Hungary" capital:@"Budapest"]];
		[items addObject:[Country countryWithName:@"Ireland" capital:@"Dublin"]];
		[items addObject:[Country countryWithName:@"Italy" capital:@"Rome"]];
		[items addObject:[Country countryWithName:@"Latvia" capital:@"Riga"]];
		[items addObject:[Country countryWithName:@"Lithuania" capital:@"Vilnus"]];
		[items addObject:[Country countryWithName:@"Luxembourg" capital:@"Luxembourg"]];
		[items addObject:[Country countryWithName:@"Malta" capital:@"Valletta"]];
		[items addObject:[Country countryWithName:@"Netherlands" capital:@"Amsterdam"]];
		[items addObject:[Country countryWithName:@"Poland" capital:@"Warsaw"]];
		[items addObject:[Country countryWithName:@"Portugal" capital:@"Lisbon"]];
		[items addObject:[Country countryWithName:@"Romania" capital:@"Bucarest"]];
		[items addObject:[Country countryWithName:@"Slovakia" capital:@"Bratislava"]];
		[items addObject:[Country countryWithName:@"Slovenia" capital:@"Ljubljana"]];
		[items addObject:[Country countryWithName:@"Spain" capital:@"Madrid"]];
		[items addObject:[Country countryWithName:@"Sweden" capital:@"Stockholm"]];
		[items addObject:[Country countryWithName:@"United Kingdom" capital:@"London"]];
		_sourceItems = items;
	}
	
	return _sourceItems;
}


- (void)autocomplete:(GDCAutocomplete*)ac refreshSuggestedItemsForString:(NSString*)s
{
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"self.countryName contains [cd] %@", s];
	ac.suggestedItems = [self.sourceItems filteredArrayUsingPredicate:filter];
	[ac showWindow:nil];
}


- (NSString*)autocomplete:(GDCAutocomplete*)ac titleForItem:(id)item
{
	Country *c = item;
	return c.countryName;
}


- (void)autocomplete:(GDCAutocomplete*)ac didSelectItem:(id)item
{
	Country *suggestedCountry = item;
	Country *c = self.items.selectedObjects.firstObject;
	c.countryName = suggestedCountry.countryName;
	c.capitalName = suggestedCountry.capitalName;
}


@end
