//
//  main.m
//  GNTP
//
//  Created by Rachel Blackman on 9/01/11.
//  Copyright (c) 2011 The Growl Project. All rights reserved.
//

#include <xpc/xpc.h>
#import <Foundation/Foundation.h>
#import "GrowlDefines.h"
#import "NSObject+XPCHelpers.h"
#import "GrowlNotifier.h"
#import "GrowlGNTPCommunicationAttempt.h"
#import "GrowlGNTPRegistrationAttempt.h"
#import "GrowlGNTPNotificationAttempt.h"

static GrowlNotifier *notifier = nil;
static BOOL keepAlive = NO;

static void GNTP_peer_event_handler(xpc_connection_t peer, xpc_object_t event)
{
	if(!keepAlive){
		xpc_transaction_begin();
		keepAlive = YES;
	}
	
	xpc_type_t type = xpc_get_type(event);
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
	} else {
		assert(type == XPC_TYPE_DICTIONARY);
		
		// Here we unpack our dictionary.
		NSDictionary *dict = [NSObject xpcObjectToNSObject:event];
		NSString *purpose = [dict valueForKey:@"GrowlDictType"];
		NSDictionary *growlDict = [dict objectForKey:@"GrowlDict"];
		
		NSData *address = [dict objectForKey:@"GNTPAddressData"];
		NSString *host = [dict valueForKey :@"GNTPHost"];
		NSString *pass = [dict valueForKey:@"GNTPPassword"];
		
		GrowlGNTPCommunicationAttempt *attempt = nil;
		if ([purpose caseInsensitiveCompare:@"registration"] == NSOrderedSame) {
			attempt = [[[GrowlGNTPRegistrationAttempt alloc] initWithDictionary:growlDict] autorelease];
			
		}else if ([purpose caseInsensitiveCompare:@"notification"] == NSOrderedSame) {
			attempt = [[[GrowlGNTPNotificationAttempt alloc] initWithDictionary:growlDict] autorelease];
		}else if ([purpose caseInsensitiveCompare:@"shutdown"] == NSOrderedSame){
			if(keepAlive){
				NSLog(@"Shutting down GNTP Client XPC");
				xpc_transaction_end();
				keepAlive = NO;
				exit(0);
			}
		}
		if(attempt){
			attempt.delegate = (id <GrowlCommunicationAttemptDelegate>)notifier;
			attempt.host = host;
			attempt.addressData = address;
			attempt.password = pass;
			attempt.connection = peer;
			
			[notifier sendCommunicationAttempt:attempt];
		}
	}
}

static void GNTP_event_handler(xpc_connection_t peer)
{
	// By defaults, new connections will target the default dispatch
	// concurrent queue.
	xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
		GNTP_peer_event_handler(peer, event);
	});
	
	// This will tell the connection to begin listening for events. If you
	// have some other initialization that must be done asynchronously, then
	// you can defer this call until after that initialization is done.
	xpc_connection_resume(peer);
}

int main(int argc, const char *argv[])
{
	@autoreleasepool
    {
        notifier = [[GrowlNotifier alloc] init];
        xpc_main(GNTP_event_handler);
    }
	return 0;
}
