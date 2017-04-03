//
//  GNTPSubscriberEntry.h
//  Growl
//
//  Created by Daniel Siemer on 11/22/11.
//  Copyright (c) 2011 The Growl Project. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GrowlCommunicationAttempt.h"

@class GNTPKey, GNTPSubscribePacket, GrowlGNTPCommunicationAttempt, GrowlGNTPSubscriptionAttempt;

@interface GNTPSubscriberEntry : NSObject <GrowlCommunicationAttemptDelegate>

@property (nonatomic, retain) NSString *computerName;
@property (nonatomic, retain) NSString *addressString;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSData *lastKnownAddress;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *subscriberID;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) GNTPKey *key;
@property (nonatomic, retain) NSTimer *resubscribeTimer;

@property (nonatomic, retain) NSDate *initialTime;
@property (nonatomic, retain) NSDate *validTime;
@property (nonatomic) NSInteger timeToLive;
@property (nonatomic) NSInteger subscriberPort;
@property (nonatomic) BOOL remote;
@property (nonatomic) BOOL manual;
@property (nonatomic) BOOL use;
@property (nonatomic) BOOL active;

@property (nonatomic) BOOL alreadyBrowsing;
@property (nonatomic) BOOL attemptingToSubscribe;
@property (nonatomic) BOOL subscriptionError;
@property (nonatomic, retain) NSString* subscriptionErrorDescription;

@property (nonatomic, retain) GrowlGNTPSubscriptionAttempt *subscriptionAttempt;

-(id)initWithName:(NSString*)name
    addressString:(NSString*)addrString
           domain:(NSString*)aDomain
          address:(NSData*)addrData
             uuid:(NSString*)aUUID
     subscriberID:(NSString*)subID
           remote:(BOOL)isRemote
           manual:(BOOL)isManual
              use:(BOOL)shouldUse
      initialTime:(NSDate*)date
       timeToLive:(NSInteger)ttl
             port:(NSInteger)port;

-(id)initWithDictionary:(NSDictionary*)dict;
-(id)initWithPacket:(GNTPSubscribePacket*)packet;

-(void)updateRemoteWithPacket:(GNTPSubscribePacket*)packet;
-(void)updateLocalWithPacket:(GrowlGNTPCommunicationAttempt*)packet error:(BOOL)wasError;
-(void)subscribe;

-(void)invalidate;
-(NSDictionary*)dictionaryRepresentation;

@end
