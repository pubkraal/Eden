//
//  SQLBridge.h
//  MacEFT
//
//  Created by ugo pozo on 4/8/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <stdarg.h>
#import <string.h>
#import <stdlib.h>
#import "SQLView.h"

#define INTEGER64 SQLITE_FLOAT + SQLITE_INTEGER + 1
#define SQLBRIDGE_DATA_TOO_LONG INT_MAX
#define SQLBRIDGE_INVALID_TYPE INT_MAX - 1
#define SQLBRIDGE_PARAMETER_NOT_FOUND INT_MAX - 2

#define SQLBRIGDE_COLUMNS @"columns"
#define SQLBRIDGE_DATA @"data"

#define _Q_GET_TABLES @"select name from sqlite_master where type = \"table\""
#define _Q_GET_VIEWS @"select name from sqlite_master where type = \"table\" or type = \"view\""
#define _Q_VIEW_KEY @"name"

#define _Q_GET_DATA @"select * from %@"

@interface SQLBridge : NSObject {
@private
    sqlite3 * database;
	NSError * lastError;
	
	NSDictionary * numberTypes, * temp;
	
	NSMutableDictionary * views;
}

@property (retain) NSError * lastError;
@property (retain) NSMutableDictionary * views;

// Initialization

- (id)initWithPath:(NSString *)dbPath error:(NSError **)error;
- (BOOL)preloadViews;


// Statements

- (NSDictionary *)query:(NSString *)sql, ...;
- (NSDictionary *)query:(NSString *)sql withArgs:(va_list)args;
- (NSDictionary *)query:(NSString *)sql withDictionary:(NSDictionary *)args;
- (NSDictionary *)query:(NSString *)sql withArray:(NSArray *)args;
- (NSDictionary *)performQuery:(sqlite3_stmt *)statement;

- (BOOL)execute:(NSString *)sql, ...;
- (BOOL)execute:(NSString *)sql withArgs:(va_list)args;
- (BOOL)execute:(NSString *)sql withDictionary:(NSDictionary *)args;
- (BOOL)execute:(NSString *)sql withArray:(NSArray *)args;
- (BOOL)performExecute:(sqlite3_stmt *)statement;

- (sqlite3_stmt *)prepareStatement:(NSString *)sql, ...;
- (sqlite3_stmt *)prepareStatement:(NSString *)sql withArgs:(va_list)args;
- (sqlite3_stmt *)prepareStatement:(NSString *)sql withDictionary:(NSDictionary *)args;
- (sqlite3_stmt *)prepareStatement:(NSString *)sql withArray:(NSArray *)args;

- (void)checkBindForStatement:(sqlite3_stmt **)stmt withCode:(int)code;
- (NSObject *)valueForColumn:(int)i ofStatement:(sqlite3_stmt *)stmt;
- (void)bindValue:(NSObject *)value toStatement:(sqlite3_stmt **)stmt_ptr atIndex:(int)i;

// Error handling

- (void)setErrorWithDesc:(NSString *)description andCode:(long)code;
- (void)setErrorToDatabaseErrorWithCode:(int)code;
- (void)setErrorToDatabaseError;

// Closing

- (void)dealloc;




@end
