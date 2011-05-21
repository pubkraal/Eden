//
//	EveDatabase.m
//	MacEFT
//
//	Created by ugo pozo on 5/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "EveDatabase.h"

NSError * initError = nil;

@implementation EveDatabase

- (id)init {
	if ((self = [super init])) {
	}
	
	return self;
}

- (void)dealloc {
	[super dealloc];
}

+ (SQLBridge *)sharedBridge {
	static SQLBridge * bridge = nil;
	NSString * dbPath;
	EveDatabase * db;
	BOOL hasError;

	if (bridge == nil) {
		db     = [self sharedDatabase];
		dbPath = [[NSBundle mainBundle] pathForResource:@"evedump" ofType:@"db"];
		
		if (dbPath) {
			bridge = [[SQLBridge alloc] initWithPath:dbPath error:&initError];
			bridge.delegate = db;
			
			hasError = !!initError;
			
			if (!hasError) hasError = ![bridge preloadViews];
			if (!hasError) hasError = ![bridge loadViewsValues];
			if (!hasError) hasError = ![bridge makeView:@"skills" asQuery:_E_SKILLS];

			if (hasError) {
				if (!initError) initError = bridge.lastError;
				[bridge release];
				bridge = nil;
			}
		}
		else {
			initError = [NSError errorWithDomain:NSCocoaErrorDomain
											code:-1
										userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
													@"The EVE Database shipped with your application could not be found. Please reinstall MacEFT.", NSLocalizedRecoverySuggestionErrorKey,
													@"Database not found.", NSLocalizedDescriptionKey,
													nil]];

			bridge = nil;
		}
	}

	if (initError) [initError retain];

	return bridge;
}

+ (NSError *)initError {
	return initError;
}

+ (EveDatabase *)sharedDatabase {
	static EveDatabase * db = nil;

	if (db == nil) {
		db = [[self alloc] init];
	}

	return db;
}

+ (EveTable *)attributes {
	return [[[self sharedBridge] views] objectForKey:@"dgmAttributeTypes"];
}

+ (EveTypesTable *)types {
	return [[[self sharedBridge] views] objectForKey:@"invTypes"];
}

+ (EveTable *)groups {
	return [[[self sharedBridge] views] objectForKey:@"invGroups"];
}

- (Class)classForTable:(NSString *)tableName {
	if ([tableName isEqualToString:@"invTypes"]) return [EveTypesTable class];
	else return [EveTable class];
}

- (BOOL)shouldBuildLookupForTable:(NSString *)tableName {
	BOOL build;
	
	if ([tableName isEqualToString:@"invGroups"]) build = YES;
	else build = NO;
	
	return build;
}

@end

@implementation EveTable

@end

@implementation EveTypesTable

- (NSArray *)attributesForKey:(NSNumber *)typeID {
	static NSMutableDictionary * cachedAttributes = nil;
	NSArray * results;
	
	if (!cachedAttributes) cachedAttributes = [[NSMutableDictionary alloc] init];
	
	results = [cachedAttributes objectForKey:typeID];
	
	if (!results) {
		results = [[self.bridge query:_E_ATTRIBUTES, typeID] objectForKey:SQLBRIDGE_DATA];
		if (results) [cachedAttributes setObject:results forKey:typeID];
	}
	
	return results;
}

- (NSDictionary *)joinAttributesForRow:(NSDictionary *)row {
	NSArray * attributes;
	NSDictionary * attr;
	NSMutableDictionary * newRow;
	
	newRow     = [NSMutableDictionary dictionaryWithDictionary:row];
	attributes = [self attributesForKey:[newRow objectForKey:@"typeID"]];
	
	for (attr in attributes) {
		[newRow setObject:[attr objectForKey:_E_VALUE_KEY] forKey:[attr objectForKey:_E_ATTRNAME_KEY]];
	}

	return [NSDictionary dictionaryWithDictionary:newRow];
}

- (NSDictionary *)rowWithJoinedAttributesForKey:(NSString *)stringID {
	NSNumber * typeID;
	NSMutableDictionary * row;
	
	typeID     = [NSNumber numberWithInteger:[stringID integerValue]];
	row        = [NSMutableDictionary dictionaryWithDictionary:[self rowWithSingleKey:typeID]];

	return [self joinAttributesForRow:row];
}

@end
