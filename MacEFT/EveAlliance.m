//
//  EveAlliance.m
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveAlliance.h"


@implementation EveAlliance

@synthesize name, allianceID;

- (id)initWithName:(NSString *)allName andAllianceID:(NSString *)allID {
	if ((self = [super init])) {
		self.allianceID = allID;
		self.name       = allName;
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		self.allianceID = [coder decodeObjectForKey:@"alliance.allianceID"];
		self.name       = [coder decodeObjectForKey:@"alliance.name"];
	}

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:allianceID forKey:@"alliance.allianceID"];
	[coder encodeObject:name forKey:@"alliance.name"];
}


+ (id)allianceWithName:(NSString *)allName andAllianceID:(NSString *)allID {
	return [[[self alloc] initWithName:allName andAllianceID:allID] autorelease];
}


- (void)dealloc {
	self.allianceID = nil;
	self.name       = nil;

	[super dealloc];
}

@end
