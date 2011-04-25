//
//  DBTestDelegate.m
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "DBTestDelegate.h"


@implementation DBTestDelegate

@synthesize win, parent, data, dataController, errorController, errors, bridge, headerView, tableView, selectedView, metaTV, metaController;

- (id)init {
	NSError * sqlError;
	NSString * dbPath;

    if ((self = [super init])) {
		[self setBridge:nil];
		[self setSelectedView:nil];
		[self setErrors:[NSMutableArray array]];
		
		sqlError = nil;
		dbPath   = [[NSBundle mainBundle] pathForResource:@"evedump_notrans_nomaps" ofType:@"db"];
		
		if (dbPath) {
			[self setBridge:[SQLBridge bridgeWithPath:dbPath error:&sqlError]];
			
			if (sqlError) {
				NSLog(@"Error: %@\nCode: %lu", [sqlError localizedDescription], [sqlError code]);
			}

			[bridge setDelegate:self];

			if (![bridge preloadViews]) {
				sqlError = [bridge lastError];
				NSLog(@"Error: %@\nCode: %lu", [sqlError localizedDescription], [sqlError code]);
			}
			
			if (![bridge loadViewsValues]) {
				sqlError = [bridge lastError];
				NSLog(@"Error: %@\nCode: %lu", [sqlError localizedDescription], [sqlError code]);
			}

			[bridge addObserver:self forKeyPath:@"lastError" options:(NSKeyValueObservingOptionNew) context:nil];
		}
		else NSLog(@"Path not found.");
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
	[bridge attachViewsToArrayController:dataController];
	
	[self addObserver:self forKeyPath:@"selectedView" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
	[self setSelectedView:[[[bridge views] allKeys] objectAtIndex:0]];

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SQLView * newView, * oldView;
	id error;

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
		}


	}
	else if ([keyPath isEqualToString:@"lastError"]) {
		error = [change objectForKey:NSKeyValueChangeNewKey];

		if (error != [NSNull null]) [[self mutableArrayValueForKey:@"errors"] addObject:error];
	}
}

- (void)dealloc {
	[self setBridge:nil];
	[self setSelectedView:nil];
	[self setErrors:nil];
	
	[super dealloc];
}


- (IBAction)reloadValues:(id)sender {
	SQLView * view;
	
	[bridge loadViewsValues];
	view = [[bridge views] objectForKey:[self selectedView]];

	[view dettachFromTableView:tableView];
	[view attachToTableView:tableView];
}


- (void)attachMetadata:(SQLTable *)table {
	
	
}

- (void)dettachMetadata:(SQLTable *)table {

}

@end
