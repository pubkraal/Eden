//
//  DBTestDelegate.m
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "DBTestDelegate.h"


@implementation DBTestDelegate

@synthesize win, parent, data, dataController, bridge, headerView, tableView, selectedView;

- (id)init {
	NSError * sqlError;
	NSString * dbPath;

    if ((self = [super init])) {
		[self setBridge:nil];
		[self setSelectedView:nil];

		sqlError = nil;
		dbPath   = [[NSBundle mainBundle] pathForResource:@"evedump" ofType:@"db"];
		
		if (dbPath) {
			[self setBridge:[SQLBridge bridgeWithPath:dbPath error:&sqlError]];
			
			if (sqlError) {
				NSLog(@"Error: %@\nCode: %lu", [sqlError localizedDescription], [sqlError code]);
			}

			if (![bridge preloadViews]) {
				sqlError = [bridge lastError];
				NSLog(@"Error: %@\nCode: %lu", [sqlError localizedDescription], [sqlError code]);
			}
			
			if (![bridge loadViewsValues]) {
				sqlError = [bridge lastError];
				NSLog(@"Error: %@\nCode: %lu", [sqlError localizedDescription], [sqlError code]);
			}
		}
		else NSLog(@"Path not found.");
	}
    
    return self;
}

- (void)awakeFromNib {
	[bridge attachViewsToArrayController:dataController];
	
	[self addObserver:self forKeyPath:@"selectedView" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
	[self setSelectedView:@"dummy_full_roles"];
	
	//view = [bridge valueForKeyPath:@"views.dummy_full_roles"];
	
	//[view bindToArrayController:dataController andTableView:tableView];
	
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SQLView * newView, * oldView;

	if ([keyPath isEqualToString:@"selectedView"]) {
		newView = [[bridge views] objectForKey:[change objectForKey:NSKeyValueChangeNewKey]];
		oldView = [[bridge views] objectForKey:[change objectForKey:NSKeyValueChangeOldKey]];
		
		if (oldView) [oldView dettachFromTableView:tableView];
		if (newView) [newView attachToTableView:tableView];
	}
}

- (void)dealloc {
	[self setBridge:nil];
	[self setSelectedView:nil];
	
	[super dealloc];
}


@end
