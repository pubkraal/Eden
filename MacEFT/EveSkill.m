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

NSDictionary * rawSkills = nil;

@implementation EveSkill

@synthesize data, primaryAttribute, secondaryAttribute, skillPoints, level;

- (id)initWithSkillID:(NSString *)skillID {
	if ((self = [self init])) {
		self.data = [[self class] cachedAttributedSkillWithSkillID:skillID];
		self.primaryAttribute = [[[EveDatabase attributes] rowWithSingleKey:[self.data objectForKey:@"primaryAttribute"]] objectForKey:@"attributeName"];
		self.secondaryAttribute = [[[EveDatabase attributes] rowWithSingleKey:[self.data objectForKey:@"secondaryAttribute"]] objectForKey:@"attributeName"];
		self.skillPoints = nil;
		self.level = nil;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [self init])) {
		self.data = [[self class] cachedAttributedSkillWithSkillID:[coder decodeObjectForKey:@"skill.typeID"]];
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

+ (NSDictionary *)cachedAttributedSkillWithSkillID:(NSString *)skillID {
	static NSMutableDictionary * cachedAttributedSkills = nil;
	NSDictionary * rawSkill;
	
	if (!cachedAttributedSkills) cachedAttributedSkills = [[NSMutableDictionary alloc] init];
	
	rawSkill = [cachedAttributedSkills objectForKey:skillID];
	
	if (!rawSkill) {
		rawSkill = [rawSkills objectForKey:[NSNumber numberWithInteger:[skillID integerValue]]];
		rawSkill = [[EveDatabase types] joinAttributesForRow:rawSkill];
		[cachedAttributedSkills setObject:rawSkill forKey:skillID];
	}
	
	return rawSkill;
}

+ (void)cacheRawSkills {
	NSDictionary * row;
	NSMutableDictionary * mutableSkills;
	
	mutableSkills = [NSMutableDictionary dictionary];
	
	for (row in [[[[EveDatabase sharedBridge] views] objectForKey:@"skills"] rows]) {
		[mutableSkills setObject:row forKey:[row objectForKey:@"typeID"]];
	}

	if (rawSkills) [rawSkills release];
	
	rawSkills = [[NSDictionary alloc] initWithDictionary:mutableSkills];
	
}

- (NSUInteger)neededForLevel:(NSUInteger)lvl {
	double needed, rank;
	
	if (lvl > 5) lvl = 5;
	
	if (lvl) {
		rank   = [[self.data objectForKey:@"skillTimeConstant"] doubleValue];
		needed = pow(2.0, (2.5 * (double) lvl) - 2.5) * 250.0 * rank;
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
	return [NSString stringWithFormat:@"Primary attribute: %@\nSecondary attribute: %@\n\nDescription: %@", [self.primaryAttribute capitalizedString], [self.secondaryAttribute capitalizedString], [self.data objectForKey:@"description"]];
}

- (NSString *)currentStatus {
	NSString * status;
	NSNumberFormatter * format;
	
	if ([self.level intValue] == 5) {
		status = @"Mastered";
	}
	else {
		format = [[NSNumberFormatter alloc] init];
		[format setNumberStyle:NSNumberFormatterDecimalStyle];

		status = [NSString stringWithFormat:@"SP: %@ / %@", [format stringFromNumber:self.skillPoints], [format stringFromNumber:self.neededForNextLevel]];

		[format release];
	}
	
	return status;
}

- (NSString *)skillGroup {
	return [[[EveDatabase groups] rowWithSingleKey:[self.data objectForKey:@"groupID"]] objectForKey:@"groupName"];
}

- (NSNumber *)percentComplete {
	double current, sp, target;
	
	current = [[self neededForCurrentLevel] doubleValue];
	target  = [[self neededForNextLevel] doubleValue] - current;
	sp      = [self.skillPoints doubleValue] - current;
	
	return (target) ? [NSNumber numberWithDouble:(sp / target)] : [NSNumber numberWithInteger:1];
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
