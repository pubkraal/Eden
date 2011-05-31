//
//  EveShip.m
//  Eden
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveShip.h"
#import "SQLBridge.h"

@implementation EveShip

- (id)initWithBridge:(SQLBridge *)bridge andShipID:(NSNumber *)shipID {
	NSMutableDictionary * shipInfo;
	NSDictionary * attr;
	NSArray * shipAttributes;
	NSString * attrName;
	NSNumber * attrVal;
	SQLTable * typeAttrRel, * types, * attributes;

	if ((self = [super init])) {
		typeAttrRel = [[bridge views] objectForKey:@"dgmTypeAttributes"];
		types       = [[bridge views] objectForKey:@"invTypes"];
		attributes  = [[bridge views] objectForKey:@"dgmAttributeTypes"];
		
		shipInfo = [NSMutableDictionary dictionaryWithDictionary:[types rowWithKey:[NSArray arrayWithObject:shipID]]];
		
		shipAttributes = [typeAttrRel filteredRowsWithPredicateFormat:@"typeID = %@", shipID];
		// ^^ if we had foreign keys: [types foreignObjectsInTable:typeAttrRel usingPrimaryKeyForRow:shipInfo]; :(
		
		for (attr in shipAttributes) {
			attrName = [[attributes rowWithKey:[NSArray arrayWithObject:[attr objectForKey:@"attributeID"]]] objectForKey:@"attributeName"];
			// ^^ if we had foreign keys: [[attributes foreignObjectForKey:@"attributeID" inRow:attr] objectForKey:@"attributeName"]; :(
			
			if ([attr objectForKey:@"valueInt"] == [NSNull null]) attrVal = [attr objectForKey:@"valueFloat"];
			else attrVal = [attr objectForKey:@"valueInt"];

			[shipInfo setObject:attrVal forKey:attrName];
		}

		NSLog(@"%@", shipInfo);
	}

	return self;
}

+ (id)shipWithBridge:(SQLBridge *)bridge andShipID:(NSNumber *)shipID {
	return [[[self alloc] initWithBridge:bridge andShipID:shipID] autorelease];
}

@synthesize highSlots, medSlots, lowSlots, missileHardPoints, turretHardpoints;
@synthesize basePowergrid, baseCPU;

@end
