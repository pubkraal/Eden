//
//  SQLView.h
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLBridge;

@interface SQLView : NSObject {
@private
    NSString * tableName;
	SQLBridge * bridge;
	
	NSArray * columns, * rows;
	
	NSArrayController * arrayController;

	BOOL containsData;
}

@property (readonly) NSString * tableName;
@property (readonly) SQLBridge * bridge;

@property (retain) NSArray * columns;
@property (retain) NSArray * rows;

@property (retain) NSArrayController * arrayController;

@property (assign) BOOL containsData;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName;
+ (id)viewWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName;

- (BOOL)loadValues;
- (void)doSetRows:(NSArray *)newRows;

// Readonly array acessors

- (NSUInteger)countOfRows;
- (id)objectInRowsAtIndex:(NSUInteger)idx;
- (NSUInteger)indexOfObjectInRows:(id)obj;

// UI

- (void)attachToTableView:(NSTableView *)view;
- (void)dettachFromTableView:(NSTableView *)view;
- (void)attachToArrayController:(NSArrayController *)controller andTableView:(NSTableView *)view;
- (void)dettachFromArrayController:(NSArrayController *)controller andTableView:(NSTableView *)view;
- (NSString *)titleForColumn:(NSString *)column;
- (NSDictionary *)bindingOptionsForArrayController;
- (NSDictionary *)bindingOptionsForColumn:(NSString *)column;
- (void)modifyPropertiesOfTableColumn:(NSTableColumn *)tableColumn forColumn:(NSString *)column;
- (void)modifyPropertiesOfArrayController:(NSArrayController *)controller;
- (void)modifyPropertiesOfTableView:(NSTableView *)tableView;

@end



