//
//  Skill.m
//  Eden
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveSkill.h"
#import "EveDatabase.h"
#import "EveCharacter.h"
#import "EveEquations.h"
#import "NSDateComponents+EnglishRepresentation.h"
#import <stdlib.h>

NSDictionary * rawSkills = nil;
NSCalendarUnit units = NSMonthCalendarUnit | NSWeekCalendarUnit |
						NSDayCalendarUnit | NSHourCalendarUnit |
						NSMinuteCalendarUnit | NSSecondCalendarUnit;

@implementation EveSkill

@synthesize data, primaryAttribute, secondaryAttribute, level, character;
@synthesize isTraining, startDate, endDate;

- (id)initWithSkillID:(NSString *)skillID {
	if ((self = [self init])) {
		self.character = nil;
		self.data = [[self class] cachedAttributedSkillWithSkillID:skillID];
		self.primaryAttribute = [[[EveDatabase attributes] rowWithSingleKey:[self.data objectForKey:@"primaryAttribute"]] objectForKey:@"attributeName"];
		self.secondaryAttribute = [[[EveDatabase attributes] rowWithSingleKey:[self.data objectForKey:@"secondaryAttribute"]] objectForKey:@"attributeName"];
		self.skillPoints = nil;
		self.level = nil;
		
		self.isTraining = NO;
		self.startDate  = nil;
		self.endDate    = nil;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [self init])) {
		self.character          = [coder decodeObjectForKey:@"skill.char"];
		self.data               = [[self class] cachedAttributedSkillWithSkillID:[coder decodeObjectForKey:@"skill.typeID"]];
		self.primaryAttribute   = [coder decodeObjectForKey:@"skill.primaryAttribute"];
		self.secondaryAttribute = [coder decodeObjectForKey:@"skill.secondaryAttribute"];
		self.skillPoints        = [coder decodeObjectForKey:@"skill.skillPoints"];
		self.level              = [coder decodeObjectForKey:@"skill.level"];
		self.isTraining         = [coder decodeBoolForKey:@"skill.isTraining"];
		self.startDate          = [coder decodeObjectForKey:@"skill.startDate"];
		self.endDate            = [coder decodeObjectForKey:@"skill.endDate"];
	}
	
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	EveSkill * copy;
	
	copy = [[EveSkill allocWithZone:zone] init];
	
	copy.character          = character;
	copy.data               = [[data copyWithZone:zone] autorelease];
	copy.primaryAttribute   = [[primaryAttribute copyWithZone:zone] autorelease];
	copy.secondaryAttribute = [[secondaryAttribute copyWithZone:zone] autorelease];
	copy.skillPoints        = [[skillPoints copyWithZone:zone] autorelease];
	copy.level              = [[level copyWithZone:zone] autorelease];
	copy.isTraining         = isTraining;
	copy.startDate          = [[startDate copyWithZone:zone] autorelease];
	copy.endDate            = [[endDate copyWithZone:zone] autorelease];
	
	return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[data objectForKey:@"typeID"] forKey:@"skill.typeID"];
	[coder encodeObject:primaryAttribute forKey:@"skill.primaryAttribute"];
	[coder encodeObject:secondaryAttribute forKey:@"skill.secondaryAttribute"];
	[coder encodeObject:skillPoints forKey:@"skill.skillPoints"];
	[coder encodeObject:level forKey:@"skill.level"];
	[coder encodeObject:character forKey:@"skill.char"];
	[coder encodeBool:isTraining forKey:@"skill.isTraining"];
	[coder encodeObject:startDate forKey:@"skill.startDate"];
	[coder encodeObject:endDate forKey:@"skill.endDate"];
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

- (void)setSkillPoints:(NSNumber *)skPoints {
	[skPoints retain];
	[skillPoints release];
	
	skillPoints = skPoints;
}

- (NSNumber *)skillPoints {
	NSNumber * skPoints;
	double speed, target, dskPoints;
	NSUInteger primary, secondary;
	NSTimeInterval secondsLeft;
	
	if (isTraining && character) {
		primary   = [(NSNumber *) [character valueForKey:self.primaryAttribute] unsignedIntegerValue];
		secondary = [(NSNumber *) [character valueForKey:self.secondaryAttribute] unsignedIntegerValue];
		speed     = EveTrainingSpeedInMinutes(primary, secondary) / 60.0; // SP/second
		target    = [[self neededForNextLevel] doubleValue];
		
		secondsLeft = [self.endDate timeIntervalSinceDate:[NSDate dateWithTimeIntervalSinceNow:[[character skillTimeOffset] doubleValue]]];
		dskPoints   = target - (secondsLeft * speed);
		
		if (dskPoints < 0) dskPoints = target;
		
		skPoints = [NSNumber numberWithInteger:(NSUInteger) dskPoints + 0.5];
	}
	else skPoints = skillPoints;
	
	return skPoints;
}

- (NSUInteger)neededForLevel:(NSUInteger)lvl {
	NSUInteger needed;
	
	if (lvl > 5) lvl = 5;
	
	needed = (!lvl) ? 0 : EveSkillPointsForLevel(lvl, [[self.data objectForKey:@"skillTimeConstant"] unsignedIntegerValue]);
	
	return needed;
}

- (NSString *)name {
	return [self.data objectForKey:@"typeName"];
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
	NSString * desc;
	NSDate * nextLevelDate;
	NSDateComponents * components;
	
	desc = [NSString stringWithFormat:@"Primary attribute: %@\nSecondary attribute: %@\n\nDescription: %@",
			[self.primaryAttribute capitalizedString],
			[self.secondaryAttribute capitalizedString],
			[self.data objectForKey:@"description"]];

	if (self.character) {
		desc = [desc stringByAppendingFormat:@"\n\nTraining speed: %@ SP/hour", [self.character speedForSkill:self]];
	}
	
	if ([level integerValue] < 5) {
		if (!isTraining) {
			nextLevelDate = [NSDate dateWithTimeIntervalSinceNow:([self.neededForNextLevel doubleValue] - [self.skillPoints doubleValue]) / [[self.character speedForSkill:self] doubleValue] * 3600.0];
			components    = [[NSCalendar currentCalendar] components:units fromDate:[NSDate date] toDate:nextLevelDate options:0];
			desc          = [desc stringByAppendingFormat:@"\nNext level in: %@", [components englishRepresentation]];
		}
		else desc = [desc stringByAppendingFormat:@"\nFinishes in %@.", self.finishesIn];
	}
			
	return desc;
}

- (NSString *)currentStatus {
	NSString * status;
	NSNumberFormatter * format;
	
	format = [[NSNumberFormatter alloc] init];
	[format setNumberStyle:NSNumberFormatterDecimalStyle];

	status = [NSString stringWithFormat:@"SP: %@ / %@", [format stringFromNumber:self.skillPoints], [format stringFromNumber:self.neededForNextLevel]];

	[format release];
	
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
	
	return (target > 0) ? [NSNumber numberWithDouble:(sp / target)] : [NSNumber numberWithInteger:1];
}

- (NSNumber *)nextLevel {
	NSInteger current;
	
	current = [level integerValue];
	
	if (current < 5) current++;
	
	return [NSNumber numberWithInteger:current];
}

- (NSString *)finishesIn {
	NSDate * eveNow;
	NSDateComponents * components;
	
	if (!isTraining) return nil;
	
	eveNow     = [NSDate dateWithTimeIntervalSinceNow:[[character skillTimeOffset] doubleValue]];
	components = [[NSCalendar currentCalendar] components:units fromDate:eveNow toDate:self.endDate options:0];
	
	return [components englishRepresentation];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"currentStatus"]) {
		rootKeys = [NSSet setWithObject:@"skillPoints"];
	}
	else if ([dependentKey isEqualToString:@"percentComplete"]) {
		rootKeys = [NSSet setWithObject:@"skillPoints"];
	}
	else if ([dependentKey isEqualToString:@"finishesIn"]) {
		rootKeys = [NSSet setWithObject:@"skillPoints"];
	}
	else if ([dependentKey isEqualToString:@"neededForNextLevel"]) {
		rootKeys = [NSSet setWithObject:@"level"];
	}
	else if ([dependentKey isEqualToString:@"neededForCurrentLevel"]) {
		rootKeys = [NSSet setWithObject:@"level"];
	}
	else if ([dependentKey isEqualToString:@"nextLevel"]) {
		rootKeys = [NSSet setWithObject:@"level"];
	}
	else if ([dependentKey isEqualToString:@"attributesDescription"]) {
		rootKeys = [NSSet setWithObjects:@"character.intelligence",
											@"character.memory",
											@"character.charisma",
											@"character.perception",
											@"character.willpower",
											@"skillPoints",
											nil];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@", self.name, self.level];
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
