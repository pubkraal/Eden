//
//	EveDatabase.h
//	MacEFT
//
//	Created by ugo pozo on 5/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLBridge.h"

#define _E_ATTRIBUTES @"select A.attributeName, R.value from (select typeID, attributeID, (case when valueInt is null then valueFloat else valueInt end) as \"value\" from dgmTypeAttributes) as R left join (select attributeID, attributeName from dgmAttributeTypes) as A where (A.attributeID = R.attributeID) and (R.typeID = ?)"
#define _E_SKILLS @"select * from invTypes as T where T.groupID in (select G.groupID from invGroups as G where G.categoryID = 16)"
#define _E_ATTRNAME_KEY @"A.attributeName"
#define _E_VALUE_KEY @"R.value"

// select A.attributeName, R.value from (select typeID, attributeID, (case when valueInt is null then valueFloat else valueInt end) as "value" from dgmTypeAttributes) as R left join (select attributeID, attributeName from dgmAttributeTypes) as A where (A.attributeID = R.attributeID) and (R.typeID = 3300)

@class EveTable;
@class EveTypesTable;

@interface EveDatabase : NSObject <SQLBridgeDelegate> {
@private
}

+ (SQLBridge *)sharedBridge;
+ (EveDatabase *)sharedDatabase;
+ (NSError *)initError;
+ (EveTable *)attributes;
+ (EveTable *)groups;
+ (EveTypesTable *)types;

@end

@interface EveTable : SQLTable {

}

@end

@interface EveTypesTable : EveTable {
	
}

- (NSArray *)attributesForKey:(NSNumber *)typeID;
- (NSDictionary *)rowWithJoinedAttributesForKey:(NSString *)stringID;
- (NSDictionary *)joinAttributesForRow:(NSDictionary *)row;

@end