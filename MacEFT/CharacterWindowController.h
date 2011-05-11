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
	IBOutlet NSToolbarItem * characterInfo;
	IBOutlet NSView * characterInfoView;
	IBOutlet NSOutlineView * tasksView;
	IBOutlet NSTreeController * tasksController;
	IBOutlet NSView * dynamicView;

	// Other views
	NSDictionary * subviews;

	NSString * activeViewName;
	NSString * nextViewName;

	// Interface data
	NSMutableArray * tasks;
	
	// Tasks
	NSPredicate * requiresFullAPIPred;

	NSArray * selectedTasks;
	

}

@property (readonly) NSView * dynamicView;

@property (retain) NSString * activeViewName;
@property (retain) NSString * nextViewName;

@property (retain) NSMutableArray * tasks;
@property (retain) NSArray * selectedTasks;
@property (retain) NSDictionary * subviews;


@property (assign) CharacterDocument * document;

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
