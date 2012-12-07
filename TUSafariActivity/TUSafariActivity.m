//
//  TUSafariActivity.h
//
//  Created by David Beck on 11/30/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//
//  http://github.com/davbeck/TUSafariActivity
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "TUSafariActivity.h"
#import <objc/runtime.h>

// Stores the result of the initialize method.
static BOOL gIsAvailable;

@interface TUDummyActivity ()
// These dummy properties seem to "make space" in memory for the superclass.
// Without them, calling activityDidFinish: will crash on the device. Maybe the
// UIActivity class defines private properties and this helps the compiler give
// the necessary space for them?
//
// For further discussion see http://stackoverflow.com/a/13745244/172690
@property (nonatomic, assign) int dummy1;
@property (nonatomic, assign) int dummy2;
@property (nonatomic, assign) int dummy3;
@property (nonatomic, assign) int dummy4;
@property (nonatomic, assign) int dummy5;
@property (nonatomic, assign) int dummy6;
@property (nonatomic, assign) int dummy7;
@property (nonatomic, assign) int dummy8;
@property (nonatomic, assign) int dummy9;
@end

@implementation TUDummyActivity
- (void)activityDidFinish:(BOOL)completed {}

@end

@interface TUSafariActivity ()

@property (nonatomic, retain) NSURL *url;

@end


@implementation TUSafariActivity

@synthesize url = url_;

/** Checks the availability of the UIActivity class at runtime.
 * If the class is available, the super class is swizzled to that one and sets
 * gIsAvailable to true, so that end user code knows the class can be
 * instantiated correctly.
 */
+ (void)initialize
{
	Class activity_class = objc_getClass("UIActivity");
	if (activity_class) {
		class_setSuperclass([TUSafariActivity class], activity_class);
		gIsAvailable = YES;
	}
#ifdef DEBUG
	NSLog(@"Parent of TUSafariActivity is %@, available: %d",
		[[TUSafariActivity class] superclass], gIsAvailable);
#endif
}

- (void)dealloc
{
	[url_ release];
	[super dealloc];
}

// Returns YES if instantiating a TUSafariActivity is safe and makes sense.
+ (BOOL)isAvailable
{
	return gIsAvailable;
}

- (NSString *)activityType
{
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
	static NSBundle* bundle = nil;
	if (nil == bundle) {
		NSString *lang = [[[NSUserDefaults standardUserDefaults]
			objectForKey:@"AppleLanguages"] objectAtIndex:0];
		NSString *path = [NSString
			stringWithFormat:@"%@/TUSafariActivity.bundle/%@.lproj",
			[[NSBundle mainBundle] resourcePath], lang];
		bundle = [NSBundle bundleWithPath:path];
		// If not found, load the main bundle to have no nil localized strings.
		if (!bundle)
			bundle = [NSBundle mainBundle];
	}
	NSString *key = @"Open in Safari";
	return [bundle localizedStringForKey:key value:key table:nil];
}

- (UIImage *)activityImage
{
	return [UIImage imageNamed:@"Safari"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]] && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
			return YES;
		}
	}

	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
	for (id activityItem in activityItems) {
		if ([activityItem isKindOfClass:[NSURL class]]) {
			self.url = activityItem;
		}
	}
}

- (void)performActivity
{
	BOOL completed = [[UIApplication sharedApplication] openURL:self.url];

	[self activityDidFinish:completed];
}

@end
