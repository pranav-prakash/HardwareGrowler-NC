//
//  GrowlSpeechDisplay.h
//  Display Plugins
//
//  Created by Ingmar Stein on 15.11.04.
//  Copyright 2004–2011 The Growl Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GrowlPlugins/GrowlActionPlugin.h>

@interface GrowlSpeechDisplay : GrowlActionPlugin <GrowlDispatchNotificationProtocol, NSSpeechSynthesizerDelegate> {
    NSMutableArray *speech_queue;
    NSSpeechSynthesizer *syn;
	dispatch_queue_t speech_dispatch_queue;
}

@property (retain) NSMutableArray *speech_queue;
@property (retain) NSSpeechSynthesizer *syn;
@property (nonatomic, assign) BOOL paused;

- (void)speakNotification:(NSString*)notificationToSpeak withConfiguration:(NSDictionary*)config;

@end
