//
//  DumpNavigatorDelegate.m
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "DumpNavigatorDelegate.h"
#import "EveShip.h"
#import "EveDatabase.h"


@implementation DumpNavigatorDelegate

@synthesize win, parent, dataController, errorController, errors, predEdit, currentPred, tablesCell;
@synthesize filtersView, bridge, headerView, tableView, selectedView, metaTV, metaController;
@synthesize loadingControl, everythingEnabled, quickAccessSelected, quickAccessList, quickAccessCell, quickController;
@synthesize errorsView, columnsView;

- (id)init {
    if ((self = [super init])) {
		[self setBridge:nil];
		[self setSelectedView:nil];
		[self setErrors:[NSMutableArray array]];
		[self setCurrentPred:nil];
		[self setEverythingEnabled:false];
		[self setQuickAccessList:[NSMutableArray array]];
		[self setQuickAccessSelected:nil];
	}
    
    return self;
}

- (Class)classForTable:(NSString *)table {
	return [SQLTable class]; // Non-mutable
}

- (BOOL)shouldBuildLookupForTable:(NSString *)table {
	return NO;
}

- (void)awakeFromNib {
	self.bridge = [EveDatabase sharedBridge];

	[bridge addObserver:self forKeyPath:@"lastError" options:(NSKeyValueObservingOptionNew) context:nil];

	[self postAwakeFromNib:bridge];
	/*[loadingControl startAnimation:self];
	[self performSelectorInBackground:@selector(loadBridge:) withObject:nil];
	*/
}

- (void)loadBridge:(id)sender {
	NSError * sqlError;
	NSString * dbPath, * err;
	NSAutoreleasePool * pool;

	pool = [[NSAutoreleasePool alloc] init];

	sqlError = nil;
	err      = nil;
	dbPath   = [[NSBundle mainBundle] pathForResource:@"evedump_lite" ofType:@"db"];
	//dbPath   = [[NSBundle mainBundle] pathForResource:@"evedump" ofType:@"db"];
	
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

		[view dettach];
		[view attachToTableView:tableView];
		
	}
}

- (void)alertEnded:(NSAlert *)alert code:(int)choide context:(void *)context {
	//NSLog(@"finished failing");
}

- (void)postAwakeFromNib:(id)msg {
	NSAlert * alert;
	EveShip * ship;

	[loadingControl stopAnimation:self];
	[loadingControl setHidden:YES];

	if ([(NSObject *) msg isKindOfClass:[NSString class]]) {
		alert = [NSAlert alertWithMessageText:@"Error loading the database." defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:(NSString *)msg];
		[alert beginSheetModalForWindow:[self win] modalDelegate:self didEndSelector:@selector(alertEnded:code:context:) contextInfo:NULL];
		[(NSObject *) msg release];
	}
	else {
		[self setEverythingEnabled:YES];
		
		[dataController bind:@"contentArray" toObject:bridge withKeyPath:@"viewsValues" options:nil];

		[dataController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"tableName" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];

		
		[self addObserver:self forKeyPath:@"selectedView" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
		[self addObserver:self forKeyPath:@"currentPred" options:NSKeyValueObservingOptionNew context:nil];
		[self addObserver:self forKeyPath:@"quickAccessSelected" options:NSKeyValueObservingOptionNew context:nil];
		
		[self setSelectedView:[[[bridge viewsNames] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:0]];

		[tablesCell bind:@"content" toObject:dataController withKeyPath:@"arrangedObjects.tableName" options:nil];
		[tablesCell bind:@"selectedObject" toObject:self withKeyPath:@"selectedView" options:nil];
		
		[quickController setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]];
		[quickAccessCell bind:@"content" toObject:quickController withKeyPath:@"arrangedObjects" options:[NSDictionary dictionaryWithObject:@"Quick Access" forKey:NSNullPlaceholderBindingOption]];
		[quickAccessCell bind:@"selectedObject" toObject:self withKeyPath:@"quickAccessSelected" options:nil];

		[filtersView setBecomesKeyOnlyIfNeeded:YES];
		[filtersView setFloatingPanel:YES];
		[filtersView setReleasedWhenClosed:NO];

		[errorsView setBecomesKeyOnlyIfNeeded:YES];
		[errorsView setFloatingPanel:YES];
		[errorsView setReleasedWhenClosed:NO];

		[columnsView setBecomesKeyOnlyIfNeeded:YES];
		[columnsView setFloatingPanel:YES];
		[columnsView setReleasedWhenClosed:NO];

		ship = [EveShip shipWithBridge:bridge andShipID:[NSNumber numberWithInt:29984]];
		ship = [EveShip shipWithBridge:bridge andShipID:[NSNumber numberWithInt:17932]];
	}

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SQLView * newView, * oldView;
	id error, selected;
	NSPredicate * pred;

	if ([keyPath isEqualToString:@"selectedView"]) {
		newView = [[bridge views] objectForKey:[change objectForKey:NSKeyValueChangeNewKey]];
		oldView = [[bridge views] objectForKey:[change objectForKey:NSKeyValueChangeOldKey]];

		
		if (oldView) {
			[oldView dettach];

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

			if (![[self selectedView] isEqualToString:[self quickAccessSelected]] && [[self quickAccessList] indexOfObject:[self selectedView]] != NSNotFound) {
				[self setQuickAccessSelected:[self selectedView]];
			}
			else [self setQuickAccessSelected:nil];

			[columnsView setTitle:[NSString stringWithFormat:@"%@ columns", [self selectedView]]];
		}


	}
	else if ([keyPath isEqualToString:@"lastError"]) {
		error = [change objectForKey:NSKeyValueChangeNewKey];

		if (error != [NSNull null]) {
			[[self mutableArrayValueForKey:@"errors"] addObject:error];

			if (![errorsView isVisible]) [errorsView orderFront:nil];

		}
	}
	else if ([keyPath isEqualToString:@"currentPred"]) {
		newView = [[bridge views] objectForKey:[self selectedView]];
		
		if ([change objectForKey:NSKeyValueChangeNewKey] != [NSNull null]) {
			[[newView arrayController] setFilterPredicate:(NSPredicate *) [change objectForKey:NSKeyValueChangeNewKey]];
		}
		else [[newView arrayController] setFilterPredicate:nil];
	}
	else if ([keyPath isEqualToString:@"quickAccessSelected"]) {
		selected = [change objectForKey:NSKeyValueChangeNewKey];

		if (	(selected != [NSNull null]) && \
				![[self selectedView] isEqualToString:(NSString *)selected] &&\
				([[bridge viewsNames] indexOfObject:(NSString*)selected] != NSNotFound) ) {

			[self setSelectedView:(NSString *)selected];
		}
	}
}

- (void)dealloc {
	[self setBridge:nil];
	[self setSelectedView:nil];
	[self setErrors:nil];
	[self setCurrentPred:nil];
	[self setQuickAccessList:nil];
	[self setQuickAccessSelected:nil];
	
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

- (IBAction)toggleErrorsWindow:(id)sender {
	if ([errorsView isVisible]) [errorsView orderOut:sender];
	else [errorsView orderFront:sender];

}

- (IBAction)toggleColumnsWindow:(id)sender {
	if ([columnsView isVisible]) [columnsView orderOut:sender];
	else [columnsView orderFront:sender];

}

- (IBAction)addToQuickAccess:(id)sender {
	NSMutableArray * qaProxy;
	NSString * thisView;

	qaProxy  = [self mutableArrayValueForKey:@"quickAccessList"];
	thisView = [self selectedView];

	if ([qaProxy indexOfObject:thisView] == NSNotFound) {
		[qaProxy addObject:thisView];
		[self setQuickAccessSelected:thisView];
	}
}


- (IBAction)removeFromQuickAccess:(id)sender {
	NSMutableArray * qaProxy;
	NSString * thisView;

	qaProxy  = [self mutableArrayValueForKey:@"quickAccessList"];
	thisView = [self selectedView];

	if ([qaProxy indexOfObject:thisView] != NSNotFound) {
		[qaProxy removeObject:thisView];
		[self setQuickAccessSelected:nil];
	}
}

- (IBAction)clearPredicates:(id)sender {
	[self setCurrentPred:nil];
}

@end
