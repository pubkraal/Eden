//
//  EveCorporation.m
//  Eden
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveCorporation.h"


@implementation EveCorporation

@synthesize name, corporationID, ticker;


- (id)initWithName:(NSString *)corpName andCorporationID:(NSString *)corpID {
	if ((self = [super init])) {
		self.name          = corpName;
		self.corporationID = corpID;
		self.ticker        = nil;
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:name forKey:@"corp.name"];
	[coder encodeObject:corporationID forKey:@"corp.corporationID"];
	[coder encodeObject:ticker forKey:@"corp.ticker"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		self.name          = [coder decodeObjectForKey:@"corp.name"];
		self.corporationID = [coder decodeObjectForKey:@"corp.corporationID"];
		self.ticker        = [coder decodeObjectForKey:@"corp.ticker"];
	}

	return self;
}

- (void)dealloc {
	self.name          = nil;
	self.corporationID = nil;
	self.ticker        = nil;

	[super dealloc];
}

+ (id)corporationWithName:(NSString *)corpName andCorporationID:(NSString *)corpID {
	return [[[self alloc] initWithName:corpName andCorporationID:corpID] autorelease];
}

@end
