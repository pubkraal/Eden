//
//  SQLBridge.m
//  MacEFT
//
//  Created by ugo pozo on 4/8/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLBridge.h"

@implementation SQLBridge

@synthesize database, lastError;

- (id)initWithPath:(NSString *)dbPath error:(NSError **)error{
	int rc;
	NSString * errorMsg;
	
    if ((self = [super init])) {
		database = NULL;
		
		rc = sqlite3_open([dbPath UTF8String], &database);
		
		if (rc) {
			errorMsg = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
			
			[self setErrorWithDesc:errorMsg andCode:(long) rc];
			
			if (error) (*error) = [self lastError];
			
			sqlite3_close(database);
			database = NULL;
		}

    }
    
    return self;
}

- (void)dealloc
{
	if (database) sqlite3_close(database);

    [super dealloc];
}

- (void)setErrorWithDesc:(NSString *)description andCode:(long)code {
	NSError * newError;
	NSDictionary * errorInfo;
	
	errorInfo = [[NSDictionary alloc] initWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
	newError  = [[NSError alloc] initWithDomain:@"SQLError" code:code userInfo:errorInfo];
	
	[errorInfo release];
	
	[self setLastError:newError];
	
	[newError release];
}

@end
