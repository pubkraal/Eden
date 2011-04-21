//
//  SQLView.m
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLView.h"


@implementation SQLView

@synthesize tableName, bridge, columns, rows;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
    if ((self = [super init])) {
		tableName = [aTableName retain];
		bridge    = aBridge; // Does NOT retain the bridge! The bridge is responsible for releasing US if it ever gets dealloc'ed.
		[[bridge views] setValue:self forKey:aTableName];
		
		[self setColumns:nil];
		[self setRows:nil];
    }
    
    return self;
}

+ (SQLView *) viewWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
	return [[[SQLView alloc] initWithBridge:aBridge andTableName:aTableName] autorelease];
}

- (BOOL)loadValues {
	NSDictionary * results;
	NSString * query;
	
	query   = [NSString stringWithFormat:_Q_GET_DATA, [self tableName]];
	results = [bridge query:query];
	
	if (results) {
		[self setColumns:[results objectForKey:SQLBRIGDE_COLUMNS]];
		[self setRows:[results objectForKey:SQLBRIDGE_DATA]];
	}
	
	return !!results;
}

- (void)dealloc {
	[tableName release];
	
	[self setColumns:nil];
	[self setRows:nil];
	
    [super dealloc];
}

@end
