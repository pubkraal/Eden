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


@interface DBTestDelegate : NSObject <SQLBridgeDelegate> {
@private
	IBOutlet NSWindow * win;
	IBOutlet NSWindowController * parent;
	IBOutlet NSArrayController * dataController;
	IBOutlet NSTableHeaderView * headerView;
	IBOutlet NSTableView * tableView;
	IBOutlet NSTableView * metaTV;
	IBOutlet NSArrayController * errorController;
	IBOutlet NSArrayController * metaController;
	NSMutableArray * data;
	NSMutableArray * errors;
	SQLBridge * bridge;
	NSString * selectedView;
}

@property (assign) NSWindow * win;
@property (assign) NSWindowController * parent;
@property (assign) NSArrayController * dataController;
@property (assign) NSArrayController * errorController;
@property (assign) NSArrayController * metaController;
@property (assign) NSTableHeaderView * headerView;
@property (assign) NSTableView * tableView;
@property (assign) NSTableView * metaTV;
@property (retain) NSString * selectedView;

@property (retain) NSMutableArray * errors;
@property (retain) NSMutableArray * data;
@property (retain) SQLBridge * bridge;

- (void)awakeFromNib;
- (void)dealloc;

- (IBAction)reloadValues:(id)sender;
- (void)attachMetadata:(SQLTable *)table;
- (void)dettachMetadata:(SQLTable *)table;

@end
