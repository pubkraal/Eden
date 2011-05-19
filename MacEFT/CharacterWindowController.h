//
//  CharacterDocument.h
//  MacEFT
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <stdlib.h>
#import <string.h>


// TODO: sheet for new character

@class CharacterDocument;
@class CharacterWindowDelegate;

@interface CharacterWindowController : NSWindowController <NSWindowDelegate, NSOutlineViewDelegate> {
@private
	// Interface Elements
	IBOutlet NSToolbarItem * characterInfoItem;
	IBOutlet NSToolbarItem * trainingSkillItem;
	IBOutlet NSToolbarItem * reloadItem;
	IBOutlet NSView * characterInfoView;
	IBOutlet NSView * trainingSkillView;
	IBOutlet NSView * reloadView;
	IBOutlet NSOutlineView * tasksView;
	IBOutlet NSTreeController * tasksController;
	IBOutlet NSView * dynamicView;

	// Other views
	NSDictionary * subviews;

	NSString * activeViewName;
	NSString * nextViewName;

	// Interface data
	BOOL reloadEnabled;
	
	// Tasks
	NSMutableArray * tasks;
	NSPredicate * requiresFullAPIPred;
	NSArray * selectedTasks;

	// Timers
	NSTimer * skillTimer; 

}

@property (readonly) NSView * dynamicView;

@property (retain) NSString * activeViewName;
@property (retain) NSString * nextViewName;

@property (retain) NSMutableArray * tasks;
@property (retain) NSArray * selectedTasks;
@property (retain) NSDictionary * subviews;

@property (assign) CharacterDocument * document;
@property (assign) BOOL reloadEnabled;

// Initialization

- (void)addAllObservers;
- (void)removeAllObservers;


// Tasks functions

+ (NSMutableArray *)filteredTasks:(NSMutableArray *)tasks usingPredicate:(NSPredicate *)predicate;
- (void)loadTasks;

// Actions

- (void)selectedTaskChangedFrom:(NSArray *)oldTaskPaths to:(NSArray *)newTaskPaths;
- (void)fullAPIChangedTo:(BOOL)fullAPI;
- (void)showCharacterSelectionSheet;
- (IBAction)performReload:(id)sender;
- (void)scheduleSkillTimer;
- (void)cancelSkillTimer;

// Notifications received

- (void)windowWillClose:(NSNotification *)notif;

// Complementary functions to NSOutlineViewDelegate

- (BOOL)isTitleItem:(NSDictionary *)item;

// Subviews handling

- (void)switchView:(NSString *)newViewName;
- (void)populateSubviews;

@end


NSString * NSStringFromIndexPath(NSIndexPath *);
NSIndexPath * NSIndexPathFromString(NSString *);

NSDictionary * NSDictionaryFromRect(NSRect);
NSRect NSRectFromDictionary(NSDictionary *);
