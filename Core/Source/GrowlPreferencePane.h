//
//  GrowlPreferencePane.h
//  Growl
//
//  Created by Karl Adam on Wed Apr 21 2004.
//  Copyright 2004-2006 The Growl Project. All rights reserved.
//
// This file is under the BSD License, refer to License.txt for details

#import <PreferencePanes/PreferencePanes.h>
#import "GrowlAbstractDatabase.h"

@class GrowlPluginController, GrowlPreferencesController, GrowlPrefsViewController;

@interface GrowlPreferencePane : NSWindowController <NSNetServiceBrowserDelegate, NSWindowDelegate> {
	//cached controllers
	/*these are cached to avoid redundant calls to
	 *	[GrowlXController sharedController].
	 *though that method also caches its return value, we're dealing with
	 *	Bindings here, so we want to pick up all the speed boosts that we can.
	 */
	GrowlPluginController			*pluginController;
	GrowlPreferencesController		*preferencesController;

   //Prefs list support
    IBOutlet NSToolbar              *toolbar;
   NSMutableDictionary              *prefViewControllers;
   GrowlPrefsViewController         *currentViewController;
   
   BOOL firstOpen;
}

- (NSString *) bundleVersion;

- (void) reloadPreferences:(NSNotification *)note;

#pragma mark Bindings accessors (not for programmatic use)

- (GrowlPluginController *) pluginController;
- (GrowlPreferencesController *) preferencesController;

#pragma mark Toolbar support
-(void)setSelectedTab:(NSUInteger)tab;
-(IBAction)selectedTabChanged:(id)sender;
-(void)releaseTab:(GrowlPrefsViewController*)tab;

#pragma mark Properties
@property (retain) NSString *networkAddressString;
@property (retain) GrowlPrefsViewController *currentViewController;
@property (retain) NSMutableDictionary *prefViewControllers;

@property (nonatomic, retain) NSString *settingsWindowTitle;
@property (nonatomic, assign) IBOutlet NSToolbarItem *generalItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *applicationsItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *displaysItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *networkItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *rollupItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *historyItem;
@property (nonatomic, assign) IBOutlet NSToolbarItem *aboutItem;

@end
