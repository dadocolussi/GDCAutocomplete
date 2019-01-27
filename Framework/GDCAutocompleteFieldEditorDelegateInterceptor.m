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


#import "GDCAutocompleteFieldEditorDelegateInterceptor.h"


@interface GDCAutocompleteFieldEditorDelegateInterceptor ()
@property (strong, nonatomic) NSObject *dummyDelegate;
@end


@implementation GDCAutocompleteFieldEditorDelegateInterceptor


- (instancetype)initWithAutocomplete:(GDCAutocomplete*)ac delegate:(id<NSTextViewDelegate>)d
{
	_autocomplete = ac;
	_interceptedDelegate = d;
	self.dummyDelegate = [[NSObject alloc] init];
	return self;
}


- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
	if (self.interceptedDelegate == nil)
	{
		return [self.dummyDelegate methodSignatureForSelector:sel];
	}
	
	return [(id)self.interceptedDelegate methodSignatureForSelector:sel];
}


- (void)forwardInvocation:(NSInvocation*)invocation
{
	if (self.interceptedDelegate == nil)
	{
		[invocation invokeWithTarget:self.dummyDelegate];
	}
	else
	{
		[invocation invokeWithTarget:self.interceptedDelegate];
	}
}


- (BOOL)textView:(NSTextView*)aTextView doCommandBySelector:(SEL)aSelector
{
	if ([self.autocomplete textView:aTextView doCommandBySelector:aSelector])
	{
		return YES;
	}
	
	return [self.interceptedDelegate textView:aTextView doCommandBySelector:aSelector];
}


- (NSString*)description
{
	NSString *d = [NSString stringWithFormat:@"%@ autocomplete: %@ delegate: %@",
				   [super description],
				   self.autocomplete,
				   self.interceptedDelegate];
	return d;
}


@end
