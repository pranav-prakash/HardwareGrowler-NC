//
//  GrowlDisplaysViewController.h
//  Growl
//
//  Created by Daniel Siemer on 11/10/11.
//  Copyright (c) 2011 The Growl Project. All rights reserved.
//

#import "GrowlPrefsViewController.h"
#import "GroupedArrayController.h"

@class GrowlPlugin, GrowlPluginController, GrowlTicketDatabase, GrowlTicketDatabasePlugin, GrowlPluginPreferencePane;

@interface GrowlDisplaysViewController : GrowlPrefsViewController <GroupedArrayControllerDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>

@property (nonatomic, assign) GrowlPluginController *pluginController;
@property (nonatomic, assign) GrowlTicketDatabase *ticketDatabase;
@property (nonatomic, assign) IBOutlet NSTableView *displayPluginsTable;
@property (nonatomic, assign) IBOutlet NSView *displayPrefView;
@property (nonatomic, assign) IBOutlet NSView *displayDefaultPrefView;
@property (nonatomic, assign) IBOutlet NSTextField *displayAuthor;
@property (nonatomic, assign) IBOutlet NSTextField *displayVersion;
@property (nonatomic, assign) IBOutlet NSTextField *displayName;
@property (nonatomic, assign) IBOutlet NSButton *previewButton;
@property (nonatomic, assign) IBOutlet NSPopUpButton *defaultDisplayPopUp;
@property (nonatomic, assign) IBOutlet NSPopUpButton *defaultActionPopUp;
@property (nonatomic, retain) IBOutlet GroupedArrayController *pluginConfigGroupController;
@property (nonatomic, assign) IBOutlet NSArrayController *displayConfigsArrayController;
@property (nonatomic, assign) IBOutlet NSArrayController *actionConfigsArrayController;
@property (nonatomic, assign) IBOutlet NSArrayController *displayPluginsArrayController;

@property (nonatomic, assign) IBOutlet NSWindow *disabledDisplaysSheet;
@property (nonatomic, assign) IBOutlet NSTextView *disabledDisplaysList;

@property (nonatomic, retain) GrowlPluginPreferencePane *pluginPrefPane;
@property (nonatomic, retain) NSMutableArray *loadedPrefPanes;

@property (nonatomic, retain) GrowlPlugin *currentPluginController;

@property (nonatomic, retain) NSString *defaultStyleLabel;
@property (nonatomic, retain) NSString *showDisabledButtonTitle;
@property (nonatomic, retain) NSString *getMoreStylesButtonTitle;
@property (nonatomic, retain) NSString *previewButtonTitle;
@property (nonatomic, retain) NSString *displayStylesColumnTitle;
@property (nonatomic, retain) NSString *noDefaultDisplayPluginLabel;

@property (nonatomic, retain) NSString *defaultActionsLabel;
@property (nonatomic, retain) NSString *addConfigButtonTitle;
@property (nonatomic, retain) NSString *defaultActionPopUpTitle;
@property (nonatomic, retain) NSString *addCompoundOption;
@property (nonatomic, retain) NSString *noActionsTitle;

@property (nonatomic, retain) NSString *disabledPluginSheetDescription;
@property (nonatomic, retain) NSString *disabledPluginSheetCloseButtonTitle;

@property (nonatomic) BOOL awokeFromNib;

- (void)selectDefaultPlugin:(NSString*)pluginID;
- (void)selectPlugin:(NSString*)pluginName;

- (IBAction) showDisabledDisplays:(id)sender;
- (IBAction) endDisabledDisplays:(id)sender;
- (IBAction)addConfiguration:(id)sender;
- (IBAction)deleteConfiguration:(id)sender;

- (IBAction) openGrowlWebSiteToStyles:(id)sender;
- (IBAction) showPreview:(id)sender;
- (void) loadViewForDisplay:(GrowlTicketDatabasePlugin*)displayName;

@end
