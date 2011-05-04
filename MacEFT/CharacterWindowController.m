//
//  CharacterWindowController.m
//  MacEFT
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterWindowController.h"
#import "CharacterDocument.h"
#import <QuartzCore/CoreAnimation.h>
#import "CharacterViews.h"
#import "EveCharacter.h"

@implementation CharacterWindowController

@synthesize dynamicView, activeViewName, nextViewName, subviews, selectedTasks;

// Initialization

- (id)init {
    if ((self = [super initWithWindowNibName:@"Character"])) {

		requiresFullAPIPred = [[NSPredicate predicateWithFormat:@"requiresFullAPI == NO"] retain];


		[self setActiveViewName:nil];
		[self setNextViewName:nil];
		[self setSubviews:nil];
    }
    
    return self;
}

- (void)windowDidLoad {
	CAAnimation * newAnimation;
	NSString * startPath;
	
	// Presentation details

	[[self window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	[[self window] setContentBorderThickness:30 forEdge:NSMinYEdge];


	[characterInfo setView:characterInfoView];

	newAnimation = [CABasicAnimation animation];
	[newAnimation setDelegate:self];
	[[self window] setAnimations:[NSDictionary dictionaryWithObject:newAnimation forKey:@"frame"]];
	
	// Loading the task list

	startPath = (self.document.currentTask) ? self.document.currentTask : @"0.0";

	[self loadTasks];
	[self populateSubviews];
	[self addAllObservers];
	
	self.selectedTasks = [NSArray arrayWithObject:NSIndexPathFromString(startPath)];

	if (!self.document.character) [self showCharacterSelectionSheet];

}

- (void)addAllObservers {
	[self addObserver:self forKeyPath:@"selectedTasks" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self addObserver:self forKeyPath:@"document.character.fullAPI" options:NSKeyValueObservingOptionNew context:nil];

}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
	return [[self document] undoManager];
}

- (CharacterDocument *)document {
	return [super document];
}

- (void)setDocument:(CharacterDocument *)document {
	[super setDocument:document];
}

// Tasks functions


- (void)loadTasks {
	NSDictionary * item;
	NSString * tasksPath;
	NSDictionary * tasksDict;

	tasksPath = [[NSBundle mainBundle] pathForResource:@"CharacterTasks" ofType:@"plist"];
	tasksDict = [NSDictionary dictionaryWithContentsOfFile:tasksPath];

	[self setTasks:[NSMutableArray arrayWithArray:[tasksDict objectForKey:@"Tasks"]]];

	for (item in [[tasksController arrangedObjects] childNodes]){
		[tasksView expandItem:item expandChildren:NO];
	}
}


+ (NSMutableArray *)filteredTasks:(NSMutableArray *)tasks usingPredicate:(NSPredicate *)predicate {
	NSMutableArray * filtered, * children;
	NSMutableDictionary * dict;

	filtered = [NSMutableArray arrayWithArray:[tasks filteredArrayUsingPredicate:predicate]];
	
	for (dict in filtered) {
		children = [self filteredTasks:[dict objectForKey:@"children"] usingPredicate:predicate];
		[dict setObject:children forKey:@"children"];
	}

	return filtered;
}

- (NSMutableArray *)tasks {
	return tasks;
}

- (void)setTasks:(NSMutableArray *)newTasks {
	[tasks release];
	
	if (!self.document.character || self.document.character.fullAPI) tasks = [newTasks retain];
	else tasks = [[[self class] filteredTasks:newTasks usingPredicate:requiresFullAPIPred] retain];
}



// Actions


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"selectedTasks"]) {
		[self selectedTaskChangedFrom:(NSArray *) [change objectForKey:NSKeyValueChangeOldKey] to:(NSArray *) [change objectForKey:NSKeyValueChangeNewKey]];
	}
	else if ([keyPath isEqualToString:@"document.character.fullAPI"]) {
		[self fullAPIChangedTo:[[change objectForKey:NSKeyValueChangeOldKey] boolValue]];
	}
}

- (void)selectedTaskChangedFrom:(NSArray *)oldTaskPaths to:(NSArray *)newTaskPaths {
	NSIndexPath * newTaskPath;
	NSDictionary * newTask;
	
	if ((id) newTaskPath != [NSNull null]) {
		newTaskPath = [newTaskPaths objectAtIndex:0];
		newTask = (NSDictionary *) [[[tasksController arrangedObjects] descendantNodeAtIndexPath:newTaskPath] representedObject];
		
		[self switchView:(NSString *) [newTask objectForKey:@"view"]];

		[[self document] setCurrentTask:NSStringFromIndexPath(newTaskPath)];
	}
}

- (void)fullAPIChangedTo:(BOOL)fullAPI {
	NSArray * currentTasks;

	currentTasks = self.selectedTasks;
	[self loadTasks];
	[[[subviews objectForKey:[self activeViewName]] view] removeFromSuperview];
	self.activeViewName = nil;
	self.selectedTasks = currentTasks;
}

- (void)showCharacterSelectionSheet {
	[self.document showSheet:self.document.ccController];
}


// Notifications received

- (void)windowWillClose:(NSNotification *)notif {
	

	[[[subviews objectForKey:[self activeViewName]] view] removeFromSuperview];
	[self setSubviews:nil];

}


// Delegated methods from NSOutlineView

- (BOOL)isTitleItem:(NSDictionary *)item {
	return [[item objectForKey:@"groupItem"] boolValue];
}

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

// Subviews handling 

- (void)populateSubviews {
	EveViewController * viewController;
	NSMutableDictionary * mSubviews;
	NSDictionary * savedFrame;
	NSString * viewName;
	NSUInteger i;

	mSubviews = [NSMutableDictionary dictionary];

	
	for (i = 0; subviewsNames[i]; i++) {
		viewName       = [NSString stringWithUTF8String:subviewsNames[i]];
		viewController = [NSClassFromString(viewName) viewController];

		[viewController setDocument:[self document]];

		[mSubviews setValue:viewController
					 forKey:viewName];

		if (self.document.viewSizes && (savedFrame = [self.document.viewSizes objectForKey:viewName])) {
			[[viewController view] setFrame:NSRectFromDictionary(savedFrame)];
		}
	}

	[self setSubviews:[NSDictionary dictionaryWithDictionary:mSubviews]];
}


- (void)switchView:(NSString *)newViewName {
	NSView * newView, * activeView;
	NSViewController * newController;
	NSRect windowFrame, currentFrame, newDynFrame;

	newController = [[self subviews] objectForKey:newViewName];
	
	if (![self nextViewName] && newController) {
		newView = [newController view];

		if ([self activeViewName]) {
			activeView = [[[self subviews] objectForKey:[self activeViewName]] view];
			[activeView removeFromSuperview];
		}
		else activeView = nil;

		newDynFrame = [newView frame];
		
		newDynFrame.origin.x = 0;
		newDynFrame.origin.y = 0;
		
		[newView setFrame:newDynFrame];

		windowFrame  = [[self window] frame];
		currentFrame = [dynamicView frame];

		windowFrame.size.width  += newDynFrame.size.width - currentFrame.size.width;
		windowFrame.size.height += newDynFrame.size.height - currentFrame.size.height;
		windowFrame.origin.y    -= newDynFrame.size.height - currentFrame.size.height;

		if (activeView) {
			[self setNextViewName:newViewName];

			[[[self window] animator] setFrame:windowFrame display:YES];
		}
		else {
			[[self window] setFrame:windowFrame display:YES];
			[dynamicView addSubview:newView];

			[self setActiveViewName:newViewName];
		}
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if ([self nextViewName]) {
		[[self dynamicView] addSubview:[[[self subviews] objectForKey:[self nextViewName]] view]];

		[self setActiveViewName:[self nextViewName]];
		[self setNextViewName:nil];
	}
}


- (void)windowDidResize:(NSWindow *)window {
	__block NSMutableDictionary * windowSizes;


	if (self.subviews) {
		windowSizes = [NSMutableDictionary dictionary];

		[self.subviews enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSViewController * viewController, BOOL * stop) {
			[windowSizes setObject:NSDictionaryFromRect([[viewController view] frame]) forKey:key];
			
		}];
		
		self.document.viewSizes = [NSDictionary dictionaryWithDictionary:windowSizes];


	}
}


// Cleanup

- (void)dealloc {
	[requiresFullAPIPred release];

	[self setTasks:nil];
	[self setSubviews:nil];
	[self setActiveViewName:nil];
	[self setNextViewName:nil];

    [super dealloc];
}

@end

NSString * NSStringFromIndexPath(NSIndexPath * path) {
	NSMutableArray * pathArr;
	NSUInteger i;
	
	pathArr = [NSMutableArray array];

	if (!pathArr) return nil;

	for (i = 0; i < [path length]; i++) {
		[pathArr addObject:[NSNumber numberWithInteger:[path indexAtPosition:i]]];
	}
	
	return [pathArr componentsJoinedByString:@"."];
}

NSIndexPath * NSIndexPathFromString(NSString * str) {
	NSArray * pathArr;
	NSString * component;
	NSUInteger * indexes, count, i;
	NSIndexPath * path;

	pathArr = [str componentsSeparatedByString:@"."];
	count   = [pathArr count];
	indexes = calloc(sizeof(NSUInteger), count);

	for (i = 0; i < count; i++) {
		component = [pathArr objectAtIndex:i];

		if (!sscanf([component UTF8String], "%u", indexes + i)) {
			free(indexes);	
			return nil;
		}
	}

	path = [NSIndexPath indexPathWithIndexes:indexes length:count];

	free(indexes);
	
	return path;

}
NSDictionary * NSDictionaryFromRect(NSRect rect) {
	NSDictionary * rectDict;

	rectDict = [NSDictionary dictionaryWithObjectsAndKeys:
					[NSNumber numberWithDouble:(double) rect.origin.x], @"ox",
					[NSNumber numberWithDouble:(double) rect.origin.y], @"oy",
					[NSNumber numberWithDouble:(double) rect.size.width], @"sw",
					[NSNumber numberWithDouble:(double) rect.size.height], @"sh",
					nil];

	return rectDict;
}

NSRect NSRectFromDictionary(NSDictionary * rectDict) {
	CGFloat ox, oy, sw, sh;
	NSNumber * oxn, * oyn, * swn, * shn;

	oxn = [rectDict objectForKey:@"ox"];
	ox  = (oxn) ? (CGFloat) [oxn doubleValue] : 0.0;

	oyn = [rectDict objectForKey:@"oy"];
	oy  = (oyn) ? (CGFloat) [oyn doubleValue] : 0.0;

	swn = [rectDict objectForKey:@"sw"];
	sw  = (swn) ? (CGFloat) [swn doubleValue] : 0.0;

	shn = [rectDict objectForKey:@"sh"];
	sh  = (shn) ? (CGFloat) [shn doubleValue] : 0.0;
	
	return NSMakeRect(ox, oy, sw, sh);
}
