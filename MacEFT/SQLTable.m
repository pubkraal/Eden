//
//  SQLTable.m
//  MacEFT
//
//  Created by ugo pozo on 4/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLBridge_object.h"
#import "SQLView.h"
#import "SQLTable.h"
#import "SQLMutableTable.h"


@implementation SQLTable

@synthesize numericPrimaryKey, primaryKeys, rowsByPK;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
	
	if ((self = [super initWithBridge:aBridge andTableName:aTableName])) {
		[self setNumericPrimaryKey:nil];
		[self setPrimaryKeys:nil];
		[self setRowsByPK:nil];
	}
	
	return self;
}

- (BOOL)loadMetadata {
	NSDictionary * results, * fkResults, * info;
	__block NSMutableDictionary * md, * fk;
	NSMutableArray * pks;
	NSString * query, * numPk;
	__block NSString * key;

	query     = [NSString stringWithFormat:_Q_GET_METADATA, [self tableName]];
	results   = [[self bridge] query:query];
	query     = [NSString stringWithFormat:_Q_GET_FOREIGN_KEYS, [self tableName]];
	fkResults = [[self bridge] query:query];

	if (fkResults) {
		fk = [NSMutableDictionary dictionary];

		[[fkResults objectForKey:SQLBRIDGE_DATA] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
			NSDictionary * fkData;

			fkData = [NSDictionary dictionaryWithObjectsAndKeys: \
									[(NSDictionary *) obj objectForKey:_Q_FK_COLUMN_KEY], _Q_FK_COLUMN_KEY, \
									[(NSDictionary *) obj objectForKey:_Q_FK_TABLE_KEY], _Q_FK_TABLE_KEY, \
										nil];

			[fk setObject:fkData forKey:[(NSDictionary *) obj objectForKey:_Q_FK_FROM_KEY]];
		}];
	}
	else fk = nil;

	if (results) {
		md = [NSMutableDictionary dictionary];

		[[results objectForKey:SQLBRIDGE_DATA] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
			[md setValue:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) obj] forKey:[[self columns] objectAtIndex:idx]];

		}];

		[self setMetadata:md];

		pks   = [NSMutableArray array];
		numPk = nil;

		for (key in [self columns]) {
			if ([[[[self metadata] objectForKey:key] objectForKey:_Q_PK_KEY] boolValue]) {
				[pks addObject:key];
				
				if ([[[[self metadata] objectForKey:key] objectForKey:_Q_TYPE_KEY] isEqualToString:@"integer"]) {
					numPk = key;
				}
			}

			if (fk) {
				info = [fk objectForKey:key];

				if (info) {
					[[[self metadata] objectForKey:key] setObject:[NSNumber numberWithBool:YES] forKey:_Q_FK_KEY];

					[info enumerateKeysAndObjectsUsingBlock:^(id prop, id obj, BOOL * stop) {
						[[[self metadata] objectForKey:key] setObject:obj forKey:prop];
					}];
				}
				else [[[self metadata] objectForKey:key] setObject:[NSNumber numberWithBool:NO] forKey:_Q_FK_KEY];
			}
		}

		if ([pks count] == 1) [self setNumericPrimaryKey:numPk];
		[self setPrimaryKeys:[NSArray arrayWithArray:pks]];


		[self setPredicateEditorRowTemplates:[self generatePredicateEditorRowTemplates]];

	}

	return !!results;
}



- (void)doSetRows:(NSArray *)newRows {
	[self setRows:newRows];

	if ([[self bridge] buildLookupForTable:[self tableName]]) [self updateLookup];
}

- (void)updateLookup {
	NSArray * key;
	NSMutableDictionary * lookup;
	NSDictionary * row;

	lookup = [NSMutableDictionary dictionary];

	for (row in [self rows]) {
		key = [row objectsForKeys:[self primaryKeys] notFoundMarker:[NSNull null]];
		
		[lookup setObject:row forKey:key];
	}

	[self setRowsByPK:[NSDictionary dictionaryWithDictionary:lookup]];
}


- (NSArray *)keyForRow:(NSDictionary *)row {
	NSArray * key;

	key = [row objectsForKeys:[self primaryKeys] notFoundMarker:[NSNull null]];

	return key;
}

- (NSArray *)keyForRowAtIndex:(NSUInteger)idx {
	id row;

	row = [self objectInRowsAtIndex:idx];

	return [self keyForRow:row];
}


- (id)rowWithKey:(NSArray *)key {
	id row;

	row = [[self rowsByPK] objectForKey:key];

	return row;
}


- (NSUInteger)indexOfRowWithKey:(NSArray *)key {
	id row;

	row = [self rowWithKey:key];

	return [self indexOfObjectInRows:row];
}







- (NSDictionary *)foreignObjectForKey:(NSString *)key inRow:(NSDictionary *)row {
	NSDictionary * fObject, * fData;
	SQLTable * fView;
	NSString * fTable, * fKey;
	NSArray * results;
	NSPredicate * pred;
	
	fData = [[self metadata] objectForKey:key];

	if (fData && [[fData objectForKey:_Q_FK_KEY] boolValue]) {
		fTable = [fData objectForKey:_Q_FK_TABLE_KEY];
		fKey   = [fData objectForKey:_Q_FK_COLUMN_KEY];
		fView  = [[[self bridge] views] objectForKey:fTable];
	
		if (([[fView primaryKeys] count] == 1) && ([fKey isEqualToString:[[fView primaryKeys] objectAtIndex:0]])) {
			fObject = [fView rowWithKey:[NSArray arrayWithObject:[row objectForKey:key]]];
		}
		else {
			pred    = [NSPredicate predicateWithFormat:@"SELF.%@ == %@", fKey, [row objectForKey:key]];
			results = [[fView rows] filteredArrayUsingPredicate:pred];

			if ([results count] == 1) fObject = [results objectAtIndex:0];
			else fObject = nil;
		}
		
	}
	else fObject = nil;

	return fObject;
}

- (NSDictionary *)foreignObjectForKey:(NSString *)key inRowAtIndex:(NSUInteger)idx {
	NSDictionary * row;

	row = [self objectInRowsAtIndex:idx];

	return [self foreignObjectForKey:key inRow:row];
}

- (NSArray *)foreignObjectsInTable:(NSString *)tableName usingColumn:(NSString *)otherKey forRow:(NSDictionary *)row {
	NSPredicate * pred;
	NSDictionary * fData, * info;
	NSArray * fObjects;
	SQLTable * table;
	NSString * selfKey;
	
	if (    ([[[self bridge] viewsNames] indexOfObject:tableName] != NSNotFound) &&
			([[[self bridge] trueViews] indexOfObject:tableName] == NSNotFound)   ) {
		table = [[[self bridge] views] objectForKey:tableName];
		fData = [table metadata];
		info  = [fData objectForKey:otherKey];

		if (info && [[info objectForKey:_Q_FK_TABLE_KEY] isEqualToString:[self tableName]]) {
			selfKey  = [info objectForKey:_Q_FK_COLUMN_KEY];
			pred     = [NSPredicate predicateWithFormat:@"SELF.%@ == %@", otherKey, [row objectForKey:selfKey]];
			fObjects = [[table rows] filteredArrayUsingPredicate:pred];

		}
		else fObjects = nil;
	}
	else fObjects = nil;

	return fObjects;
}


- (NSArray *)foreignObjectsInTable:(NSString *)tableName usingColumn:(NSString *)otherKey forRowAtIndex:(NSUInteger)idx {
	NSDictionary * row;

	row = [self objectInRowsAtIndex:idx];

	return [self foreignObjectsInTable:tableName usingColumn:otherKey forRow:row];
	
}

- (NSArray *)foreignObjectsInTable:(NSString *)tableName usingPrimaryKeyForRow:(NSDictionary *)row {
	NSArray * obj;
	
	if ([[self primaryKeys] count] == 1) {
		obj = [self foreignObjectsInTable:tableName usingColumn:[[self primaryKeys] objectAtIndex:0] forRow:row];
	}
	else obj = nil;
	
	return obj;
}

- (NSArray *)foreignObjectsInTable:(NSString *)tableName usingPrimaryKeyForRowAtIndex:(NSUInteger)idx {
	NSDictionary * row;

	row = [self objectInRowsAtIndex:idx];

	return [self foreignObjectsInTable:tableName usingPrimaryKeyForRow:row];
}


- (void)dealloc {
	[self setNumericPrimaryKey:nil];
	[self setPrimaryKeys:nil];
	[self setRowsByPK:nil];

    [super dealloc];
}

@end
