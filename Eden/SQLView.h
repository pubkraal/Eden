//
//  SQLView.h
//  Eden
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLBridge;

@interface SQLView : NSObject <NSCoding> {
@private
    NSString * tableName;
	SQLBridge * bridge;
	
	NSArray * columns, * rows;
	
	NSArrayController * arrayController;
	NSDictionary * metadata;
	NSArray * predicateEditorRowTemplates;
	NSArray * tableViewColumns;

	BOOL containsData;
}

@property (readonly) NSString * tableName;
@property (readonly) SQLBridge * bridge;

@property (retain) NSArray * columns;
@property (retain) NSArray * rows;

@property (retain) NSArrayController * arrayController;
@property (retain) NSDictionary * metadata;
@property (retain) NSArray * predicateEditorRowTemplates;
@property (readonly) NSArray * metadataArray;

@property (assign) BOOL containsData;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName;
+ (id)viewWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName;

- (BOOL)loadValues;
- (BOOL)loadMetadata;
- (void)doSetRows:(NSArray *)newRows;

// Readonly array acessors

- (NSUInteger)countOfRows;
- (id)objectInRowsAtIndex:(NSUInteger)idx;
- (NSUInteger)indexOfObjectInRows:(id)obj;

// Filtering

- (NSArray *)filteredRowsWithPredicate:(NSPredicate *)predicate;
- (NSArray *)filteredRowsWithPredicateFormat:(NSString *)format, ...;
- (NSArray *)generatePredicateEditorRowTemplates;

// UI

- (void)bindTableViewColumnsToController:(NSArrayController *)controller tableView:(NSTableView *)tableView;

- (void)attachToTableView:(NSTableView *)view;
- (void)dettach;
- (void)attachToArrayController:(NSArrayController *)controller andTableView:(NSTableView *)view;
- (void)dettachFromArrayController:(NSArrayController *)controller;

- (NSString *)titleForColumn:(NSString *)column;
- (NSDictionary *)bindingOptionsForArrayController;
- (NSDictionary *)bindingOptionsForColumn:(NSString *)column;
- (void)modifyPropertiesOfTableColumn:(NSTableColumn *)tableColumn forColumn:(NSString *)column;
- (void)modifyPropertiesOfArrayController:(NSArrayController *)controller;
- (void)modifyPropertiesOfTableView:(NSTableView *)tableView;

@end



