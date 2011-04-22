//
//  DBTestDelegate.h
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacEFTAppDelegate.h"
#import "SQLBridge.h"


@interface DBTestDelegate : NSObject {
@private
	IBOutlet NSWindow * win;
	IBOutlet NSWindowController * parent;
	IBOutlet NSArrayController * dataController;
	IBOutlet NSTableHeaderView * headerView;
	IBOutlet NSTableView * tableView;
	NSMutableArray * data;
	SQLBridge * bridge;
	NSString * selectedView;
}

@property (assign) NSWindow * win;
@property (assign) NSWindowController * parent;
@property (assign) NSArrayController * dataController;
@property (assign) NSTableHeaderView * headerView;
@property (assign) NSTableView * tableView;
@property (retain) NSString * selectedView;

@property (retain) NSMutableArray * data;
@property (retain) SQLBridge * bridge;

- (void)awakeFromNib;
- (void)dealloc;

@end
