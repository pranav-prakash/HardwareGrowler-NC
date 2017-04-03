//
//  GrowlTicketController.m
//  Growl
//
//  Created by Peter Hosey on 2005-06-08.
//  Copyright 2005-2006 Peter Hosey. All rights reserved.
//

#import "GrowlTicketController.h"
#import "GrowlPathUtilities.h"
#import "NSStringAdditions.h"

@implementation GrowlTicketController

- (id) init {
	if ((self = [super init])) {
		ticketsByApplicationName = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc{
	[ticketsByApplicationName release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (void) loadTicketsFromDirectory:(NSString *)srcDir clobbering:(BOOL)clobber {
	NSFileManager *mgr = [NSFileManager defaultManager];
	BOOL isDir;
	NSDirectoryEnumerator *ticketsEnum = [mgr enumeratorAtPath:srcDir];
	NSString *filename;

	while ((filename = [ticketsEnum nextObject])) {
		filename = [srcDir stringByAppendingPathComponent:filename];
		[mgr fileExistsAtPath:filename isDirectory:&isDir];

		if ((!isDir) && [[filename pathExtension] isEqualToString:GROWL_PATHEXTENSION_TICKET]) {
			GrowlApplicationTicket *newTicket = [[GrowlApplicationTicket alloc] initTicketFromPath:filename];
			if (newTicket) {
				NSString *applicationName = [newTicket appNameHostName];
				if (!applicationName) {
					NSLog(@"Invalid ticket (no application name inside): %@", [filename lastPathComponent]);
				} else {
					/* Growl used to generate a ticket for itself to display notifcations, but 
				 	 * but this has been removed for 1.1, referencing ticket #547. Thus we have
				 	 * the ticket loader remove the file if found */
					if([applicationName isEqual:@"Growl"])
					{
						[self removeTicketForApplicationName:@"Growl"];
						[mgr removeItemAtPath:filename error:nil];
					}

					/*if we haven't already loaded a ticket for this application,
				 	 *	or if we're clobbering already-loaded tickets,
				 	 *	set this ticket in the dictionary.
				 	 */
					if (clobber || ![ticketsByApplicationName objectForKey:applicationName])
						[ticketsByApplicationName setObject:newTicket forKey:applicationName];
				}
				
				[newTicket release];
			}
		}
	}
}

- (void) loadAllSavedTickets {
//	CFAbsoluteTime start = CFAbsoluteTimeGetCurrent(); //TEMP

	// XXX: should use GrowlPathUtilities here
	NSArray *libraryDirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, /*expandTilde*/ YES);
	NSString *growlSupportPath;
	[ticketsByApplicationName removeAllObjects];

	for (NSString *libraryPath in libraryDirs) {
		growlSupportPath = [libraryPath      stringByAppendingPathComponent:@"Application Support"];
		growlSupportPath = [growlSupportPath stringByAppendingPathComponent:@"Growl"];
		growlSupportPath = [growlSupportPath stringByAppendingPathComponent:@"Tickets"];
		/*the search paths are returned in the order we should search in, so
		 *	earlier results should take priority. thus, clobbering:NO.
		 */
		[self loadTicketsFromDirectory:growlSupportPath clobbering:NO];
	}

//	NSLog(@"Got all saved tickets in %f seconds", CFAbsoluteTimeGetCurrent() - start); //TEMP
}

#pragma mark -
#pragma mark Public methods

- (NSArray *) allSavedTickets {
	return [ticketsByApplicationName allValues];
}

- (GrowlApplicationTicket *) ticketForApplicationName:(NSString *)appName hostName:(NSString*)hostName {
   NSString *appHost;
   if(hostName && ![hostName isLocalHost])
      appHost = [NSString stringWithFormat:@"%@ - %@", hostName, appName];
   else
      appHost = appName;
	return [[[ticketsByApplicationName objectForKey:appHost] retain] autorelease];
}
- (void) addTicket:(GrowlApplicationTicket *) newTicket {
	NSString *appName = [newTicket appNameHostName];
	if (!appName)
		NSLog(@"GrowlTicketController: cannot add ticket because it has no application name (description follows)\n%@", newTicket);
	else {
      [self willChangeValueForKey:@"allSavedTickets"];
		[ticketsByApplicationName setObject:newTicket
									 forKey:appName];
      [self didChangeValueForKey:@"allSavedTickets"];
		//XXX this here is pretty barftastic. what about tickets that already have a path? should we clobber the existing path? create a copy? leave it alone, as now? --boredzo
		//if (![newTicket path])
		//	[newTicket setPath:[GrowlPathUtilities defaultSavePathForTicketWithApplicationName:appName];
		//Don't synchronize here to avoid an infinite loop in -[GrowlApplicationController preferencesChanged]
		//[newTicket synchronize];
	}
}

- (void) removeTicketForApplicationName:(NSString *)appName {
   [self willChangeValueForKey:@"allSavedTickets"];
	[ticketsByApplicationName removeObjectForKey:appName];
   [self didChangeValueForKey:@"allSavedTickets"];
}

@end
