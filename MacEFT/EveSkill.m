//
//  Skill.m
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveSkill.h"
#import "EveDatabase.h"
#import <math.h>

@implementation EveSkill

@synthesize data, primaryAttribute, secondaryAttribute, skillPoints, level;

- (id)initWithSkillID:(NSString *)skillID {
	if ((self = [self init])) {
		self.data = [[self class] cachedRawSkillWithSkillID:skillID];
		self.primaryAttribute = [[[EveDatabase attributes] rowWithSingleKey:[self.data objectForKey:@"primaryAttribute"]] objectForKey:@"attributeName"];
		self.secondaryAttribute = [[[EveDatabase attributes] rowWithSingleKey:[self.data objectForKey:@"secondaryAttribute"]] objectForKey:@"attributeName"];
		self.skillPoints = nil;
		self.level = nil;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [self init])) {
		self.data = [[self class] cachedRawSkillWithSkillID:[coder decodeObjectForKey:@"skill.typeID"]];
		self.primaryAttribute = [coder decodeObjectForKey:@"skill.primaryAttribute"];
		self.secondaryAttribute = [coder decodeObjectForKey:@"skill.secondaryAttribute"];
		self.skillPoints = [coder decodeObjectForKey:@"skill.skillPoints"];
		self.level = [coder decodeObjectForKey:@"skill.level"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[data objectForKey:@"typeID"] forKey:@"skill.typeID"];
	[coder encodeObject:primaryAttribute forKey:@"skill.primaryAttribute"];
	[coder encodeObject:secondaryAttribute forKey:@"skill.secondaryAttribute"];
	[coder encodeObject:skillPoints forKey:@"skill.skillPoints"];
	[coder encodeObject:level forKey:@"skill.level"];
}

+ (id)skillWithSkillID:(NSString *)skillID {
	return [[[self alloc] initWithSkillID:skillID] autorelease];
}

+ (NSDictionary *)cachedRawSkillWithSkillID:(NSString *)skillID {
	static NSMutableDictionary * cachedRawSkills = nil;
	NSDictionary * rawSkill;
	
	if (!cachedRawSkills) cachedRawSkills = [[NSMutableDictionary alloc] init];
	
	rawSkill = [cachedRawSkills objectForKey:skillID];
	
	if (!rawSkill) {
		rawSkill = [[EveDatabase types] rowWithJoinedAttributesForKey:skillID];
		[cachedRawSkills setObject:rawSkill forKey:skillID];
	}
	
	return rawSkill;
}

- (NSUInteger)neededForLevel:(NSUInteger)lvl {
	NSUInteger rank;
	double needed;
	
	if (lvl > 5) lvl = 5;
	
	if (lvl) {
		rank   = [[self.data objectForKey:@"skillTimeConstant"] unsignedIntegerValue];
		needed = pow(2.0, (2.5 * (double) lvl) - 2.5) * 250.0 * (double) rank;
	}
	else needed = 0.0;
	
	return (NSUInteger) floor(needed + 0.5);
}

- (NSNumber *)neededForNextLevel {
	NSUInteger nextLevel, needed;
	
	nextLevel = ([self.level unsignedIntegerValue] == 5) ? 4 : [self.level unsignedIntegerValue];
	nextLevel++;
	
	needed = [self neededForLevel:nextLevel];
	
	return [NSNumber numberWithInteger:needed];
}

- (NSNumber *)neededForCurrentLevel {
	NSUInteger needed;
	
	if ([self.level unsignedIntegerValue] == 5) {
		needed = 0;
	}
	else {
		needed = [self neededForLevel:[self.level unsignedIntegerValue]];
	}
	
	return [NSNumber numberWithInteger:needed];
}

- (NSString *)attributesDescription {
	return [NSString stringWithFormat:@"Primary attribute: %@\nSecondary attribute: %@", [self.primaryAttribute capitalizedString], [self.secondaryAttribute capitalizedString]];
}

- (NSString *)currentStatus {
	NSString * status;
	
	if ([self.level intValue] == 5) {
		status = @"Mastered";
	}
	else {
		status = [NSString stringWithFormat:@"%@ / %@", self.skillPoints, self.neededForNextLevel];
	}
	
	return status;
}

- (void)dealloc {
	self.data = nil;
	self.primaryAttribute = nil;
	self.secondaryAttribute = nil;
	self.skillPoints = nil;
	self.level = nil;
	
	[super dealloc];
}

@end
