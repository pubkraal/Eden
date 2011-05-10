//
//  SQLBridge.m
//  MacEFT
//
//  Created by ugo pozo on 4/8/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "SQLBridge_object.h"
#import "SQLView.h"
#import "SQLTable.h"
#import "SQLMutableTable.h"

@implementation SQLBridge

@synthesize lastError, views, delegate, trueViews;

- (id)initWithPath:(NSString *)dbPath error:(NSError **)error{
	int rc;
	
    if ((self = [super init])) {
		database  = NULL;
		[self clearError];
		[self setDelegate:nil];
		[self setViews:nil];
		[self setTrueViews:nil];
		
		rc = sqlite3_open([dbPath UTF8String], &database);
		
		if (rc) {
			[self setErrorToDatabaseErrorWithCode:rc];

			if (error) (*error) = [self lastError];
			
			sqlite3_close(database);
			database    = NULL;
		}
		else {
			[self setViews:[NSMutableDictionary dictionary]];
		}
    }
    
    return self;
}

+ (id)bridgeWithPath:(NSString *)dbPath error:(NSError **)error {
	return [[[self alloc] initWithPath:dbPath error:error] autorelease];
}

- (BOOL)preloadViews {
	NSDictionary * queryResult, * row;
	id newView;
	Class cls;
	NSMutableArray * newTrueViews;
	
	queryResult = [self query:_Q_GET_OBJECTS];
	
	if (queryResult) {
		newTrueViews = [NSMutableArray array];
		
		for (row in [queryResult objectForKey:SQLBRIDGE_DATA]) {
			if ([[row objectForKey:_Q_TYPE_KEY] isEqualToString:@"view"]) {
				cls = [self classForView:[row objectForKey:_Q_NAME_KEY]];

				[newTrueViews addObject:[row objectForKey:_Q_NAME_KEY]];
			}
			else {
				cls = [self classForTable:[row objectForKey:_Q_NAME_KEY]];
			}
			
			newView = [cls viewWithBridge:self andTableName:[row objectForKey:_Q_NAME_KEY]];

		}
		
		[self setTrueViews:newTrueViews];
	}

	return !!queryResult;
}

- (Class)classForView:(NSString *)view {
	Class cls;
	
	if ([[self delegate] respondsToSelector:@selector(classForView:)]) {
		cls = [[self delegate] classForView:view];
	}
	else cls = [SQLView class];
	
	return cls;
}

- (Class)classForTable:(NSString *)table {
	Class cls;
	
	if ([[self delegate] respondsToSelector:@selector(classForTable:)]) {
		cls = [[self delegate] classForTable:table];
	}
	else cls = [SQLMutableTable class];
	
	return cls;
}

- (BOOL)shouldAutoloadView:(NSString *)viewName {
	BOOL autoload;
	
	if ([[self delegate] respondsToSelector:@selector(shouldAutoloadView:)]) {
		autoload = [[self delegate] shouldAutoloadView:viewName];
	}
	else autoload = YES;
	
	return autoload;
}

- (BOOL)shouldBuildLookupForTable:(NSString *)table {
	BOOL lookup;
	
	if ([[self delegate] respondsToSelector:@selector(shouldBuildLookupForTable:)]) {
		lookup = [[self delegate] shouldBuildLookupForTable:table];
	}
	else lookup = YES;
	
	return lookup;
}




- (BOOL)loadViewsValues {
	__block BOOL success;
	
	[[self views] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL * stop) {
		if ([self shouldAutoloadView:(NSString *)key]) {
			success = [(SQLView *) obj loadValues];
			*stop   = !success;
		}
	}];
	
	return success;
}

// Views


- (SQLView *)makeView:(NSString *)viewName asQuery:(NSString *)sql {
	NSString * query;
	Class cls;
	SQLView * view;

	if ([[[self views] allKeys] indexOfObject:viewName] != NSNotFound) {
		return [[self views] objectForKey:viewName];
	}

	query = [NSString stringWithFormat:_Q_TEMP_VIEW, viewName, sql];
	
	if ([self execute:query]) {
		cls  = [self classForView:viewName];
		view = [cls viewWithBridge:self andTableName:viewName];
		
		[[self trueViews] addObject:viewName];
		
		if ([self shouldAutoloadView:viewName]) [view loadValues];
	}
	else view = nil;

	return view;

}


// Statements

- (NSDictionary *)query:(NSString *)sql, ... {
	va_list args;
	NSDictionary * result;
	
	va_start(args, sql);
	
	result = [self query:sql withArgs:args];

	va_end(args);
	
	return result;
}

- (NSDictionary *)query:(NSString *)sql withArgs:(va_list)args {
	sqlite3_stmt * statement;
	NSDictionary * result;
	
	[self clearError];
	
	SQLBRIDGE_CONDLOG(@"Query: %@", sql);
	
	statement = [self prepareStatement:sql withArgs:args];
	
	if (statement) result = [self performQuery:statement];
	else result = nil;
	
	return result;
}

- (NSDictionary *)query:(NSString *)sql withDictionary:(NSDictionary *)args {
	sqlite3_stmt * statement;
	NSDictionary * result;
	
	[self clearError];
	
	SQLBRIDGE_CONDLOG(@"Query: %@", sql);
	
	statement = [self prepareStatement:sql withDictionary:args];
	
	if (statement) result = [self performQuery:statement];
	else result = nil;
	
	return result;
}

- (NSDictionary *)query:(NSString *)sql withArray:(NSArray *)args {
	sqlite3_stmt * statement;
	NSDictionary * result;
	
	[self clearError];
	
	SQLBRIDGE_CONDLOG(@"Query: %@", sql);
	
	statement = [self prepareStatement:sql withArray:args];
	
	if (statement) result = [self performQuery:statement];
	else result = nil;
	
	return result;
}

- (NSDictionary *)performQuery:(sqlite3_stmt *)statement {
	NSMutableArray * columns, * data;
	NSMutableDictionary * row;
	NSDictionary * result;
	NSString * colName;
	int i, colCount, errCode;
	NSObject * value;
	
	columns  = [[NSMutableArray alloc] init];
	colCount = sqlite3_column_count(statement);
	
	for (i = 0; i < colCount; i++) {
		colName = [[NSString alloc] initWithUTF8String:sqlite3_column_name(statement, i)];
		
		[columns addObject:colName];
		[colName release];
	}
	
	data = [[NSMutableArray alloc] init];
	
	while ((errCode = sqlite3_step(statement)) == SQLITE_ROW) {
		row = [[NSMutableDictionary alloc] init];
		
		for (i = 0; i < colCount; i++) {
			colName = [columns objectAtIndex:i];
			value   = [self valueForColumn:i ofStatement:statement];
			
			[row setValue:value forKey:colName];
		}
		
		[data addObject:row];
		
		[row release];
	}

	if (errCode == SQLITE_DONE) {
		result = [NSDictionary dictionaryWithObjectsAndKeys:\
				  [NSArray arrayWithArray:data], SQLBRIDGE_DATA, \
				  [NSArray arrayWithArray:columns], SQLBRIGDE_COLUMNS, \
				  nil];
	}
	else {
		result = nil;
		[self setErrorToDatabaseError];
	}
	
	[data release];
	[columns release];
	sqlite3_finalize(statement);
	
	return result;
}

- (BOOL)execute:(NSString *)sql, ... {
	BOOL success;
	va_list args;
	
	va_start(args, sql);
	
	success = [self execute:sql withArgs:args];
	
	va_end(args);
	
	return success;
}

- (BOOL)execute:(NSString *)sql withArgs:(va_list)args {
	BOOL success;
	sqlite3_stmt * statement;
	
	[self clearError];
	
	SQLBRIDGE_CONDLOG(@"Execute: %@", sql);
	
	statement = [self prepareStatement:sql withArgs:args];
	
	if (statement) success = [self performExecute:statement];
	else success = NO;
	
	
	return success;
}

- (BOOL)execute:(NSString *)sql withDictionary:(NSDictionary *)args {
	BOOL success;
	sqlite3_stmt * statement;
	
	[self clearError];

	SQLBRIDGE_CONDLOG(@"Execute: %@", sql);

	statement = [self prepareStatement:sql withDictionary:args];
	
	if (statement) success = [self performExecute:statement];
	else success = NO;
	
	
	return success;
}

- (BOOL)execute:(NSString *)sql withArray:(NSArray *)args {
	BOOL success;
	sqlite3_stmt * statement;
	
	[self clearError];

	SQLBRIDGE_CONDLOG(@"Execute: %@", sql);
	
	statement = [self prepareStatement:sql withArray:args];
	
	if (statement) success = [self performExecute:statement];
	else success = NO;
	
	
	return success;
}

- (BOOL)performExecute:(sqlite3_stmt *)statement {
	BOOL success;
	int errCode;
	
	errCode = sqlite3_step(statement);
	success = ((errCode == SQLITE_DONE) || (errCode == SQLITE_ROW));

	if (!success) [self setErrorToDatabaseError];
	
	return success;
}

- (sqlite3_stmt *)prepareStatement:(NSString *)sql, ... {
	sqlite3_stmt * statement;
	va_list args;
	
	va_start(args, sql);
	
	statement = [self prepareStatement:sql withArgs:args];
	
	va_end(args);
	
	return statement;
}

- (sqlite3_stmt *)prepareStatement:(NSString *)sql withArgs:(va_list)args {
	/* Parameter types:
	 * 
	 * SQLite     - Cocoa
	 * blob       - NSData
	 * double     - NSNumber initWithDouble: / initWithFloat:
	 * int/int64  - NSNumber initWithXXX:, XXX being neither Double nor Float
	 * text       - NSString
	 * null       - NSNull
	 *
	 * If any other type if passed to this function, it will fail, set
	 * [self lastError] and return NULL.
	 *
	 * Also, variadic functions have no way of knowing if the number of
	 * parameters you sent match the number that is expected by the SQL
	 * expression, so, be careful with those.
	 *
	 */
	
	sqlite3_stmt * statement;
	const char * cSQL;
	NSObject * arg;
	int i, count;
	
	cSQL = [sql UTF8String];
	
	if (sqlite3_prepare_v2(database, cSQL, (int) strlen(cSQL) + 1, &statement, NULL) == SQLITE_OK) {
		count = sqlite3_bind_parameter_count(statement);
		
		for (i = 1; (i <= count) && statement; i++) { // Parameters in SQLite begins at index 1
			arg = va_arg(args, NSObject *);
			
			[self bindValue:arg toStatement:&statement atIndex:i];
		}
	}
	else {
		[self setErrorToDatabaseErrorWithCode:sqlite3_finalize(statement)];
		
		statement = NULL;
	}
	
	return statement;
}

- (sqlite3_stmt *)prepareStatement:(NSString *)sql withDictionary:(NSDictionary *)args {
	sqlite3_stmt * statement;
	const char * cSQL;
	NSObject * arg;
	int i, count;
	NSString * key, * errorMsg;
	
	cSQL = [sql UTF8String];
	
	if (sqlite3_prepare_v2(database, cSQL, (int) strlen(cSQL) + 1, &statement, NULL) == SQLITE_OK) {
		count = sqlite3_bind_parameter_count(statement);
		
		for (i = 1; (i <= count) && statement; i++) { // Parameters in SQLite begins at index 1
			key = [[NSString alloc] initWithUTF8String:sqlite3_bind_parameter_name(statement, i)];
			arg = [args objectForKey:[key substringWithRange:NSMakeRange(1, [key length] - 1)]];
			
			if (arg == nil) {
				errorMsg = [NSString stringWithFormat:@"Value to bind parameter \"%@\" not found in the dictionary:\n%@", key, args];
				[self setErrorWithDesc:errorMsg andCode:SQLBRIDGE_PARAMETER_NOT_FOUND];
				sqlite3_finalize(statement);
				statement = NULL;
			}
			else [self bindValue:arg toStatement:&statement atIndex:i];

			[key release];
		}
	}
	else {
		[self setErrorToDatabaseErrorWithCode:sqlite3_finalize(statement)];
		
		statement = NULL;
	}
	
	return statement;
}

- (sqlite3_stmt *)prepareStatement:(NSString *)sql withArray:(NSArray *)args {
	sqlite3_stmt * statement;
	const char * cSQL;
	NSObject * arg;
	int i, count;
	NSString * errorMsg;
	
	cSQL = [sql UTF8String];
	
	if (sqlite3_prepare_v2(database, cSQL, (int) strlen(cSQL) + 1, &statement, NULL) == SQLITE_OK) {
		count = sqlite3_bind_parameter_count(statement);
		
		if (count > [args count]) {
			errorMsg = [NSString stringWithFormat:@"The array should have at least %d elements, but it only has %lu.", count, [args count]];
			[self setErrorWithDesc:errorMsg andCode:SQLBRIDGE_PARAMETER_NOT_FOUND];
			sqlite3_finalize(statement);
			statement = NULL;
		}
		
		for (i = 1; (i <= count) && statement; i++) { // Parameters in SQLite begins at index 1
			arg = [args objectAtIndex:i - 1];
			
			[self bindValue:arg toStatement:&statement atIndex:i];
		}
	}
	else {
		[self setErrorToDatabaseErrorWithCode:sqlite3_finalize(statement)];
		
		statement = NULL;
	}
	
	return statement;
}

- (void)checkBindForStatement:(sqlite3_stmt **)stmt_ptr withCode:(int)code {
	if (code != SQLITE_OK) {
		[self setErrorToDatabaseErrorWithCode:code];
		sqlite3_finalize(*stmt_ptr);
		*stmt_ptr = NULL;
	}
}

- (NSObject *)valueForColumn:(int)i ofStatement:(sqlite3_stmt *)stmt {
	/* This can only be called for a statement that has returned SQLITE_ROW
	 * to a sqlite3_step() call.
	 */
	
	int colType;
	NSObject * value;
	long long intVal;
	
	colType = sqlite3_column_type(stmt, i);
	
	if (colType == SQLITE_TEXT) {
		value = [NSString stringWithUTF8String:(char *) sqlite3_column_text(stmt, i)];
	} else if (colType == SQLITE_INTEGER) {
		intVal = sqlite3_column_int64(stmt, i);
		
		if (intVal > INT_MAX) {
			value = [NSNumber numberWithLongLong:intVal];
		}
		else {
			value = [NSNumber numberWithInt:(int) intVal];
		}
	}
	else if (colType == SQLITE_FLOAT) {
		value = [NSNumber numberWithDouble:sqlite3_column_double(stmt, i)];
	}
	else if (colType == SQLITE_BLOB) {
		value = [NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, i)];
	}
	else if (colType == SQLITE_NULL) {
		value = [NSNull null];
	}
	
	return value;
}

- (void)bindValue:(NSObject *)value toStatement:(sqlite3_stmt **)stmt_ptr atIndex:(int)i {
	int errCode;
	const char * numberType;
	sqlite3_stmt * statement;
	long long tempInt;
	
	statement = *stmt_ptr;
	
	if ([value isKindOfClass:[NSNull class]]) {
		errCode = sqlite3_bind_null(statement, i);
		
		[self checkBindForStatement:stmt_ptr withCode:errCode];
	}
	else if ([value isKindOfClass:[NSString class]]) {
		errCode = sqlite3_bind_text(statement, i, [(NSString *) value UTF8String], -1, SQLITE_TRANSIENT);
		
		[self checkBindForStatement:stmt_ptr withCode:errCode];
	}
	else if ([value isKindOfClass:[NSNumber class]]) {
		numberType = [(NSNumber *) value objCType];
		
		if (strchr("cislqCISLQB", *numberType)) {
			tempInt = [(NSNumber *) value longLongValue];
			
			if (tempInt <= INT_MAX) {
				errCode = sqlite3_bind_int(statement, i, [(NSNumber *) value intValue]);
			}
			else {
				errCode = sqlite3_bind_int64(statement, i, (sqlite3_int64) tempInt);
			}

		}
		else if (strchr("fd", *numberType)) {
			errCode = sqlite3_bind_double(statement, i, [(NSNumber *) value doubleValue]);

		}
		else {
			[self setErrorWithDesc:[NSString stringWithFormat:@"Invalid type to interact with database: NSNumber with objCType %s", numberType] andCode:SQLBRIDGE_INVALID_TYPE];
			sqlite3_finalize(statement);
			*stmt_ptr = NULL;
		}

		if (*stmt_ptr) [self checkBindForStatement:stmt_ptr withCode:errCode];
	}
	else if ([value isKindOfClass:[NSData class]]) {
		if ([(NSData *) value length] > INT_MAX) {
			/* sqlite3_bind_blob() can't accept blobs with size greater than
			 * the greatest number that can be stored in int.
			 */
			
			[self setErrorWithDesc:@"You can't have a blob with size greater than the greatest number that an int can hold." andCode:SQLBRIDGE_DATA_TOO_LONG];
			sqlite3_finalize(statement);
			*stmt_ptr = NULL;
		}
		else {
			errCode = sqlite3_bind_blob(statement, i, [(NSData *) value bytes], (int) [(NSData *) value length], SQLITE_TRANSIENT);
			
			[self checkBindForStatement:stmt_ptr withCode:errCode];
		}
	}
	else {
		[self setErrorWithDesc:[NSString stringWithFormat:@"Invalid type to interact with database: %@", NSStringFromClass([value class])] andCode:SQLBRIDGE_INVALID_TYPE];
		sqlite3_finalize(statement);
		*stmt_ptr = NULL;
	}
}

- (NSNumber *)lastInsertRowID {
	NSNumber * rowID;
	
	rowID = [NSNumber numberWithLong:sqlite3_last_insert_rowid(database)];
	
	return rowID;
}


- (void)setErrorWithDesc:(NSString *)description andCode:(long)code {
	NSError * newError;
	NSDictionary * errorInfo;
	
	errorInfo = [[NSDictionary alloc] initWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil];
	newError  = [[NSError alloc] initWithDomain:SQLBRIDGE_DOMAIN code:code userInfo:errorInfo];
	
	[errorInfo release];
	
	[self setLastError:newError];
	
	[newError release];
}

- (void)setErrorToDatabaseErrorWithCode:(int)code {
	NSString * errorMsg;
	
	errorMsg = [NSString stringWithUTF8String:sqlite3_errmsg(database)];
	[self setErrorWithDesc:errorMsg andCode:code];
}

- (void)setErrorToDatabaseError {
	int code;
	
	code = sqlite3_errcode(database);
	[self setErrorToDatabaseErrorWithCode:code];
}

- (void)clearError {
	[self setLastError:nil];
}

- (NSArray *)viewsNames {
	return [[self views] allKeys];
}

- (NSArray *)viewsValues {
	return [[self views] allValues];
}

- (void)dealloc
{
	if (database) {
		sqlite3_close(database);
	}
	
	[self setViews:nil];
	[self setLastError:nil];
	[self setDelegate:nil];
	
    [super dealloc];
}

@end
