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


@class CharacterDocumentDelegate;

@interface CharacterDocument : NSPersistentDocument <NSSplitViewDelegate, NSOutlineViewDelegate> {
@private
	// Interface Elements
	IBOutlet NSToolbarItem * characterInfo;
	IBOutlet NSView * characterInfoView;
	IBOutlet NSOutlineView * tasksView;
	IBOutlet NSTreeController * tasksController;
	IBOutlet NSView * dynamicView;
	IBOutlet NSWindow * mainWindow;

	// Other views
	IBOutlet NSView * infoView;
	IBOutlet NSView * skillsView;

	NSView * currentView;
	NSView * nextView;

	// Interface data
	NSMutableArray * tasks;
	
	// Tasks
	NSIndexPath * selectedTask;
	CharacterDocumentDelegate * delegate;

}

@property (assign) NSView * currentView;
@property (assign) NSView * nextView;

@property (readonly) NSWindow * mainWindow;
@property (readonly) NSView * dynamicView;
@property (readonly) NSView * infoView, * skillsView;

@property (retain) CharacterDocumentDelegate * delegate;
@property (retain) NSMutableArray * tasks;
@property (retain) NSIndexPath * selectedTask;


- (BOOL)isTitleItem:(NSDictionary *)item;

- (void)selectedTaskChangedFrom:(NSArray *)oldTaskPaths to:(NSArray *)newTaskPaths;
- (void)switchView:(NSView *)newView;

@end


@interface CharacterDocumentDelegate : NSObject {


}

+ (id)characterDocumentDelegate;

- (void)showInfo:(CharacterDocument *)doc;
- (void)showSkills:(CharacterDocument *)doc;

@end
