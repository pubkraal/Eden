//
//  DBTestDelegate.m
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "DBTestDelegate.h"


@implementation DBTestDelegate

@synthesize win, parent, dataController, errorController, errors, predEdit, currentPred, tablesCell;
@synthesize filtersView, bridge, headerView, tableView, selectedView, metaTV, metaController;
@synthesize loadingControl, everythingEnabled;

- (id)init {
    if ((self = [super init])) {
		[self setBridge:nil];
		[self setSelectedView:nil];
		[self setErrors:[NSMutableArray array]];
		[self setCurrentPred:nil];
		[self setEverythingEnabled:false];
	}
    
    return self;
}

- (Class)classForTable:(NSString *)table {
	return [SQLTable class]; // Non-mutable
}

- (BOOL)buildLookupForTable:(NSString *)table {
	return NO;
}

- (void)awakeFromNib {
	[loadingControl startAnimation:self];
	[self performSelectorInBackground:@selector(loadBridge:) withObject:nil];
}

- (void)loadBridge:(id)sender {
	NSError * sqlError;
	NSString * dbPath, * err;
	NSAutoreleasePool * pool;

	pool = [[NSAutoreleasePool alloc] init];

	sqlError = nil;
	err      = nil;
	dbPath   = [[NSBundle mainBundle] pathForResource:@"evedump_notrans_nomaps" ofType:@"db"];
	
	if (dbPath) {
		[self setBridge:[SQLBridge bridgeWithPath:dbPath error:&sqlError]];
		
		if (sqlError) {
			err = [NSString stringWithFormat:@"Error: %@\nCode: %lu", [[bridge lastError] localizedDescription], [[bridge lastError] code]];
		}

		[bridge setDelegate:self];
		[bridge addObserver:self forKeyPath:@"lastError" options:(NSKeyValueObservingOptionNew) context:nil];

		if (![bridge preloadViews]) {
			err = [NSString stringWithFormat:@"Error: %@\nCode: %lu", [[bridge lastError] localizedDescription], [[bridge lastError] code]];
		}
		
		[self loadBridgeValues:self];

	}
	else err = @"Path not found.";

	
	if (err) [err retain];
	[self performSelectorOnMainThread:@selector(postAwakeFromNib:) withObject:((err) ? err : bridge) waitUntilDone:NO];

	[pool drain];

}

- (void)loadBridgeValues:(id)sender {
	NSString * err;
	NSAutoreleasePool * pool;

	pool = [[NSAutoreleasePool alloc] init];

	err = nil;

	if (![bridge loadViewsValues]) {
		err = [NSString stringWithFormat:@"Error: %@\nCode: %lu", [[bridge lastError] localizedDescription], [[bridge lastError] code]];
	}
	
	if (sender != self) {
		if (err) [err retain];
		[self performSelectorOnMainThread:@selector(postBridgeValues:) withObject:err waitUntilDone:NO];
		[err release];
	}

	[pool drain];
}

- (void)postBridgeValues:(id)msg {
	NSString * err;
	SQLView * view;
	NSAlert * alert;

	err = (NSString *)msg;

	[loadingControl stopAnimation:self];
	[loadingControl setHidden:YES];

	if (err) {
		alert = [NSAlert alertWithMessageText:@"Error loading the database." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:err];
		[alert beginSheetModalForWindow:[self win] modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:NULL];
		[err release];
	}
	else {
		[self setEverythingEnabled:YES];	
		view = [[bridge views] objectForKey:[self selectedView]];

		[view dettachFromTableView:tableView];
		[view attachToTableView:tableView];
		
	}
}

- (void)alertEnded:(NSAlert *)alert code:(int)choide context:(void *)context {
	NSLog(@"finished failing");
}

- (void)postAwakeFromNib:(id)msg {
	NSAlert * alert;

	[loadingControl stopAnimation:self];
	[loadingControl setHidden:YES];

	if ([(NSObject *) msg isKindOfClass:[NSString class]]) {
		alert = [NSAlert alertWithMessageText:@"Error loading the database." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:(NSString *)msg];
		[alert beginSheetModalForWindow:[self win] modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:NULL];
		[(NSObject *) msg release];
	}
	else {
		[self setEverythingEnabled:YES];
		[bridge attachViewsToArrayController:dataController];
		[dataController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tableName" ascending:YES]]];
		
		[self addObserver:self forKeyPath:@"selectedView" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
		[self addObserver:self forKeyPath:@"currentPred" options:NSKeyValueObservingOptionNew context:nil];
		
		[self setSelectedView:[[[bridge viewsNames] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] objectAtIndex:0]];

		[tablesCell bind:@"content" toObject:dataController withKeyPath:@"arrangedObjects.tableName" options:nil];
		[tablesCell bind:@"selectedObject" toObject:self withKeyPath:@"selectedView" options:nil];

		[filtersView setBecomesKeyOnlyIfNeeded:YES];
		[filtersView setFloatingPanel:YES];

	}

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SQLView * newView, * oldView;
	id error;
	NSPredicate * pred;

	if ([keyPath isEqualToString:@"selectedView"]) {
		newView = [[bridge views] objectForKey:[change objectForKey:NSKeyValueChangeNewKey]];
		oldView = [[bridge views] objectForKey:[change objectForKey:NSKeyValueChangeOldKey]];

		
		if (oldView) {
			[oldView dettachFromTableView:tableView];

			if ([oldView respondsToSelector:@selector(metadataArray)]) [metaController unbind:@"contentArray"];
		}
		if (newView) {
			[newView attachToTableView:tableView];

			if ([newView respondsToSelector:@selector(metadataArray)]) [metaController bind:@"contentArray" toObject:newView withKeyPath:@"metadataArray" options:nil];
			
			pred = [[[newView arrayController] filterPredicate] retain];
			
			[self setCurrentPred:nil];
			[predEdit setRowTemplates:[newView predicateEditorRowTemplates]];
			[self setCurrentPred:pred];

			[pred release];
		}


	}
	else if ([keyPath isEqualToString:@"lastError"]) {
		error = [change objectForKey:NSKeyValueChangeNewKey];

		if (error != [NSNull null]) [[self mutableArrayValueForKey:@"errors"] addObject:error];
	}
	else if ([keyPath isEqualToString:@"currentPred"]) {
		newView = [[bridge views] objectForKey:[self selectedView]];
		
		if ([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) {
			[[newView arrayController] setFilterPredicate:(NSPredicate *) [change objectForKey:NSKeyValueChangeNewKey]];
		}
		else [[newView arrayController] setFilterPredicate:nil];
	}
}

- (void)dealloc {
	[self setBridge:nil];
	[self setSelectedView:nil];
	[self setErrors:nil];
	[self setCurrentPred:nil];
	
	[super dealloc];
}


- (IBAction)reloadValues:(id)sender {
	[loadingControl setHidden:NO];
	[loadingControl startAnimation:sender];
	[self setEverythingEnabled:NO];

	[self performSelectorInBackground:@selector(loadBridgeValues:) withObject:sender];

}


- (IBAction)toggleFiltersWindow:(id)sender {
	if ([filtersView isVisible]) [filtersView orderOut:sender];
	else [filtersView orderFront:sender];
}



@end
