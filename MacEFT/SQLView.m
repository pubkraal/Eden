//
//  SQLView.m
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLView.h"


@implementation SQLView

@synthesize tableName, bridge, columns, rows, containsData, arrayController;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
    if ((self = [super init])) {
		tableName = [aTableName retain];
		bridge    = aBridge; // Does NOT retain the bridge! The bridge is responsible for releasing US if it ever gets dealloc'ed.
		[[bridge views] setValue:self forKey:aTableName];
		
		[self setColumns:nil];
		[self setRows:nil];
		[self setContainsData:NO];
		[self setArrayController:nil];
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
	
	query   = [NSString stringWithFormat:_Q_GET_DATA, [self tableName]];
	results = [bridge query:query];
	
	if (results) {
		[self setColumns:[results objectForKey:SQLBRIGDE_COLUMNS]];
		[self setRows:[results objectForKey:SQLBRIDGE_DATA]];
		
		newController = [[NSArrayController alloc] init];
		[self setArrayController:newController];
		[newController release];
	}

	[self setContainsData:YES];
	
	return !!results;
}


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
	
	[self modifyPropertiesOfTableView:view];}

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

	//[arrayController unbind:@"contentArray"];
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
	
    [super dealloc];
}

@end
