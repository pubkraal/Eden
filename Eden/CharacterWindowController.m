//
//  CharacterWindowController.m
//  Eden
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterWindowController.h"
#import "CharacterDocument.h"
#import <QuartzCore/CoreAnimation.h>
#import "CharacterViews.h"
#import "EveCharacter.h"
#import "EveSkill.h"
#import "EveAPI.h"
#import "CharacterCreateSheetController.h"
#import "CharacterReloadController.h"
#import "TaskCell.h"
#import "TaskCellController.h"

@implementation CharacterWindowController

@synthesize dynamicView, activeViewName, nextViewName, subviews, selectedTasks;
@synthesize fullScreen, reloadEnabled, hasError, errors, taskCellControllers;

// Initialization

- (id)init {
	NSNotificationCenter * nc;
	if ((self = [super initWithWindowNibName:@"Character"])) {
		requiresFullAPIPred = [[NSPredicate predicateWithFormat:@"requiresFullAPI == NO"] retain];
		skillTimer          = nil;
		
		[self setActiveViewName:nil];
		[self setNextViewName:nil];
		[self setSubviews:nil];
		[self setFullScreen:NO];
		[self setReloadEnabled:YES];
		[self setHasError:NO];
		[self setErrors:nil];
		[self setTaskCellControllers:[NSMutableDictionary dictionary]];
		
		nc = [NSNotificationCenter defaultCenter];
		
		[nc addObserver:self selector:@selector(autoReload:) name:EveAPICacheClearedNotification object:nil];
    }
    
    return self;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notif {
	self.fullScreen = YES;
}


- (void)windowDidExitFullScreen:(NSNotification *)notif {
	NSRect currentFrame, savedFrame, windowFrame;
	NSView * activeView;
	BOOL taskChangedInFullScreen;
	
	self.fullScreen = NO;

	currentFrame = dynamicView.frame;
	savedFrame   = NSRectFromDictionary([self.document.viewSizes objectForKey:activeViewName]);

	taskChangedInFullScreen = (savedFrame.size.width != currentFrame.size.width) || (savedFrame.size.height != currentFrame.size.height);

	if (taskChangedInFullScreen) {
		activeView = [[subviews objectForKey:activeViewName] view];

		[activeView removeFromSuperview];
	}

	[self.document.viewSizes enumerateKeysAndObjectsUsingBlock:^(id key, NSDictionary * rect, BOOL * stop) {
		[[subviews objectForKey:key] view].frame = NSRectFromDictionary(rect);
	}];

	if (taskChangedInFullScreen) {
		self.nextViewName = activeViewName;
		
		windowFrame = [self windowFrameForTaskFrame:savedFrame];

		[[[self window] animator] setFrame:windowFrame display:YES];
	}
}

- (void)windowDidLoad {
	CAAnimation * newAnimation;
	NSString * startPath;
	
	[super windowDidLoad];
	
	// Presentation details

	[characterInfoItem setView:characterInfoView];
	[trainingSkillItem setView:trainingSkillView];
	[reloadItem setView:reloadView];

	newAnimation = [CABasicAnimation animation];
	[newAnimation setDelegate:self];
	[[self window] setAnimations:[NSDictionary dictionaryWithObject:newAnimation forKey:@"frame"]];

	// Loading the task list

	startPath = (self.document.currentTask) ? self.document.currentTask : @"0.0";

	[self loadTasks];
	[self populateSubviews];
	[self addAllObservers];
	
	self.selectedTasks = [NSArray arrayWithObject:NSIndexPathFromString(startPath)];

	if (!self.document.character) {
		[self saveSubviewsSizes];
		[self showCharacterSelectionSheet];
	}
	else {
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reloadOnFileOpened"]) [self.document showSheet:self.document.reloadController];
		else [self scheduleSkillTimer];
	}


}

- (void)addAllObservers {
	[self addObserver:self forKeyPath:@"selectedTasks" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	[self addObserver:self forKeyPath:@"document.character.fullAPI" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)removeAllObservers {
	[self removeObserver:self forKeyPath:@"selectedTasks"];
	[self removeObserver:self forKeyPath:@"document.character.fullAPI"];
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
	TaskCellController * controller;

	tasksPath = [[NSBundle mainBundle] pathForResource:@"CharacterTasks" ofType:@"plist"];
	tasksDict = [NSDictionary dictionaryWithContentsOfFile:tasksPath];

	[self setTasks:[NSMutableArray arrayWithArray:[tasksDict objectForKey:@"Tasks"]]];

	for (item in [[tasksController arrangedObjects] childNodes]){
		[tasksView expandItem:item expandChildren:NO];
	}
	
	for (controller in [taskCellControllers allValues]) {
		// Force the cells to be redrawn to avoid overlaps
		
		[controller removeSubviews];
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
	if (!self.document.character || self.document.character.fullAPI) [newTasks retain];
	else newTasks = [[[self class] filteredTasks:newTasks usingPredicate:requiresFullAPIPred] retain];

	[tasks release];
	tasks = newTasks;
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
	
	if ((id) newTaskPaths != [NSNull null]) {
		newTaskPath = [newTaskPaths objectAtIndex:0];
		newTask = (NSDictionary *) [[[tasksController arrangedObjects] descendantNodeAtIndexPath:newTaskPath] representedObject];
		
		[[self document] setCurrentTask:NSStringFromIndexPath(newTaskPath)];
		if (self.activeViewName) [self.document updateChangeCount:NSChangeDone];

		[self switchView:(NSString *) [newTask objectForKey:@"view"]];
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
	CharacterCreateSheetController * ccController;

	ccController = [[CharacterCreateSheetController alloc] init];

	[self.document addWindowController:ccController];

	[self.document showSheet:ccController];

	[ccController release];
}

- (IBAction)performReload:(id)sender {
	[self cancelSkillTimer];
	self.document.reloadController.reloadType = kReloadData;
	[self.document showSheet:self.document.reloadController];
}

- (void)autoReload:(NSNotification *)notification {
	NSUserDefaults * prefs;
	NSDictionary * info;
	NSString * call;

	prefs = [NSUserDefaults standardUserDefaults];
	
	if ([prefs boolForKey:@"reloadWhenCacheExpires"] && self.document.character) {
		info = [notification userInfo];

		if ([[info objectForKey:EveAPICacheAccountKey] isEqualToString:self.document.character.accountID] &&
			[[info objectForKey:EveAPICacheCharacterKey] isEqualToString:self.document.character.characterID] ) {
			
			call = [info objectForKey:EveAPICacheCallKey];
			
			NSLog(@"Call %@ for %@", call, self.document.character.name);
		}
	}
}

- (void)scheduleSkillTimer {
	[self cancelSkillTimer];
	
	skillTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
												  target:self.document.character
												selector:@selector(updateSkillInTraining:)
												userInfo:nil
												 repeats:YES];
}

- (void)cancelSkillTimer {
	NSTimer * oldTimer;
	
	if (skillTimer) {
		oldTimer   = skillTimer;
		skillTimer = nil;

		[oldTimer invalidate];
	}
}

- (IBAction)reloadPortrait:(id)sender {
	self.document.reloadController.reloadType = kReloadPortrait;
	[self.document showSheet:self.document.reloadController];
}


// Notifications received

- (void)windowWillClose:(NSNotification *)notif {
	NSNotificationCenter * nc;
	EveViewController * view;

	[self.document removeReloadController];
	
	[[[subviews objectForKey:[self activeViewName]] view] removeFromSuperview];
	
	for (view in [subviews allValues]) [view documentWillClose];
	
	[self setSubviews:nil];
	
	[self removeAllObservers];
	[[self window] setAnimations:nil];
	
	nc = [NSNotificationCenter defaultCenter];
	
	[nc removeObserver:self name:EveAPICacheClearedNotification object:nil];

}

// Delegated methods

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


- (void)outlineView:(NSOutlineView *)view willDisplayCell:(id)cellObject forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSDictionary * node;
	TaskCellController * controller;
	TaskCell * cell;
	
	if ([cellObject isKindOfClass:[TaskCell class]]) {
		cell = (TaskCell *) cellObject;
		node = [item representedObject];

		controller = [taskCellControllers objectForKey:node];

		if (!controller) {
			controller = [TaskCellController controllerWithNode:node];
			controller.document = self.document;
			[taskCellControllers setObject:controller forKey:node];
		}

		cell.controller = controller;
	}
}

- (NSCell *)outlineView:(NSOutlineView *)view dataCellForTableColumn:(NSTableColumn *)column item:(id)item {
	NSDictionary * node;
	NSCell * cell;
	
	node = [item representedObject];
	cell = (![[node objectForKey:@"groupItem"] boolValue]) ? [TaskCell cell] : [column dataCellForRow:-1];
	
	return cell;
}

/*- (CGFloat)outlineView:(NSOutlineView *)view heightOfRowByItem:(id)item {
	NSDictionary * node;
	CGFloat height;
	
	node   = [item representedObject];
	height = ([[node objectForKey:@"leaf"] boolValue]) ? 42.0 : 19.0;
	
	return height;
}*/



- (BOOL)shouldCascadeWindows {
	return NO;
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

		newDynFrame = (self.document.viewSizes) ? NSRectFromDictionary([self.document.viewSizes objectForKey:newViewName]) : dynamicView.frame;
		
		newDynFrame.origin.x = 0;
		newDynFrame.origin.y = 0;
		
		[newView setFrame:newDynFrame];

		windowFrame = [self windowFrameForTaskFrame:newDynFrame];

		if (activeView) {
			if (!self.fullScreen) {
				[self setNextViewName:newViewName];
				
				//[self replaceTaskSubview:newViewName];
				[[[self window] animator] setFrame:windowFrame display:YES];
			}
			else {
				/*newDynFrame = dynamicView.frame;
				newDynFrame.origin.x = 0;
				newDynFrame.origin.y = 0;*/

				newDynFrame.size.width  = dynamicView.frame.size.width;
				newDynFrame.size.height = dynamicView.frame.size.height;
				
				[newView setFrame:newDynFrame];

				[dynamicView addSubview:newView];

				[self setActiveViewName:newViewName];
			}
		}
		else {
			if (self.document.windowOrigin) {
				windowFrame.origin.y = [[self.document.windowOrigin objectForKey:@"y"] integerValue];
				windowFrame.origin.x = [[self.document.windowOrigin objectForKey:@"x"] integerValue];
			}
			
			[[self window] setFrame:windowFrame display:YES];
			[dynamicView addSubview:newView];

			[self setActiveViewName:newViewName];
		}
	}
}

- (NSRect)windowFrameForTaskFrame:(NSRect)taskFrame {
	NSRect windowFrame, dynamicFrame;

	dynamicFrame = dynamicView.frame;
	windowFrame  = [self window].frame;

	windowFrame.size.width  += taskFrame.size.width  - dynamicFrame.size.width;
	windowFrame.size.height += taskFrame.size.height - dynamicFrame.size.height;
	windowFrame.origin.y    -= taskFrame.size.height - dynamicFrame.size.height;

	return windowFrame;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if ([self nextViewName]) {
		[[self dynamicView] addSubview:[[[self subviews] objectForKey:[self nextViewName]] view]];

		[self setActiveViewName:[self nextViewName]];
		[self setNextViewName:nil];
		[self windowDidMove:nil];
	}
}

- (void)saveSubviewsSizes {
	__block NSMutableDictionary * windowSizes;
	
	windowSizes = [NSMutableDictionary dictionary];

	[self.subviews enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSViewController * viewController, BOOL * stop) {
		[windowSizes setObject:NSDictionaryFromRect([[viewController view] frame]) forKey:key];
			
	}];

	self.document.viewSizes = [NSDictionary dictionaryWithDictionary:windowSizes];
}

- (void)replaceTaskSubview:(NSString *)newTaskName {
	NSView * currentTask, * nextTask;

	currentTask = [[subviews objectForKey:activeViewName] view];
	nextTask    = [[subviews objectForKey:newTaskName] view];

	[[dynamicView animator] replaceSubview:currentTask with:nextTask];

	self.activeViewName = newTaskName;
}

- (void)windowDidResize:(NSNotification *)notification {
	if (self.subviews && !self.fullScreen) {
		[self saveSubviewsSizes];
		
		if (self.activeViewName) [self.document updateChangeCount:NSChangeDone];
	}
}

- (void)windowDidMove:(NSNotification *)notification {
	NSNumber * x, * y;
	NSRect frame;
	
	if (!self.fullScreen) {
		frame = [self window].frame;

		x = [NSNumber numberWithInteger:frame.origin.x];
		y = [NSNumber numberWithInteger:frame.origin.y];

		self.document.windowOrigin = [NSDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil];

		if (self.activeViewName) [self.document updateChangeCount:NSChangeDone];
	}
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	if (self.document.character && [self.document fileURL]) {
		displayName = [NSString stringWithFormat:@"%@ (%@)", self.document.character.name, displayName];
	}
	
	return displayName;
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	BOOL enabled;
	
	enabled = YES;
	
	if (([menuItem tag] == 1) || ([menuItem tag] == 2)) {
		enabled = reloadEnabled;
	}
	
	return enabled;
}

// Etc

- (NSString *)currentSkillFinishesIn {
	EveSkill * skill;
	
	skill = self.document.character.skillInTraining;

	return (skill) ? [NSString stringWithFormat:@"Finishes in %@.", skill.finishesIn] : nil;
}

// Errors

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"errorString"]) {
		rootKeys = [NSSet setWithObject:@"errors"];
	}
	else if ([dependentKey isEqualToString:@"firstError"]) {
		rootKeys = [NSSet setWithObject:@"errors"];
	}
	else if ([dependentKey isEqualToString:@"currentSkillFinishesIn"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining.finishesIn"];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}

- (NSString *)errorString {
	NSMutableArray * errorDescriptions;
	NSError * error;
	NSString * key;
	
	errorDescriptions = [NSMutableArray array];
	
	for (key in errors) {
		error = [errors objectForKey:key];
		NSLog(@"%@", error);
		[errorDescriptions addObject:[NSString stringWithFormat:@"(%@) Error %d: %@", key, [error code], [error localizedDescription]]];
	}
	
	return [errorDescriptions componentsJoinedByString:@"\n"];
}

- (NSString *)firstError {
	NSString * firstError;
	
	if ([errors count] > 0) firstError = [[[errors allValues] objectAtIndex:0] localizedDescription];
	else firstError = nil;
	
	return firstError;
}

// Cleanup

- (void)dealloc {
	[requiresFullAPIPred release];
	
	tasksView.delegate = nil;
	/* WTF, Cocoa?! I shouldn't be responsible for cleaning delegates that
	 * were set in the Interface Builder! But if I don't this, tasksView
	 * goes apeshit calling methods on CharacterWindowController's zombie
	 * left and right.
	 */
	
	if (skillTimer) [skillTimer invalidate];
	
	[self setTaskCellControllers:nil];
	[self setTasks:nil];
	[self setSubviews:nil];
	[self setActiveViewName:nil];
	[self setNextViewName:nil];
	[self setErrors:nil];

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
