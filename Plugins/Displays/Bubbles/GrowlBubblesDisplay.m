//
//  GrowlBubblesDisplay.m
//  Growl
//
//  Created by Nelson Elhage on Wed Jun 09 2004.
//  Name changed from KABubbleController.h by Justin Burns on Fri Nov 05 2004.
//  Name changed from GrowlBubblesController.h by rudy on Tue Nov 29 2005.
//  Copyright (c) 2004 Nelson Elhage. All rights reserved.
//

#import <GrowlPlugins/GrowlNotification.h>
#import "GrowlBubblesDisplay.h"
#import "GrowlBubblesDefines.h"
#import "GrowlBubblesWindowController.h"
#import "GrowlBubblesPrefsController.h"


@implementation GrowlBubblesController

#pragma mark -

- (id) init {
	if ((self = [super init])) {
		windowControllerClass = NSClassFromString(@"GrowlBubblesWindowController");
		self.prefDomain = GrowlBubblesPrefDomain;
	}
	return self;
}

- (void) dealloc {
	[preferencePane release];
	[super dealloc];
}

- (GrowlPluginPreferencePane *) preferencePane {
	if (!preferencePane)
		preferencePane = [[GrowlBubblesPrefsController alloc] initWithBundle:[NSBundle bundleForClass:[self class]]];
	return preferencePane;
}

@end
