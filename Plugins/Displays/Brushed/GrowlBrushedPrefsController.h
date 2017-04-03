//
//  GrowlBrushedPrefsController.h
//  Display Plugins
//
//  Created by Ingmar Stein on 12/01/2004.
//  Copyright 2004–2011 The Growl Project. All rights reserved.
//

#import <GrowlPlugins/GrowlPluginPreferencePane.h>

@interface GrowlBrushedPrefsController : GrowlPluginPreferencePane {
}

@property (nonatomic, retain) NSString *useAquaLabel;

- (CGFloat) duration;
- (void) setDuration:(CGFloat)value;
- (BOOL) isFloatingIcon;
- (void) setFloatingIcon:(BOOL)value;
- (BOOL) isLimit;
- (void) setLimit:(BOOL)value;
- (BOOL) isAqua;
- (void) setAqua:(BOOL)value;
- (int) size;
- (void) setSize:(int)value;
- (NSColor *) textColorVeryLow;
- (void) setTextColorVeryLow:(NSColor *)value;
- (NSColor *) textColorModerate;
- (void) setTextColorModerate:(NSColor *)value;
- (NSColor *) textColorNormal;
- (void) setTextColorNormal:(NSColor *)value;
- (NSColor *) textColorHigh;
- (void) setTextColorHigh:(NSColor *)value;
- (NSColor *) textColorEmergency;
- (void) setTextColorEmergency:(NSColor *)value;
- (int) screen;
- (void) setScreen:(int)value;

@end
