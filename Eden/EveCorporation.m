//
//  EveCorporation.m
//  Eden
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveCorporation.h"


@implementation EveCorporation

@synthesize name, corporationID;


- (id)initWithName:(NSString *)corpName andCorporationID:(NSString *)corpID {
	if ((self = [super init])) {
		self.name          = corpName;
		self.corporationID = corpID;
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"corp.name"];
	[coder encodeObject:corporationID forKey:@"corp.corporationID"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		self.name          = [coder decodeObjectForKey:@"corp.name"];
		self.corporationID = [coder decodeObjectForKey:@"corp.corporationID"];
	}

	return self;
}

- (void)dealloc {
	self.name          = nil;
	self.corporationID = nil;

	[super dealloc];
}

+ (id)corporationWithName:(NSString *)corpName andCorporationID:(NSString *)corpID {
	return [[[self alloc] initWithName:corpName andCorporationID:corpID] autorelease];
}

@end
