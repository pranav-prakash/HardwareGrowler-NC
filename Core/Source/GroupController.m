//
//  GroupController.m
//  Growl
//
//  Created by Daniel Siemer on 8/13/11.
//  Copyright 2011 The Growl Project. All rights reserved.
//

#import "GroupController.h"
#import "GroupedArrayController.h"

@implementation GroupController

@synthesize owner;
@synthesize groupID;
@synthesize groupArray;
@synthesize showGroup;

- (id)initWithGroupID:(NSString*)newID
      arrayController:(NSArrayController*)controller
{
    self = [super init];
    if (self) {
        self.groupID = newID;
        self.groupArray = controller;
        showGroup = YES;
        // Initialization code here.
    }
    
    return self;
}

-(void)setShowGroup:(BOOL)newGroup {
	if(owner){
		owner.transitionGroup = YES;
	}
	[self willChangeValueForKey:@"showGroup"];
	showGroup = newGroup;
	[self didChangeValueForKey:@"showGroup"];
}

-(void)dealloc
{
    [groupID release];
    [groupArray release];
   [super dealloc];
}

-(NSComparisonResult)compare:(id)obj2
{
    if([obj2 isKindOfClass:[self class]])
        return [groupID caseInsensitiveCompare:[obj2 groupID]];
    else
        return NSOrderedDescending;
}

@end
