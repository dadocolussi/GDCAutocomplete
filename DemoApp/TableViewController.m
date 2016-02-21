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


#import "TableViewController.h"
#import "Country.h"


@interface TableViewController ()
@property (strong, nonatomic) NSArray *euItems;
@property (strong, nonatomic) NSArray *usItems;
@property (strong, nonatomic, readonly) NSArray *sourceItems;
@property (copy, nonatomic) NSString *inputString;
- (void)refreshSuggestions;
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


- (NSArray*)euItems
{
	if (_euItems == nil)
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
		_euItems = items;
	}
	
	return _euItems;
}


- (NSArray*)usItems
{
	if (_usItems == nil)
	{
		NSMutableArray *items = [NSMutableArray array];
		[items addObject:[Country countryWithName:@"Alabama" capital:@"Montgomery"]];
		[items addObject:[Country countryWithName:@"Alaska" capital:@"Juneau"]];
		[items addObject:[Country countryWithName:@"Arizona" capital:@"Phoenix"]];
		[items addObject:[Country countryWithName:@"Arkansas" capital:@"Little Rock"]];
		[items addObject:[Country countryWithName:@"California" capital:@"Sacramento"]];
		[items addObject:[Country countryWithName:@"Colorado" capital:@"Denver"]];
		[items addObject:[Country countryWithName:@"Connecticut" capital:@"Hartford"]];
		[items addObject:[Country countryWithName:@"Delaware" capital:@"Dover"]];
		[items addObject:[Country countryWithName:@"Florida" capital:@"Tallahassee"]];
		[items addObject:[Country countryWithName:@"Georgia" capital:@"Atlanta"]];
		[items addObject:[Country countryWithName:@"Hawaii" capital:@"Honolulu"]];
		[items addObject:[Country countryWithName:@"Idaho" capital:@"Boise"]];
		[items addObject:[Country countryWithName:@"Illinois" capital:@"Springfield"]];
		[items addObject:[Country countryWithName:@"Indiana" capital:@"Indianapolis"]];
		[items addObject:[Country countryWithName:@"Iowa" capital:@"Des Moines"]];
		[items addObject:[Country countryWithName:@"Kansas" capital:@"Topeka"]];
		[items addObject:[Country countryWithName:@"Kentucky" capital:@"Frankfort"]];
		[items addObject:[Country countryWithName:@"Louisiana" capital:@"Baton Rouge"]];
		[items addObject:[Country countryWithName:@"Maine" capital:@"Augusta"]];
		[items addObject:[Country countryWithName:@"Maryland" capital:@"Annapolis"]];
		[items addObject:[Country countryWithName:@"Massachusetts" capital:@"Boston"]];
		[items addObject:[Country countryWithName:@"Michigan" capital:@"Lansing"]];
		[items addObject:[Country countryWithName:@"Minnesota" capital:@"St. Paul"]];
		[items addObject:[Country countryWithName:@"Mississippi" capital:@"Jackson"]];
		[items addObject:[Country countryWithName:@"Missouri" capital:@"Jefferson City"]];
		[items addObject:[Country countryWithName:@"Montana" capital:@"Helena"]];
		[items addObject:[Country countryWithName:@"Nebraska" capital:@"Lincoln"]];
		[items addObject:[Country countryWithName:@"Nevada" capital:@"Carson City"]];
		[items addObject:[Country countryWithName:@"New Hampshire" capital:@"Concord"]];
		[items addObject:[Country countryWithName:@"New Jersey" capital:@"Trenton"]];
		[items addObject:[Country countryWithName:@"New Mexico" capital:@"Santa Fe"]];
		[items addObject:[Country countryWithName:@"New York" capital:@"Albany"]];
		[items addObject:[Country countryWithName:@"North Carolina" capital:@"Raleigh"]];
		[items addObject:[Country countryWithName:@"North Dakota" capital:@"Bismarck"]];
		[items addObject:[Country countryWithName:@"Ohio" capital:@"Columbus"]];
		[items addObject:[Country countryWithName:@"Oklahoma" capital:@"Oklahoma City"]];
		[items addObject:[Country countryWithName:@"Oregon" capital:@"Salem"]];
		[items addObject:[Country countryWithName:@"Pennsylvania" capital:@"Harrisburg"]];
		[items addObject:[Country countryWithName:@"Rhode Island" capital:@"Providence"]];
		[items addObject:[Country countryWithName:@"South Carolina" capital:@"Columbia"]];
		[items addObject:[Country countryWithName:@"South Dakota" capital:@"Pierre"]];
		[items addObject:[Country countryWithName:@"Tennessee" capital:@"Nashville"]];
		[items addObject:[Country countryWithName:@"Texas" capital:@"Austin"]];
		[items addObject:[Country countryWithName:@"Utah" capital:@"Salt Lake City"]];
		[items addObject:[Country countryWithName:@"Vermont" capital:@"Montpelier"]];
		[items addObject:[Country countryWithName:@"Virginia" capital:@"Richmond"]];
		[items addObject:[Country countryWithName:@"Washington" capital:@"Olympia"]];
		[items addObject:[Country countryWithName:@"West Virginia" capital:@"Charleston"]];
		[items addObject:[Country countryWithName:@"Wisconsin" capital:@"Madison"]];
		[items addObject:[Country countryWithName:@"Wyoming" capital:@"Cheyenne"]];
		_usItems = items;
	}
	
	return _usItems;
}


- (NSArray*)sourceItems
{
	switch (self.selectedRegionTag)
	{
		case 0:
			return self.euItems;
		case 1:
			return self.usItems;
		default:
			@throw [NSException exceptionWithName:NSInternalInconsistencyException
										   reason:@"Invalid region tag"
										 userInfo:nil];
	}
}


- (void)setSelectedRegionTag:(NSInteger)t
{
	_selectedRegionTag = t;
	[self refreshSuggestions];
}


- (void)refreshSuggestions
{
	NSPredicate *filter = [NSPredicate predicateWithFormat:@"self.countryName contains [cd] %@", self.inputString];
	self.autocomplete.suggestedItems = [self.sourceItems filteredArrayUsingPredicate:filter];
	[self.autocomplete showWindow:nil];
}


- (void)autocomplete:(GDCAutocomplete*)ac refreshSuggestedItemsForString:(NSString*)s
{
	self.inputString = s;
	[self refreshSuggestions];
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
