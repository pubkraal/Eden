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
#import "SQLTable.h"

#define INTEGER64 SQLITE_FLOAT + SQLITE_INTEGER + 1

#define SQLBRIDGE_DOMAIN @"SQLBridgeError"
#define SQLBRIDGE_DATA_TOO_LONG INT_MAX
#define SQLBRIDGE_INVALID_TYPE INT_MAX - 1
#define SQLBRIDGE_PARAMETER_NOT_FOUND INT_MAX - 2

#define SQLBRIGDE_COLUMNS @"columns"
#define SQLBRIDGE_DATA @"data"

#define _Q_GET_OBJECTS @"select name, type from sqlite_master where type = \"table\" or type = \"view\";"
#define _Q_GET_DATA @"select * from %@;"
#define _Q_GET_METADATA @"pragma table_info(%@);"

#define _Q_INSERT_OBJECT @"insert into %@ (%@) values (:%@);"
#define _Q_DELETE_OBJECT @"delete from %@ where %@ = ?;"
#define _Q_UPDATE_OBJECT @"update %@ set %@ = ? where %@ = ?;"

#define _QMakeInsert(T, C) [NSString stringWithFormat:_Q_INSERT_OBJECT, (T), [(C) componentsJoinedByString:@", "], [(C) componentsJoinedByString:@", :"]]
#define _QMakeDelete(T, P) [NSString stringWithFormat:_Q_DELETE_OBJECT, (T), (P)]
#define _QMakeUpdate(T, P, C) [NSString stringWithFormat:_Q_UPDATE_OBJECT, (T), (C), (P)]

#define _Q_NAME_KEY @"name"
#define _Q_TYPE_KEY @"type"
#define _Q_PK_KEY @"pk"
#define _Q_DEFAULT_KEY @"dflt_value"
#define _Q_NOTNULL_KEY @"notnull"

@protocol SQLBridgeDelegate <NSObject>

@optional
- (Class)classForTable:(NSString *)table;
- (Class)classForView:(NSString *)view;

@end

@interface SQLBridge : NSObject {
@private
    sqlite3 * database;
	NSError * lastError;
	
	NSDictionary * numberTypes, * temp;
	
	NSMutableDictionary * views;
	
	NSArray * trueViews;
	
	NSObject <SQLBridgeDelegate> * delegate;
}

@property (retain) NSError * lastError;
@property (retain) NSMutableDictionary * views;
@property (retain) NSObject <SQLBridgeDelegate> * delegate;
@property (readonly) NSArray * viewsNames;
@property (readonly) NSArray * viewsValues;
@property (retain) NSArray * trueViews;

// Initialization

- (id)initWithPath:(NSString *)dbPath error:(NSError **)error;
+ (id)bridgeWithPath:(NSString *)dbPath error:(NSError **)error;
- (BOOL)preloadViews;
- (BOOL)loadViewsValues;
- (Class)classForView:(NSString *)view;
- (Class)classForTable:(NSString *)table;

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

// Convenience

- (NSNumber *)lastInsertRowID;

// Error handling

- (void)setErrorWithDesc:(NSString *)description andCode:(long)code;
- (void)setErrorToDatabaseErrorWithCode:(int)code;
- (void)setErrorToDatabaseError;
- (void)clearError;

// UI

- (void)attachViewsToArrayController:(NSArrayController *)controller;


// Closing

- (void)dealloc;




@end
