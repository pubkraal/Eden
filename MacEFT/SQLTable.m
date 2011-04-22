//
//  SQLTable.m
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLTable.h"


@implementation SQLTable

@synthesize rows = mutableRows, metadata, numericPrimaryKey, primaryKey;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
	
	if ((self = [super initWithBridge:aBridge andTableName:aTableName])) {
		[self setMetadata:nil];
		[self setNumericPrimaryKey:nil];
		[self setPrimaryKey:nil];
		
		databaseAccessLock = [[NSLock alloc] init];
	}
	
	return self;
}

- (BOOL)loadValues {
	NSArrayController * newController;
	NSDictionary * results, * metaResults;
	NSString * query, * key;
	
	query       = [NSString stringWithFormat:_Q_GET_DATA, [self tableName]];
	results     = [[self bridge] query:query];
	query       = [NSString stringWithFormat:_Q_GET_METADATA, [self tableName]];
	metaResults = [[self bridge] query:query];
	
	if (results && metaResults) {
		[self setColumns:[results objectForKey:SQLBRIGDE_COLUMNS]];
		[self setMetadata:[NSDictionary dictionaryWithObjects:[metaResults objectForKey:SQLBRIDGE_DATA] forKeys:[self columns]]];
		
		for (key in [self columns]) {
			if ([[[[self metadata] objectForKey:key] objectForKey:_Q_PK_KEY] boolValue]) {
				[self setPrimaryKey:key];
				
				if ([[[[self metadata] objectForKey:key] objectForKey:_Q_TYPE_KEY] isEqualToString:@"integer"]) {
					[self setNumericPrimaryKey:key];
				}
				
				break;
			}
		}
		
		[self autoObserveRows:[results objectForKey:SQLBRIDGE_DATA]];
		
		newController = [[NSArrayController alloc] init];
		[self setArrayController:newController];
		[newController release];

	}
	
	[self setContainsData:YES];
	
	return !!(results && metaResults);
}

- (void)autoObserveRows:(NSArray *)rows {
	NSDictionary * row;
	NSUInteger i, rowCount;
	
	if (mutableRows) {
		[self removeObserverForAllRows];
		[mutableRows release];
	}
	
	mutableRows = [NSMutableArray arrayWithArray:rows];
	rowCount    = [mutableRows count];

	for (i = 0; i < rowCount; i++) {
		row = [mutableRows objectAtIndex:i];
		[mutableRows replaceObjectAtIndex:i withObject:[NSMutableDictionary dictionaryWithDictionary:row]];
	}
	
	[self addObserverForAllRows];
	
	[self addObserver:self forKeyPath:@"rows" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	
}

// Primitive foreign key

- (NSObject *)referenceForRow:(NSMutableDictionary *)row {
	NSUInteger idx;
	NSObject * ref;
	
	idx = [[self rows] indexOfObject:row];
	
	if (idx != NSNotFound) ref = [self referenceForRowAtIndex:idx];
	else ref = nil;
	
	return ref;
}

- (NSObject *)referenceForRowAtIndex:(NSUInteger)idx {
	NSObject * ref;
	NSMutableDictionary * row;
	
	row = [[self rows] objectAtIndex:idx];
	ref = [row objectForKey:[self primaryKey]];
	
	return ref;
}

// SQL Interface

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	__block NSMutableDictionary *row;
	NSArray * oldRows, * newRows;
	NSObject * oldValue, * newValue;
	NSInteger changeType, idx;
	NSIndexSet * indexes;
	__block NSMutableArray * aIndexes;
	__block BOOL success;
	NSString * viewName;

	changeType = [[change objectForKey:NSKeyValueChangeKindKey] intValue];
	
	[databaseAccessLock lock];
	
	if ((context) && (changeType == NSKeyValueChangeSetting)) {
		row      = (NSMutableDictionary *) context;
		oldValue = [change objectForKey:NSKeyValueChangeOldKey];
		newValue = [change objectForKey:NSKeyValueChangeNewKey];
		
		if (![oldValue isEqualTo:newValue])	success = [self performUpdateRow:row withValue:newValue forKey:keyPath];
		else success = YES;
		
		if (!success) {
			idx = [[self rows] indexOfObject:row];
			[self removeObserverForRowAtIndex:idx];
			[row setValue:oldValue forKey:keyPath];
			[self addObserverForRowAtIndex:idx];
		}
		
	}
	else {
		oldRows  = [change objectForKey:NSKeyValueChangeOldKey];
		newRows  = [change objectForKey:NSKeyValueChangeNewKey];
		indexes  = [change objectForKey:NSKeyValueChangeIndexesKey];
		aIndexes = [NSMutableArray array];
		
		[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
			[aIndexes addObject:[NSNumber numberWithUnsignedLong:idx]];
		}];
		

		if (changeType == NSKeyValueChangeInsertion) {
			success = YES;
			
			[newRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				row = (NSMutableDictionary *) obj;
				
				if (success) {
					success = [self performInsertRow:row];

					if (success) [self addObserverForRow:row];
					else [mutableRows removeObject:row];
				}
				else [mutableRows removeObject:row];
			}];

		}
		else if (changeType == NSKeyValueChangeRemoval) {
			success = YES;
			
			[oldRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				row = (NSMutableDictionary *) obj;
				
				if (success) {
					success = [self performDeleteRow:row];
					
					if (success) [self removeObserverForRow:row];
					else [mutableRows insertObject:row atIndex:[[aIndexes objectAtIndex:idx] unsignedLongValue]];
				}
				else [mutableRows insertObject:row atIndex:[[aIndexes objectAtIndex:idx] unsignedLongValue]];
			}];
		}
		else if (changeType == NSKeyValueChangeReplacement) {
			success = YES;
			
			[oldRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				if (success) {
					success = [self performDeleteRow:row];
					
					if (success) [self removeObserverForRow:row];
					else [mutableRows insertObject:row atIndex:[[aIndexes objectAtIndex:idx] unsignedLongValue]];
				}
				else [mutableRows insertObject:row atIndex:[[aIndexes objectAtIndex:idx] unsignedLongValue]];
			}];
			
			if (success) {
				[newRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
					row = (NSMutableDictionary *) obj;
					
					if (success) {
						success = [self performInsertRow:row];
						
						if (success) [self addObserverForRow:row];
						else [mutableRows removeObject:row];
					}
					else [mutableRows removeObject:row];
				}];
			}
			else {
				[mutableRows insertObjects:oldRows atIndexes:indexes];
			}
		}
	}
	
	[databaseAccessLock unlock];

	
	if (!success) {
		NSLog(@"Error: %@", [[self bridge] lastError]);
	}
	else {
		for (viewName in [[self bridge] trueViews]) {
			[(SQLView *) [[[self bridge] views] objectForKey:viewName] loadValues];
		}
	}
}

- (BOOL)performInsertRow:(NSMutableDictionary *)row {
	BOOL success;
	NSString * query;
	
	query = _QMakeInsert([self tableName], [row allKeys]);
	
	success = [[self bridge] execute:query withDictionary:row];
	
	if (success && [self numericPrimaryKey] && ([[row allKeys] indexOfObject:[self numericPrimaryKey]] == NSNotFound)) {
		[row setValue:[[self bridge] lastInsertRowID] forKey:[self primaryKey]];
	}
	
	return success;
}

- (BOOL)performDeleteRow:(NSMutableDictionary *)row {
	BOOL success;
	NSString * query;
	
	query = _QMakeDelete([self tableName], [self primaryKey]);
	
	success = [[self bridge] execute:query, [row objectForKey:[self primaryKey]]];
	
	return success;
}

- (BOOL)performUpdateRow:(NSMutableDictionary *)row withValue:(NSObject *)value forKey:(NSString *)key {
	BOOL success;
	NSString * query;
	
	query = _QMakeUpdate([self tableName], [self primaryKey], key);
	
	success = [[self bridge] execute:query, value, [row objectForKey:[self primaryKey]]];
	
	return success;
}

// Convenience functions for insertion

- (NSMutableDictionary *)emptyRow {
	NSMutableDictionary * row;
	NSString * key;
	
	row = [NSMutableDictionary dictionary];
	
	for (key in [self columns]) {
		if (![key isEqualToString:[self numericPrimaryKey]]) [row setValue:[NSNull null] forKey:key];
	}
	
	return row;
}

- (NSMutableDictionary *)newRow {
	NSMutableDictionary * newRow;
	NSDictionary * colMeta;
	NSString * key;
	NSObject * defaultValue;
	
	newRow = [NSMutableDictionary dictionary];
	
	for (key in newRow) {
		if ([key isEqualToString:[self numericPrimaryKey]]) continue;
		
		colMeta      = [[self metadata] objectForKey:key];
		defaultValue = [colMeta objectForKey:_Q_DEFAULT_KEY];
		
		if ((defaultValue == [NSNull null]) && ([colMeta objectForKey:_Q_NOTNULL_KEY])) {
			return nil;
		}
		
		[newRow setValue:defaultValue forKey:key];
	}
	
	[self insertInRows:newRow];
	
	return newRow;
}



// Accessors

- (NSUInteger)countOfRows {
	return [mutableRows count];
}

- (id)objectInRowsAtIndex:(NSUInteger)idx {
	return [mutableRows objectAtIndex:idx];
}

- (void)insertObject:(id)anObject inRowsAtIndex:(NSUInteger)idx {
	[mutableRows insertObject:anObject atIndex:idx];
}

- (void)insertInRows:(id)anObject {
	[self insertObject:anObject inRowsAtIndex:[self countOfRows]];
}

- (void)removeObjectFromRowsAtIndex:(NSUInteger)idx {
	[mutableRows removeObjectAtIndex:idx];
}

- (void)replaceObjectInRowsAtIndex:(NSUInteger)idx withObject:(id)anObject {
	[mutableRows replaceObjectAtIndex:idx withObject:anObject];
}

- (NSUInteger)indexOfObjectInRows:(id)obj {
	return [mutableRows indexOfObject:obj];
}

- (void)addObserverForRow:(NSMutableDictionary *)row {
	NSString * key;
	
	for (key in [self columns]) {
		[row addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:row];
	}
}

- (void)removeObserverForRow:(NSMutableDictionary *)row {
	NSString * key;
	
	for (key in [self columns]) {
		[row removeObserver:self forKeyPath:key];
	}
}

- (void)addObserverForRowAtIndex:(NSUInteger)idx {
	NSMutableDictionary * row;
	
	row = [self objectInRowsAtIndex:idx];
	
	[self addObserverForRow:row];
}

- (void)removeObserverForRowAtIndex:(NSUInteger)idx {
	NSMutableDictionary * row;

	row = [self objectInRowsAtIndex:idx];
	
	[self removeObserverForRow:row];
}

- (void)addObserverForAllRows {
	NSUInteger idx, count;
	
	count = [self countOfRows];
	
	for (idx = 0; idx < count; idx++) {
		[self addObserverForRowAtIndex:idx];
	}
}

- (void)removeObserverForAllRows {
	NSUInteger idx, count;

	count = [self countOfRows];

	for (idx = 0; idx < count; idx++) {
		[self removeObserverForRowAtIndex:idx];
	}
}

// UI

- (void)modifyPropertiesOfArrayController:(NSArrayController *)controller {
	[controller setEditable:YES];
}

- (void)modifyPropertiesOfTableColumn:(NSTableColumn *)tableColumn forColumn:(NSString *)column {
	[tableColumn setEditable:(![column isEqualToString:[self primaryKey]])];
}

// Clean up

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"rows"];
	[self removeObserverForAllRows];
	[self setMetadata:nil];
	[self setNumericPrimaryKey:nil];
	[self setPrimaryKey:nil];
	[databaseAccessLock release];
	
	
	[super dealloc];
}

@end
