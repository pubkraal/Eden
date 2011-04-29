//
//  CharacterDocument.m
//  MacEFT
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterDocument.h"
#import <QuartzCore/CoreAnimation.h>

@implementation CharacterDocument

@synthesize delegate, tasks, selectedTask, mainWindow, dynamicView, currentView, nextView;
@synthesize infoView, skillsView;

- (id)init {
	NSString * tasksPath;
	NSDictionary * tasksDict;

    if ((self = [super init])) {
		tasksPath = [[NSBundle mainBundle] pathForResource:@"CharacterTasks" ofType:@"plist"];
		tasksDict = [NSDictionary dictionaryWithContentsOfFile:tasksPath];

		tasks = [[NSMutableArray alloc] initWithArray:[tasksDict objectForKey:@"Tasks"]];

		[self setSelectedTask:nil];
		[self setDelegate:[CharacterDocumentDelegate characterDocumentDelegate]];
		[self setCurrentView:nil];
		[self setNextView:nil];
    }
    
    return self;
}

- (BOOL)isTitleItem:(NSDictionary *)item {
	return [[item objectForKey:@"groupItem"] boolValue];
}

- (NSString *)windowNibName {
	return @"Character";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller {
	NSWindow * window;
	NSDictionary * item;
	NSUInteger tempIndexes[2];
	CAAnimation * newAnimation;

	window = [controller window];

	if (window == mainWindow) {
		[window setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
		[window setContentBorderThickness:30 forEdge:NSMinYEdge];

		[characterInfo setView:characterInfoView];

		[self addObserver:self forKeyPath:@"selectedTask" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];

		for (item in [[tasksController arrangedObjects] childNodes]){
			[tasksView expandItem:item expandChildren:NO];
		}

		newAnimation = [CABasicAnimation animation];
		[newAnimation setDelegate:self];
		[mainWindow setAnimations:[NSDictionary dictionaryWithObject:newAnimation forKey:@"frame"]];
		

		// TODO: remember user preference!
		memset(tempIndexes, 0, sizeof(NSUInteger) * 2);
		[tasksController setSelectionIndexPath:[NSIndexPath indexPathWithIndexes:tempIndexes length:2]];


	}
	
}

// Actions


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"selectedTask"]) {
		[self selectedTaskChangedFrom:(NSArray *) [change objectForKey:NSKeyValueChangeOldKey] to:(NSArray *) [change objectForKey:NSKeyValueChangeNewKey]];
	}
}

- (void)selectedTaskChangedFrom:(NSArray *)oldTaskPaths to:(NSArray *)newTaskPaths {
	NSIndexPath * newTaskPath;
	NSDictionary * newTask;
	SEL delegateSelector;

	if (newTaskPaths) {
		newTaskPath = [newTaskPaths objectAtIndex:0];
		newTask     = (NSDictionary *) [[[tasksController arrangedObjects] descendantNodeAtIndexPath:newTaskPath] representedObject];

		delegateSelector = NSSelectorFromString([newTask objectForKey:@"selector"]);
	
		if ([delegate respondsToSelector:delegateSelector]) {
			[delegate performSelector:delegateSelector withObject:self];
		}
	}
}

// Delegated methods from NSOutlineView

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
	return [self isTitleItem:[item representedObject]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
	return ![self isTitleItem:[item representedObject]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item {
	return ![self isTitleItem:[item representedObject]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
	return ![self isTitleItem:[item representedObject]];
}

// View mess :(

- (void)switchView:(NSView *)newView {
	NSRect windowFrame, currentFrame, newDynFrame;
	
	if (![self nextView]) {
		if (currentView) {
			[currentView removeFromSuperview];
		}

		newDynFrame = [newView frame];
		
		newDynFrame.origin.x = 0;
		newDynFrame.origin.y = 0;
		
		[newView setFrame:newDynFrame];

		windowFrame  = [mainWindow frame];
		currentFrame = [dynamicView frame];

		windowFrame.size.width  += newDynFrame.size.width - currentFrame.size.width;
		windowFrame.size.height += newDynFrame.size.height - currentFrame.size.height;
		windowFrame.origin.y    -= newDynFrame.size.height - currentFrame.size.height;

		if (currentView) {
			[self setNextView:newView];

			[[mainWindow animator] setFrame:windowFrame display:YES];
		}
		else {
			[mainWindow setFrame:windowFrame display:YES];
			[dynamicView addSubview:newView];

			[self setCurrentView:newView];
		}

	}



}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if ([self nextView]) {
		[[self dynamicView] addSubview:[self nextView]];

		[self setCurrentView:[self nextView]];
		[self setNextView:nil];
	}
}


// Cleanup

- (void)dealloc {
	[self setTasks:nil];
	[self setSelectedTask:nil];
	[self setDelegate:nil];

    [super dealloc];
}

@end


@implementation CharacterDocumentDelegate

+ (id)characterDocumentDelegate {
	return [[[self alloc] init] autorelease];
}

- (void)showInfo:(CharacterDocument *)doc {
	[doc switchView:[doc infoView]];
}

- (void)showSkills:(CharacterDocument *)doc {
	[doc switchView:[doc skillsView]];
}

@end
