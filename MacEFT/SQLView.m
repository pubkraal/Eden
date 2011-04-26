//
//  SQLView.m
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLBridge_object.h"
#import "SQLView.h"
#import "SQLTable.h"
#import "SQLMutableTable.h"

@implementation SQLView

@synthesize tableName, bridge, columns, rows, containsData, arrayController, metadata;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
    if ((self = [super init])) {
		tableName = [aTableName retain];
		bridge    = aBridge; // Does NOT retain the bridge! The bridge is responsible for releasing US if it ever gets dealloc'ed.
		[bridge setValue:self forKeyPath:[NSString stringWithFormat:@"views.%@", aTableName]];
		
		[self setColumns:nil];
		[self setRows:nil];
		[self setContainsData:NO];
		[self setArrayController:nil];
		[self setMetadata:nil];
		
    }
    
    return self;
}

+ (id)viewWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
	return [[[self alloc] initWithBridge:aBridge andTableName:aTableName] autorelease];
}

- (NSString *)description {
	NSString * desc;
	
	desc = [NSString stringWithFormat:@"{\n- Table name: %@;\n- Columns: %@;\n- Data: %@\n}", [self tableName], [[self columns] componentsJoinedByString:@", "], [self rows]];
	
	return desc;
}

- (BOOL)loadValues {
	NSDictionary * results;
	NSString * query;
	NSArrayController * newController;
	
	query       = [NSString stringWithFormat:_Q_GET_DATA, [self tableName]];
	results     = [bridge query:query];
	
	if (results) {
		[self setColumns:[results objectForKey:SQLBRIGDE_COLUMNS]];
		if (![self metadata]) [self loadMetadata];
		[self doSetRows:[results objectForKey:SQLBRIDGE_DATA]];
		
		newController = [[NSArrayController alloc] init];
		[self setArrayController:newController];
		[newController release];
	}

	[self setContainsData:YES];
	
	return !!results;
}

- (BOOL)loadMetadata {
	NSDictionary * results;
	NSString * query;

	query     = [NSString stringWithFormat:_Q_GET_METADATA, [self tableName]];
	results   = [[self bridge] query:query];

	if (results) {
		[self setMetadata:[NSDictionary dictionaryWithObjects:[results objectForKey:SQLBRIDGE_DATA] forKeys:[self columns]]];
	}

	return !!results;
}

- (NSArray *)metadataArray {
	return [[self metadata] allValues];
}

- (void)doSetRows:(NSArray *)newRows {
	[self setRows:newRows];
}


// Readonly array accessors


- (NSUInteger)countOfRows {
	return [rows count];
}

- (id)objectInRowsAtIndex:(NSUInteger)idx {
	return [rows objectAtIndex:idx];
}

- (NSUInteger)indexOfObjectInRows:(id)obj {
	return [rows indexOfObject:obj];
}


// Filtering

- (NSArray *)filteredRowsWithPredicate:(NSPredicate *)predicate {
	return [[self rows] filteredArrayUsingPredicate:predicate];
}


- (NSArray *)filteredRowsWithPredicateFormat:(NSString *)format, ... {
	va_list args;
	NSArray * filtered;
	NSPredicate * predicate;
	NSString * predicateText;

	va_start(args, format);
	
	predicateText = [[NSString alloc] initWithFormat:format arguments:args];
	predicate     = [NSPredicate predicateWithFormat:predicateText];

	[predicateText release];

	filtered      = [self filteredRowsWithPredicate:predicate];

	va_end(args);

	return filtered;
}

- (NSArray *)predicateEditorRowTemplates {
	__block NSMutableArray * strExpr, * numExpr;
	NSMutableArray * templates;
	NSArray * strComp, * numComp;

	strComp = [NSArray arrayWithObjects:
							[NSNumber numberWithInt:NSContainsPredicateOperatorType],
							[NSNumber numberWithInt:NSBeginsWithPredicateOperatorType],
							[NSNumber numberWithInt:NSEndsWithPredicateOperatorType],
							[NSNumber numberWithInt:NSLikePredicateOperatorType],
							[NSNumber numberWithInt:NSNotEqualToPredicateOperatorType],
							[NSNumber numberWithInt:NSMatchesPredicateOperatorType],
							nil];
	
	numComp = [NSArray arrayWithObjects:
							[NSNumber numberWithInt:NSEqualToPredicateOperatorType],
							[NSNumber numberWithInt:NSNotEqualToPredicateOperatorType],
							[NSNumber numberWithInt:NSLessThanPredicateOperatorType],
							[NSNumber numberWithInt:NSGreaterThanPredicateOperatorType],
							[NSNumber numberWithInt:NSLessThanOrEqualToPredicateOperatorType],
							[NSNumber numberWithInt:NSGreaterThanOrEqualToPredicateOperatorType],
							nil];
	
	strExpr = [NSMutableArray array];
	numExpr = [NSMutableArray array];

	[[self metadata] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
		NSExpression * expr;
		NSDictionary * info;

		info = (NSDictionary *) obj;
		expr = [NSExpression expressionForKeyPath:[NSString stringWithFormat:@"%@", [info objectForKey:_Q_NAME_KEY]]];
		
		if ([[NSPredicate predicateWithFormat:@"(SELF contains[i] 'char') OR (SELF contains[i] 'text')"] evaluateWithObject:[info objectForKey:_Q_TYPE_KEY]]) {
			[strExpr addObject:expr];
		}
		else [numExpr addObject:expr];
	}];

	templates = [NSMutableArray arrayWithObject:[[[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:NSAndPredicateType], [NSNumber numberWithInt: NSOrPredicateType], [NSNumber numberWithInt: NSNotPredicateType], nil]] autorelease]];
	
	if ([strExpr count] > 0) {
		[templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:strExpr rightExpressionAttributeType:NSStringAttributeType modifier:NSDirectPredicateModifier operators:strComp options:(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption)] autorelease]];
	}
	
	if ([numExpr count] > 0) {
		[templates addObject:[[[NSPredicateEditorRowTemplate alloc] initWithLeftExpressions:numExpr rightExpressionAttributeType:NSInteger64AttributeType modifier:NSDirectPredicateModifier operators:numComp options:0] autorelease]];
	}

	return [NSArray arrayWithArray:templates];
}

// UI


- (void)attachToTableView:(NSTableView *)view {
	__block NSTableColumn * newColumn;
	
	[[self columns] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		newColumn = [[NSTableColumn alloc] initWithIdentifier:obj];
		[[newColumn headerCell] setStringValue:[self titleForColumn:(NSString *) obj]];
		
		[newColumn bind:@"value"
			   toObject:[self arrayController]
			withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@", (NSString *)obj]
				options:[self bindingOptionsForColumn:(NSString *)obj]];
		
		[view addTableColumn:newColumn];
		[self modifyPropertiesOfTableColumn:newColumn forColumn:(NSString *)obj];
		
		[newColumn release];
	}];
	
	[self modifyPropertiesOfTableView:view];
}

- (void)dettachFromTableView:(NSTableView *)view {
	NSArray * tableColumns;
	
	tableColumns = [view tableColumns];
	
	[tableColumns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSTableColumn * column = (NSTableColumn *) obj;
		
		[column unbind:@"value"];
	}];
	
	while ([tableColumns count] > 0) {
		[view removeTableColumn:[tableColumns objectAtIndex:0]];
	}
}


- (void)attachToArrayController:(NSArrayController *)controller andTableView:(NSTableView *)view {
	__block NSTableColumn * newColumn;
	
	[controller bind:@"contentArray" toObject:self withKeyPath:@"rows" options:[self bindingOptionsForArrayController]];
	[self modifyPropertiesOfArrayController:controller];
	
	[[self columns] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		newColumn = [[NSTableColumn alloc] initWithIdentifier:obj];
		[[newColumn headerCell] setStringValue:[self titleForColumn:(NSString *) obj]];
		
		[newColumn bind:@"value"
			   toObject:controller
			withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@", (NSString *)obj]
				options:[self bindingOptionsForColumn:(NSString *)obj]];
		
		[view addTableColumn:newColumn];
		[self modifyPropertiesOfTableColumn:newColumn forColumn:(NSString *)obj];
		
		[newColumn release];
	}];
	
	[self modifyPropertiesOfTableView:view];
}

- (void)dettachFromArrayController:(NSArrayController *)controller andTableView:(NSTableView *)view {
	NSArray * tableColumns;
	
	[controller unbind:@"contentArray"];

	tableColumns = [view tableColumns];
	
	[tableColumns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSTableColumn * column = (NSTableColumn *) obj;
		
		[column unbind:@"value"];
	}];
	
	while ([tableColumns count] > 0) {
		[view removeTableColumn:[tableColumns objectAtIndex:0]];
	}
}

- (NSString *)titleForColumn:(NSString *)column {
	return column;
}

- (NSDictionary *)bindingOptionsForColumn:(NSString *)column {
	return nil;
}

- (NSDictionary *)bindingOptionsForArrayController {
	return nil;
}

- (void)modifyPropertiesOfTableColumn:(NSTableColumn *)tableColumn forColumn:(NSString *)column {
	[tableColumn setEditable:NO];
}

- (void)modifyPropertiesOfArrayController:(NSArrayController *)controller {
	[controller setEditable:NO];
}

- (void)modifyPropertiesOfTableView:(NSTableView *)tableView {
	
}

- (void)setArrayController:(NSArrayController *)controller {
	[controller retain];
	[controller bind:@"contentArray" toObject:self withKeyPath:@"rows" options:[self bindingOptionsForArrayController]];

	[arrayController release];
	
	arrayController = controller;

	[self modifyPropertiesOfArrayController:arrayController];
}

- (NSArrayController *)arrayController {
	return arrayController;
}


- (void)dealloc {
	[tableName release];
	
	[self setColumns:nil];
	[self setRows:nil];
	[self setArrayController:nil];
	[self setMetadata:nil];
	
    [super dealloc];
}

@end
