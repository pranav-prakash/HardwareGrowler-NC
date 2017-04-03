//
//  GrowlNanoDisplay.m
//  Display Plugins
//
//  Created by Rudy Richter on 12/12/2005.
//  Copyright 2005–2011, The Growl Project. All rights reserved.
//

#import <GrowlPlugins/GrowlNotification.h>
#import "GrowlNanoDisplay.h"
#import "GrowlNanoWindowController.h"
#import "GrowlNanoPrefs.h"
#import "GrowlDefinesInternal.h"

@implementation GrowlNanoDisplay

- (id) init {
	if ((self = [super init])) {
		windowControllerClass = NSClassFromString(@"GrowlNanoWindowController");
		self.prefDomain = GrowlNanoPrefDomain;
	}
	return self;
}

- (void) dealloc {
	[preferencePane release];
	[super dealloc];
}

- (GrowlPluginPreferencePane *) preferencePane {
	if (!preferencePane)
		preferencePane = [[GrowlNanoPrefs alloc] initWithBundle:[NSBundle bundleForClass:[self class]]];
	return preferencePane;
}

//we implement requiresPositioning entirely because it was added as a requirement for doing 1.1 plugins, however
//we don't really care if positioning is required or not, because we are only ever in the menubar.
- (BOOL)requiresPositioning {
	return NO;
}

@end
