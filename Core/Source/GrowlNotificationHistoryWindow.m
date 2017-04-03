//
//  GrowlNotificationHistoryWindow.m
//  Growl
//
//  Created by Daniel Siemer on 9/2/10.
//  Copyright 2010 The Growl Project. All rights reserved.
//

#import "GrowlNotificationHistoryWindow.h"
#import "GrowlNotificationDatabase.h"
#import "GrowlHistoryNotification.h"
#import "GrowlApplicationController.h"
#import "GrowlTicketDatabase.h"
#import "GrowlApplication.h"
#import "GrowlPathUtilities.h"
#import "GrowlNotificationCellView.h"
#import "GrowlNotificationRowView.h"
#import "GrowlRollupGroupCellView.h"
#import "GroupedArrayController.h"
#import "GroupController.h"
#import "GrowlMenu.h"

#define GROWL_ROLLUP_WINDOW_HEIGHT @"GrowlRollupWindowHeight"
#define GROWL_ROLLUP_WINDOW_WIDTH @"GrowlRollupWindowWidth"

#define GROWL_DESCRIPTION_WIDTH_PAD 42.0
#define GROWL_DESCRIPTION_HEIGHT_PAD 28.0
#define GROWL_ROW_MINIMUM_HEIGHT 48.0
#define GROWL_ROW_UNSELECTED_MAX_HEIGHT 62.0
#define GROWL_ROW_MAX_HEIGHT 113.0

@interface GrowlNotificationHistoryWindow (PrivateMethods)

-(void)updateRowHeights;
-(CGFloat)heightForRow:(NSUInteger)row;
-(CGFloat)heightForDescription:(NSString *)description forWidth:(CGFloat)width;

@end

@implementation GrowlNotificationHistoryWindow

@synthesize historyTable;
@synthesize countLabel;
@synthesize notificationColumn;
@synthesize notificationDatabase=_notificationDatabase;
@synthesize windowTitle;
@synthesize groupController;

-(id)initWithNotificationDatabase:(GrowlNotificationDatabase *)notificationDatabase
{
   if((self = [super initWithWindowNibName:@"AwayHistoryWindow" owner:self]))
   {
       self.notificationDatabase = notificationDatabase;
       
       [self setWindowFrameAutosaveName:@"GrowlNotificationRollup"];
       [[self window] setFrameAutosaveName:@"GrowlNotificationRollup"];
              
       rowHeights = [[NSMutableArray alloc] init];
      self.windowTitle = NSLocalizedString(@"Growl Notification Rollup", @"Window title for the Notification Rollup window");
   }
   return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [historyTable setDoubleAction:@selector(userDoubleClickedNote:)];
}

-(void)dealloc
{
    [groupController removeObserver:self forKeyPath:nil];
    
    [historyTable release], historyTable = nil;
    groupController.delegate = nil;
    [groupController release], groupController = nil;
    _notificationDatabase = nil;
    [windowTitle release];
    [super dealloc];
}

-(BOOL)windowShouldClose:(NSNotification *)notfication
{
    [self.notificationDatabase userReturnedAndClosedList];
    return YES;
}

-(void)windowWillClose:(NSNotification *)notification
{
    //We use the setBool rather than the direct since that causes an infinite loop trying to close the window
    [[GrowlPreferencesController sharedController] setBool:NO forKey:GrowlRollupShown];
}

-(void)setNotificationDatabase:(GrowlNotificationDatabase *)notificationDatabase {
    if (notificationDatabase != _notificationDatabase) {
        _notificationDatabase = notificationDatabase;
        
        if (groupController)
        {
            [groupController setDelegate:nil];
            [groupController release], groupController = nil;
        }
        
        groupController = [[GroupedArrayController alloc] initWithEntityName:@"Notification" 
                                                         basePredicateString:@"showInRollup == 1" 
                                                                    groupKey:@"ApplicationName"
                                                        managedObjectContext:[_notificationDatabase managedObjectContext]];
        [groupController setDelegate:self];
        
        NSSortDescriptor *ascendingTime = [NSSortDescriptor sortDescriptorWithKey:@"Time" ascending:NO];
        [[groupController countController] setSortDescriptors:[NSArray arrayWithObject:ascendingTime]];
		 [groupController setTableView:historyTable];
    }
    

}

-(void)updateCount
{
   NSUInteger numberOfNotifications = [[[groupController countController] arrangedObjects] count];
   NSString* description = nil;
   
   NSInteger menuState = [[GrowlPreferencesController sharedController] menuState];
   if(menuState == GrowlDockMenu || menuState == GrowlBothMenus){
      NSDockTile *tile = [NSApp dockTile];
      NSString *dockString = (numberOfNotifications > 0) ? [NSString stringWithFormat:@"%lu", numberOfNotifications] : nil;
      [tile setBadgeLabel:dockString];
   }
   
   if(menuState == GrowlStatusMenu || menuState == GrowlBothMenus){
      if(numberOfNotifications > 0)
         [[[GrowlApplicationController sharedController] statusMenu] startPulse];
      else
         [[[GrowlApplicationController sharedController] statusMenu] stopPulse];
   }
   
   if(numberOfNotifications == 0){
      //Use perform close so that userReturnedAndClosedList is called, which will set us back to having notes while away
      description = NSLocalizedString(@"There are no new notifications", nil);
      if([[GrowlPreferencesController sharedController] isRollupAutomatic])
         [[self window] performClose:self];
   }else if(numberOfNotifications == 1){
      description = [NSString stringWithFormat:NSLocalizedString(@"There was %lu notification while you were away", nil), numberOfNotifications];
   } else {
      description = [NSString stringWithFormat:NSLocalizedString(@"There were %lu notifications while you were away", nil), numberOfNotifications];   
   }

    [countLabel setObjectValue:description];
}

-(void)resetArray
{   
    [historyTable reloadData];
}

-(IBAction)userDoubleClickedNote:(id)sender
{
   NSInteger row = NSNotFound;
   if([sender isKindOfClass:[NSTableView class]]){
       row = [historyTable clickedRow];
   }else if([sender isKindOfClass:[NSButton class]]){
       //We use bindings, so the showGroup is already toggled, just tell it to update the array
       [groupController updateArray];
       return;
   }
   
   if(row != NSNotFound && row >= 0)
   {      
      id obj = [[groupController arrangedObjects] objectAtIndex:row];
      if([obj isKindOfClass:[GrowlHistoryNotification class]])
          [[GrowlApplicationController sharedController] growlNotificationDict:[obj valueForKey:@"GrowlDictionary"] 
                                                  didCloseViaNotificationClick:YES 
                                                                onLocalMachine:YES];
      else if([obj isKindOfClass:[GroupController class]]){
          [groupController toggleShowGroup:[obj groupID]];
      }
   }
}

- (IBAction)deleteNotifications:(id)sender {
    /* Logic for what note to remove from the rollup:
     * If we clicked while on a hovered note, delete that one
     * If we clicked or pressed delete while on a selected note, delete that one
     * If there are other selected notes, and we clicked delete, or a selected one, delete those as well
     */
    NSInteger row = [historyTable rowForView:sender];
    NSMutableIndexSet *rowsToDelete = [NSMutableIndexSet indexSet];
    if(row == -1 || row > [historyTable numberOfRows]){
        NSLog(@"no row for this delete event");
        return;
    }
   
    NSTableRowView *view = [historyTable rowViewAtRow:row makeIfNecessary:NO];
    if(view && [view isKindOfClass:[GrowlNotificationRowView class]] && [(GrowlNotificationRowView*)view mouseInside] && 
       ![[historyTable selectedRowIndexes] containsIndex:row]){
        [rowsToDelete addIndex:row];
    }else if([[historyTable selectedRowIndexes] containsIndex:row]){
        [rowsToDelete addIndexes:[historyTable selectedRowIndexes]];
    }
    if([rowsToDelete count] == 0)
        return;
    //NSLog(@"Rows to remove from the rollup: %@", rowsToDelete);
    for(id obj in [[groupController arrangedObjects] objectsAtIndexes:rowsToDelete]){
        if([obj isKindOfClass:[GrowlHistoryNotification class]])
            [obj setShowInRollup:[NSNumber numberWithBool:NO]];
    }
    [self.notificationDatabase saveDatabase:NO];
}

- (IBAction)deleteAppNotifications:(id)sender {
    NSUInteger row = [historyTable rowForView:sender];
    if(![self tableView:historyTable isGroupRow:row]){
        NSLog(@"Row not found, or not application");
        return;
    }

    NSArrayController *appController = [[[groupController arrangedObjects] objectAtIndex:row] groupArray];
    if(!appController)
        return;
    [[appController arrangedObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[GrowlHistoryNotification class]])
            [obj setShowInRollup:[NSNumber numberWithBool:NO]];
    }];
    [self.notificationDatabase saveDatabase:NO];
}

#pragma mark Row Height methods

-(void)updateRowHeights
{
    if([[groupController arrangedObjects] count] == 0)
        return;
    
    /* we got out of sync somehow, we will fix here */
    BOOL rebuilding = NO;
    if([rowHeights count] != [[groupController arrangedObjects] count]){
        NSLog(@"Row height array and group controller got out of sync, rebuilding row height array");
        rebuilding = YES;
        [rowHeights removeAllObjects];
    }
    
    __block GrowlNotificationHistoryWindow *blockSafeSelf = self;
    NSMutableIndexSet *modified = [NSMutableIndexSet indexSet];
    [[groupController arrangedObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat newHeight = [blockSafeSelf heightForRow:idx];
        if(!rebuilding){
            CGFloat oldHeight = [[rowHeights objectAtIndex:idx] floatValue];
            
            if(newHeight > oldHeight || newHeight < oldHeight){
                [rowHeights replaceObjectAtIndex:idx withObject:[NSNumber numberWithFloat:newHeight]];
                [modified addIndex:idx];
            }
        }else{
            [rowHeights insertObject:[NSNumber numberWithFloat:newHeight] atIndex:idx];
            [modified addIndex:idx];
        }
    }];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.25];
    [historyTable noteHeightOfRowsWithIndexesChanged:modified];
    [NSAnimationContext endGrouping];
}

/* This method always returns the current value, and not the cached one */
-(CGFloat)heightForRow:(NSUInteger)row
{
    CGFloat result = GROWL_ROW_MINIMUM_HEIGHT;
    if([self tableView:historyTable isGroupRow:row]){
        result = 34.0;
    }else{
        id obj = [[groupController arrangedObjects] objectAtIndex:row];
        if([obj isKindOfClass:[GrowlHistoryNotification class]]){
            NSString *description = [[[groupController arrangedObjects] objectAtIndex:row] Description];
            CGFloat width = [[self window] frame].size.width;
            result = [self heightForDescription:description forWidth:width];
            if([[historyTable selectedRowIndexes] containsIndex:row]){
/*              if (result > GROWL_ROW_MAX_HEIGHT)
                    result = GROWL_ROW_MAX_HEIGHT;*/
            }else{
                if(result > GROWL_ROW_UNSELECTED_MAX_HEIGHT)
                    result = GROWL_ROW_UNSELECTED_MAX_HEIGHT;
            }
        }
    }
    return result;
}

-(CGFloat)heightForDescription:(NSString*)description forWidth:(CGFloat)width
{
    CGFloat padded = width - GROWL_DESCRIPTION_WIDTH_PAD;
    NSFont *font = [NSFont boldSystemFontOfSize:0];
    NSParagraphStyle *paragraph = [NSParagraphStyle defaultParagraphStyle];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, 
                                                                          paragraph, NSParagraphStyleAttributeName, nil];
    NSRect bound = [description boundingRectWithSize:NSMakeSize(padded, 0) 
                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine 
                                          attributes:attributes];
    CGFloat result = bound.size.height + GROWL_DESCRIPTION_HEIGHT_PAD;
    return (result > GROWL_ROW_MINIMUM_HEIGHT) ? result : GROWL_ROW_MINIMUM_HEIGHT;
}


#pragma mark TableView Data source methods

- (BOOL)tableView:(NSTableView*)tableView isGroupRow:(NSInteger)row
{
	if([[groupController arrangedObjects] count] > (NSUInteger)row)
		return [[[groupController arrangedObjects] objectAtIndex:row] isKindOfClass:[GroupController class]];
	else
		return NO;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[groupController arrangedObjects] count];
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
   if(aTableColumn == notificationColumn || [self tableView:aTableView isGroupRow:rowIndex]){
      return [[groupController arrangedObjects] objectAtIndex:rowIndex];
   }
   return nil;
}

-(NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if(tableColumn == notificationColumn){
        if([groupController grouped]){
            GrowlNotificationCellView *cellView = [tableView makeViewWithIdentifier:@"GroupNoteCell" owner:self];
            [[cellView deleteButton] setHidden:![[historyTable selectedRowIndexes] containsIndex:row]];
            return cellView;
        }else{
            GrowlNotificationCellView *cellView = [tableView makeViewWithIdentifier:@"NotificationCellView" owner:self];
            [[cellView deleteButton] setHidden:![[historyTable selectedRowIndexes] containsIndex:row]];
            return cellView;
        }
    }else if([self tableView:tableView isGroupRow:row]){
        GrowlRollupGroupCellView *groupView = [tableView makeViewWithIdentifier:@"GroupCellView" owner:self];
       
        NSString *appName = [[self tableView:tableView objectValueForTableColumn:tableColumn row:row] groupID];
        NSData *iconData = [[[GrowlTicketDatabase sharedInstance] ticketForApplicationName:appName hostName:nil] iconData];
        NSImage *icon = [[NSImage alloc] initWithData:iconData];
        if(icon){
            [[groupView imageView] setImage:icon];
        }else{
            [[groupView imageView] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericApplicationIcon)]];
        }
        [icon release];
        
        [[groupView deleteButton] setState:NSOnState];
        
        return groupView;
    }
    return nil;
}

-(NSView*)tableView:(NSTableView*)tableView rowViewForRow:(NSInteger)row
{
    if(![self tableView:tableView isGroupRow:row]){
        GrowlNotificationRowView *rowView = [tableView makeViewWithIdentifier:NSTableViewRowViewKey owner:self];
        [rowView setMouseInside:NO];
        return rowView;
    }else{
        return [tableView makeViewWithIdentifier:@"GroupRowView" owner:self];
    }
}

/* We should have ALWAYS have a valid cached value, but just in case we don't, call the method that will give us the current, valid value*/
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if((NSUInteger)row < [rowHeights count] && [[rowHeights objectAtIndex:row] floatValue] > 0.0)
        return [[rowHeights objectAtIndex:row] floatValue];

    return [self heightForRow:row];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [historyTable enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        NSView *cellView = [rowView viewAtColumn:0];
        if ([cellView isKindOfClass:[GrowlNotificationCellView class]] && [rowView isKindOfClass:[GrowlNotificationRowView class]]) {
            GrowlNotificationRowView *tableRowView = (GrowlNotificationRowView*)rowView;
            GrowlNotificationCellView *tableCellView = (GrowlNotificationCellView *)cellView;
            NSButton *deleteButton = tableCellView.deleteButton;
            if (tableRowView.selected || tableRowView.mouseInside) {
                [deleteButton setHidden:NO];
            } else {
                [deleteButton setHidden:YES];
            }
        }
    }];
    
    [self updateRowHeights];
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
   return ![self tableView:tableView isGroupRow:row];
}


#pragma mark Window delegate methods

- (void)windowDidResize:(NSNotification *)note
{
    [self updateRowHeights];
}

#pragma mark GroupedArrayControllerDelegate methods

-(void)groupedControllerUpdatedTotalCount:(GroupedArrayController*)groupedController
{
    [self updateCount];
}
-(void)groupedControllerBeginUpdates:(GroupedArrayController*)groupedController
{
}
-(void)groupedControllerEndUpdates:(GroupedArrayController*)groupedController
{
    [self updateRowHeights];
}
-(void)groupedController:(GroupedArrayController*)groupedController insertIndexes:(NSIndexSet*)indexSet
{    
    __block GrowlNotificationHistoryWindow *blockSafeSelf = self;
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSNumber *height = [NSNumber numberWithFloat:[blockSafeSelf heightForRow:idx]];
        [rowHeights insertObject:height atIndex:idx];
    }];
}
-(void)groupedController:(GroupedArrayController*)groupedController removeIndexes:(NSIndexSet*)indexSet
{    
    [rowHeights removeObjectsAtIndexes:indexSet];
}
-(void)groupedController:(GroupedArrayController*)groupedController moveIndex:(NSUInteger)start toIndex:(NSUInteger)end
{
    id temp = [[rowHeights objectAtIndex:start] retain];
    [rowHeights removeObjectAtIndex:start];
    [rowHeights insertObject:temp atIndex:end];
    [temp release];
}

@end
