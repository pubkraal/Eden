//
//  SQLMutableTable.h
//  Eden
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLTable.h"

@interface SQLMutableTable : SQLTable {
@private
    NSMutableArray * mutableRows;
	NSLock * databaseAccessLock;
}

@property (retain) NSMutableArray * rows;

// Initializers

//- (void)autoObserveRows:(NSArray *)rows;


// SQL Interface

- (BOOL)performInsertRow:(NSMutableDictionary *)row;
- (BOOL)performDeleteRow:(NSMutableDictionary *)row;
- (BOOL)performUpdateRow:(NSMutableDictionary *)row withValue:(NSObject *)value forKey:(NSString *)key;

// Convenience functions for insertion

- (NSMutableDictionary *)emptyRow;
- (NSMutableDictionary *)newRow;

// Array accessors

- (void)insertObject:(id)anObject inRowsAtIndex:(NSUInteger)idx;
- (void)insertInRows:(id)anObject;
- (void)removeObjectFromRowsAtIndex:(NSUInteger)idx;
- (void)replaceObjectInRowsAtIndex:(NSUInteger)idx withObject:(id)anObject;

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
