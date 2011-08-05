//
//	EveDatabase.m
//	Eden
//
//	Created by ugo pozo on 5/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "EveDatabase.h"

NSError * initError = nil;
SQLBridge * bridge  = nil;
EveDatabase * db    = nil;

@implementation EveDatabase

- (id)init {
	if ((self = [super init])) {
	}
	
	return self;
}

- (void)dealloc {
	[super dealloc];
}

+ (SQLBridge *)sharedBridgeFromCoder:(NSCoder *)coder {
	if (bridge) [bridge release];
	
	bridge = [[coder decodeObjectForKey:@"evedatabase.bridge"] retain];
	
	bridge.delegate = [self sharedDatabase];
	
	return bridge;
}

+ (void)encodeBridgeWithCoder:(NSCoder *)coder {
	[coder encodeObject:bridge forKey:@"evedatabase.bridge"];
}

+ (BOOL)bridgeLoaded {
	return !!bridge;
}

+ (SQLBridge *)sharedBridge {
	NSString * dbPath;
	BOOL hasError;

	if (bridge == nil) {
		dbPath = [[NSBundle mainBundle] pathForResource:@"evedump" ofType:@"db"];
		
		if (dbPath) {
			bridge = [[SQLBridge alloc] initWithPath:dbPath error:&initError];
			bridge.delegate = [self sharedDatabase];
			
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
													@"The EVE Database shipped with your application could not be found. Please reinstall Eden.", NSLocalizedRecoverySuggestionErrorKey,
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

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName {
	
	if ((self = [super initWithBridge:aBridge andTableName:aTableName])) {
		cachedAttributes = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	
	if ((self = [super initWithCoder:coder])) {
		cachedAttributes = [[coder decodeObjectForKey:@"evetypestable.cachedAttributes"] retain];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:cachedAttributes forKey:@"evetypestable.cachedAttributes"];
}

- (void)dealloc {
	[cachedAttributes release];
	
	[super dealloc];
}

- (NSArray *)attributesForKey:(NSNumber *)typeID {
	NSArray * results;
	
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
