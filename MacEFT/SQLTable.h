//
//  SQLTable.h
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLBridge.h"

@class SQLBridge;

@interface SQLTable : SQLView {
@private
    NSMutableArray * mutableRows;
	NSDictionary * metadata;
	NSString * numericPrimaryKey, * primaryKey;
	NSLock * databaseAccessLock;
}

@property (retain) NSMutableArray * rows;
@property (retain) NSDictionary * metadata;
@property (retain) NSString * numericPrimaryKey;
@property (retain) NSString * primaryKey;

// Initializers

- (void)autoObserveRows:(NSArray *)rows;

// Primitive Foreign Key

- (NSObject *)referenceForRow:(NSMutableDictionary *)row;
- (NSObject *)referenceForRowAtIndex:(NSUInteger)idx;

// SQL Interface

- (BOOL)performInsertRow:(NSMutableDictionary *)row;
- (BOOL)performDeleteRow:(NSMutableDictionary *)row;
- (BOOL)performUpdateRow:(NSMutableDictionary *)row withValue:(NSObject *)value forKey:(NSString *)key;

// Convenience functions for insertion

- (NSMutableDictionary *)emptyRow;
- (NSMutableDictionary *)newRow;

// Array accessors

- (NSUInteger)countOfRows;
- (id)objectInRowsAtIndex:(NSUInteger)idx;
- (void)insertObject:(id)anObject inRowsAtIndex:(NSUInteger)idx;
- (void)insertInRows:(id)anObject;
- (void)removeObjectFromRowsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRowsAtIndex:(NSUInteger)idx withObject:(id)anObject;
- (NSUInteger)indexOfObjectInRows:(id)obj;

// Observer convenience functions

- (void)addObserverForRow:(NSMutableDictionary *)row;
- (void)removeObserverForRow:(NSMutableDictionary *)row;
- (void)addObserverForRowAtIndex:(NSUInteger)idx;
- (void)removeObserverForRowAtIndex:(NSUInteger)idx;
- (void)addObserverForAllRows;
- (void)removeObserverForAllRows;


// Clean up

- (void)dealloc;

@end
