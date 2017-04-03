//
//  AppDelegate.m
//  HardwareGrowlerLauncher
//
//  Created by Daniel Siemer on 5/2/12.
//  Copyright (c) 2012 The Growl Project, LLC. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
   NSArray *growlInstances = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.growl.hardwaregrowler"];
   if(!growlInstances.count)
   {
      NSURL* appURL = [[[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"../../../../Contents/MacOS/HardwareGrowler" isDirectory:NO] URLByResolvingSymlinksInPath];
      NSLog(@"Launching HardwareGrowler at URL: %@", appURL);
      NSDictionary* conf = [NSDictionary dictionary];
      NSError* error = nil;
      [[NSWorkspace sharedWorkspace] launchApplicationAtURL:appURL options:NSWorkspaceLaunchDefault configuration:conf error:&error];
      if (error) {
         NSLog(@"%@", error);
      }
   }
	[NSApp terminate:nil];
}

@end
