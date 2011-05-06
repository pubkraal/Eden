//
//	EveDatabase.h
//	MacEFT
//
//	Created by ugo pozo on 5/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLBridge.h"

@class EveTable;
@class EveTypesTable;

@interface EveDatabase : NSObject <SQLBridgeDelegate> {
@private
	
}


+ (SQLBridge *)sharedBridge;
+ (EveDatabase *)sharedDatabase;
+ (NSError *)initError;
+ (EveTable *)attributes;
+ (EveTypesTable *)types;

@end

@interface EveTable : SQLTable {

}

@end

@interface EveTypesTable : EveTable {
	
}

- (NSDictionary *)rowWithJoinedAttributesForKey:(NSString *)stringID;

@end