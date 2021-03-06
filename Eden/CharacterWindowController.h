//
//  CharacterDocument.h
//  Eden
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
	BOOL fullScreen;
	BOOL reloadEnabled;
	BOOL hasError;
	NSDictionary * errors;
	
	// Tasks
	NSMutableDictionary * taskCellControllers;
	NSMutableArray * tasks;
	NSPredicate * requiresFullAPIPred;
	NSArray * selectedTasks;

	// Timers
	NSTimer * skillTimer; 

}

@property (readonly) NSView * dynamicView;

@property (retain) NSString * activeViewName;
@property (retain) NSString * nextViewName;

@property (retain) NSMutableDictionary * taskCellControllers;
@property (retain) NSMutableArray * tasks;
@property (retain) NSArray * selectedTasks;
@property (retain) NSDictionary * subviews;

@property (assign) CharacterDocument * document;
@property (assign) BOOL reloadEnabled;
@property (assign) BOOL fullScreen;
@property (assign) BOOL hasError;
@property (retain) NSDictionary * errors;

@property (readonly) NSString * errorString;
@property (readonly) NSString * firstError;

@property (readonly) NSString * currentSkillFinishesIn;

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
- (void)autoReload:(NSNotification *)notification;
- (void)scheduleSkillTimer;
- (void)cancelSkillTimer;
- (IBAction)reloadPortrait:(id)sender;

// Notifications received

- (void)windowWillClose:(NSNotification *)notif;

// Complementary functions to NSOutlineViewDelegate

- (BOOL)isTitleItem:(NSDictionary *)item;

// Subviews handling

- (void)switchView:(NSString *)newViewName;
- (void)populateSubviews;
- (NSRect)windowFrameForTaskFrame:(NSRect)taskFrame;
- (void)saveSubviewsSizes;
- (void)replaceTaskSubview:(NSString *)newTaskName;

@end


NSString * NSStringFromIndexPath(NSIndexPath *);
NSIndexPath * NSIndexPathFromString(NSString *);

NSDictionary * NSDictionaryFromRect(NSRect);
NSRect NSRectFromDictionary(NSDictionary *);
