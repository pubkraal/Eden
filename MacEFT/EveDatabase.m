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
		// Initialization code here.
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

	if (bridge == nil) {
		db     = [self sharedDatabase];
		dbPath = [[NSBundle mainBundle] pathForResource:@"evedump_lite_nochr" ofType:@"db"];
		
		if (dbPath) {
			bridge = [[SQLBridge alloc] initWithPath:dbPath error:&initError];
			
			if (!initError) {
				bridge.delegate = db;

				if (![bridge preloadViews]) {
					initError = bridge.lastError;
				}
				else {
					if (![bridge loadViewsValues]) {
						initError = bridge.lastError;
					}
				}
			}

			if (initError) {
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


- (Class)classForTable:(NSString *)tableName {
	if ([tableName isEqualToString:@"invTypes"]) return [EveTypesTable class];
	else return [EveTable class];
}

- (BOOL)shouldBuildLookupForTable:(NSString *)tableName {
	return NO;
}

@end

@implementation EveTable

@end

@implementation EveTypesTable

- (NSDictionary *)rowWithJoinedAttributesForKey:(NSString *)stringID {
	NSNumber * typeID, * attrVal;
	NSArray * attributes;
	NSMutableDictionary * row;
	NSDictionary * attr;
	NSString * attrName;
	EveTable * intermediaryTable, * attributesTable;
	
	typeID = [NSNumber numberWithInteger:[stringID integerValue]];
	row    = [NSMutableDictionary dictionaryWithDictionary:[self rowWithSingleKey:typeID]];
	
	intermediaryTable = [[self.bridge views] objectForKey:@"dgmTypeAttributes"];
	attributesTable   = [EveDatabase attributes];
	attributes        = [intermediaryTable filteredRowsWithPredicateFormat:@"typeID = %@", typeID];
	
	for (attr in attributes) {
		attrName = [[attributesTable rowWithSingleKey:[attr objectForKey:@"attributeID"]] objectForKey:@"attributeName"];
		
		if ([attr objectForKey:@"valueInt"] == [NSNull null]) attrVal = [attr objectForKey:@"valueFloat"];
		else attrVal = [attr objectForKey:@"valueInt"];
		
		[row setObject:attrVal forKey:attrName];
	}
	
	return [NSDictionary dictionaryWithDictionary:row];
}

@end
