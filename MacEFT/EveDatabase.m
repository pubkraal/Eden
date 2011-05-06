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

- (Class)classForTable:(NSString *)tableName {
	return [EveTable class];
}

- (BOOL)shouldBuildLookupForTable:(NSString *)tableName {
	return NO;
}

@end

@implementation EveTable

@end
