//
//  DumpNavigatorDelegate.h
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacEFTAppDelegate.h"
#import "SQLBridge.h"


@interface DumpNavigatorDelegate : NSObject <SQLBridgeDelegate> {
@private
	IBOutlet NSWindow * win;
	IBOutlet NSPanel * filtersView;
	IBOutlet NSPanel * errorsView;
	IBOutlet NSPanel * columnsView;
	IBOutlet NSPopUpButtonCell * tablesCell;
	IBOutlet NSPopUpButtonCell * quickAccessCell;
	IBOutlet NSWindowController * parent;
	IBOutlet NSArrayController * dataController;
	IBOutlet NSTableHeaderView * headerView;
	IBOutlet NSTableView * tableView;
	IBOutlet NSTableView * metaTV;
	IBOutlet NSArrayController * errorController;
	IBOutlet NSArrayController * metaController;
	IBOutlet NSArrayController * quickController;
	IBOutlet NSPredicateEditor * predEdit;
	IBOutlet NSProgressIndicator * loadingControl;

	NSPredicate * currentPred;
	NSMutableArray * errors;
	SQLBridge * bridge;
	NSString * selectedView;
	NSMutableArray * quickAccessList;
	NSString * quickAccessSelected;

	BOOL everythingEnabled;
}

@property (assign) NSWindow * win;
@property (assign) NSPanel * filtersView;
@property (assign) NSPanel * errorsView;
@property (assign) NSPanel * columnsView;
@property (assign) NSWindowController * parent;
@property (assign) NSArrayController * dataController;
@property (assign) NSArrayController * errorController;
@property (assign) NSArrayController * metaController;
@property (assign) NSArrayController * quickController;
@property (assign) NSTableHeaderView * headerView;
@property (assign) NSTableView * tableView;
@property (assign) NSTableView * metaTV;
@property (assign) NSPredicateEditor * predEdit;
@property (assign) NSPopUpButtonCell * tablesCell;
@property (assign) NSPopUpButtonCell * quickAccessCell;
@property (assign) NSProgressIndicator * loadingControl;

@property (retain) NSMutableArray * errors;
@property (retain) SQLBridge * bridge;
@property (retain) NSString * selectedView;
@property (retain) NSPredicate * currentPred;
@property (retain) NSString * quickAccessSelected;
@property (retain) NSMutableArray * quickAccessList;

@property (assign) BOOL everythingEnabled;

- (void)awakeFromNib;
- (void)loadBridge:(id)sender;
- (void)alertEnded:(NSAlert *)alert code:(int)choide context:(void *)context;
- (void)postAwakeFromNib:(id)msg;
- (void)loadBridgeValues:(id)sender;
- (void)postBridgeValues:(id)msg;
- (void)dealloc;

- (IBAction)reloadValues:(id)sender;
- (IBAction)toggleFiltersWindow:(id)sender;
- (IBAction)toggleErrorsWindow:(id)sender;
- (IBAction)toggleColumnsWindow:(id)sender;
- (IBAction)addToQuickAccess:(id)sender;
- (IBAction)removeFromQuickAccess:(id)sender;
- (IBAction)clearPredicates:(id)sender;
@end
