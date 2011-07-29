//
//  Character.m
//  Eden
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveCharacter.h"
#import "EveSkill.h"
#import "EveCorporation.h"
#import "EveAlliance.h"
#import "EveAccount.h"
#import "EveSkill.h"
#import "EveEquations.h"
#import "EveAPI.h"

@implementation EveCharacter

@synthesize accountID, APIKey, characterID, fullAPI;
@synthesize portraitData;
@synthesize corporation, alliance;
@synthesize name, race, bloodLine, ancestry, gender, cloneName;
@synthesize dateOfBirth;
@synthesize cloneSkillPoints, balance;
@synthesize intelligence, memory, charisma, perception, willpower;
@synthesize skills, certificates, skillsArray;
@synthesize skillInTraining, skillTimeOffset;
@synthesize trainingQueue;

- (id)initWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey {

	if ((self = [super init])) {
		[self addObserver:self forKeyPath:@"skills" options:NSKeyValueObservingOptionNew context:NULL];

		[self setAccountID:accID];
		[self setAPIKey:APKey];
		[self setCharacterID:nil];
		[self setFullAPI:NO];

		[self setPortraitData:nil];

		[self setCorporation:nil];
		[self setAlliance:nil];

		[self setName:nil];
		[self setRace:nil];
		[self setBloodLine:nil];
		[self setAncestry:nil];
		[self setGender:nil];
		[self setCloneName:nil];

		[self setDateOfBirth:nil];

		[self setCloneSkillPoints:nil];
		[self setBalance:nil];

		[self setIntelligence:nil];
		[self setMemory:nil];
		[self setCharisma:nil];
		[self setPerception:nil];
		[self setWillpower:nil];

		[self setSkills:[NSMutableDictionary dictionary]];
		[self setCertificates:[NSMutableDictionary dictionary]];

		[self setSkillInTraining:nil];
		[self setSkillTimeOffset:[NSNumber numberWithDouble:0.0]];

		[self setTrainingQueue:nil];

	}

	return self;
}


- (id)initWithCharacter:(EveCharacter *)character {
	return [self initWithAccountID:character.accountID andAPIKey:character.APIKey];
}

+ (id)characterWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey {
	return [[[self alloc] initWithAccountID:accID andAPIKey:APKey] autorelease];
}

+ (id)characterWithCharacter:(EveCharacter *)character {
	return [[[self alloc] initWithCharacter:character] autorelease];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Character {\n\tname: %@;\n\tcharacterID: %@;\n\tfullAPI: %d;\n\taccountID: %@;\n\tcorporation.ID: %@;\n\tcorporation.name: %@\n}",
					name, characterID, fullAPI, accountID, corporation.corporationID, corporation.name];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"skills"]) {
		[self updateSkillsArray];
	}
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"skills"];

	[self setAccountID:nil];
	[self setAPIKey:nil];
	[self setCharacterID:nil];

	[self setPortraitData:nil];

	[self setCorporation:nil];
	[self setAlliance:nil];

	[self setName:nil];
	[self setRace:nil];
	[self setBloodLine:nil];
	[self setAncestry:nil];
	[self setGender:nil];
	[self setCloneName:nil];

	[self setDateOfBirth:nil];

	[self setCloneSkillPoints:nil];
	[self setBalance:nil];

	[self setIntelligence:nil];
	[self setMemory:nil];
	[self setCharisma:nil];
	[self setPerception:nil];
	[self setWillpower:nil];

	[self setSkills:nil];
	[self setCertificates:nil];
	[self setSkillInTraining:nil];
	[self setSkillTimeOffset:nil];
	[self setTrainingQueue:nil];

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:accountID forKey:@"char.accountID"];
	[coder encodeObject:APIKey forKey:@"char.APIKey"];
	[coder encodeObject:characterID forKey:@"char.characterID"];
	[coder encodeBool:fullAPI forKey:@"char.fullAPI"];

	[coder encodeObject:corporation forKey:@"char.corporation"];
	[coder encodeObject:alliance forKey:@"char.alliance"];

	[coder encodeObject:name forKey:@"char.name"];
	[coder encodeObject:race forKey:@"char.race"];
	[coder encodeObject:bloodLine forKey:@"char.bloodLine"];
	[coder encodeObject:ancestry forKey:@"char.ancestry"];
	[coder encodeObject:gender forKey:@"char.gender"];
	[coder encodeObject:cloneName forKey:@"char.cloneName"];

	[coder encodeObject:dateOfBirth forKey:@"char.dateOfBirth"];

	[coder encodeObject:cloneSkillPoints forKey:@"char.cloneSkillPoints"];
	[coder encodeObject:balance forKey:@"char.balance"];

	[coder encodeObject:intelligence forKey:@"char.intelligence"];
	[coder encodeObject:memory forKey:@"char.memory"];
	[coder encodeObject:charisma forKey:@"char.charisma"];
	[coder encodeObject:perception forKey:@"char.perception"];
	[coder encodeObject:willpower forKey:@"char.willpower"];

	[coder encodeObject:skills forKey:@"char.skills"];
	[coder encodeObject:certificates forKey:@"char.certificates"];
	[coder encodeObject:skillInTraining forKey:@"char.skillInTraining"];
	[coder encodeObject:skillTimeOffset forKey:@"char.skillTimeOffset"];

	[coder encodeObject:trainingQueue forKey:@"char.trainingQueue"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		[self addObserver:self forKeyPath:@"skills" options:NSKeyValueObservingOptionNew context:NULL];

		self.accountID        = [coder decodeObjectForKey:@"char.accountID"];
		self.APIKey           = [coder decodeObjectForKey:@"char.APIKey"];
		self.characterID      = [coder decodeObjectForKey:@"char.characterID"];
		self.fullAPI          = [coder decodeBoolForKey:@"char.fullAPI"];

		self.corporation      = [coder decodeObjectForKey:@"char.corporation"];
		self.alliance         = [coder decodeObjectForKey:@"char.alliance"];

		self.name             = [coder decodeObjectForKey:@"char.name"];
		self.race             = [coder decodeObjectForKey:@"char.race"];
		self.bloodLine        = [coder decodeObjectForKey:@"char.bloodLine"];
		self.ancestry         = [coder decodeObjectForKey:@"char.ancestry"];
		self.gender           = [coder decodeObjectForKey:@"char.gender"];
		self.cloneName        = [coder decodeObjectForKey:@"char.cloneName"];

		self.dateOfBirth      = [coder decodeObjectForKey:@"char.dateOfBirth"];

		self.cloneSkillPoints = [coder decodeObjectForKey:@"char.cloneSkillPoints"];
		self.balance          = [coder decodeObjectForKey:@"char.balance"];

		self.intelligence     = [coder decodeObjectForKey:@"char.intelligence"];
		self.memory           = [coder decodeObjectForKey:@"char.memory"];
		self.charisma         = [coder decodeObjectForKey:@"char.charisma"];
		self.perception       = [coder decodeObjectForKey:@"char.perception"];
		self.willpower        = [coder decodeObjectForKey:@"char.willpower"];

		self.skills           = [coder decodeObjectForKey:@"char.skills"];
		self.certificates     = [coder decodeObjectForKey:@"char.certificates"];
		self.skillInTraining  = [coder decodeObjectForKey:@"char.skillInTraining"];
		self.skillTimeOffset  = [coder decodeObjectForKey:@"char.skillTimeOffset"];

		self.trainingQueue    = [coder decodeObjectForKey:@"char.trainingQueue"];

	}

	return self;
}

- (NSImage *)portrait {
	return (portraitData) ? [[[NSImage alloc] initWithData:portraitData] autorelease] : nil;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;

	if ([dependentKey isEqualToString:@"portrait"]) {
		rootKeys = [NSSet setWithObject:@"portraitData"];
	}
	else if ([dependentKey isEqualToString:@"formattedBalance"]) {
		rootKeys = [NSSet setWithObject:@"balance"];
	}
	else if ([dependentKey isEqualToString:@"formattedCloneSkillPoints"]) {
		rootKeys = [NSSet setWithObject:@"cloneSkillPoints"];
	}
	else if ([dependentKey isEqualToString:@"totalSkillPoints"]) {
		rootKeys = [NSSet setWithObject:@"skillInTraining.skillPoints"];
	}
	else rootKeys = [NSSet set];

	return rootKeys;
}

- (NSString *)formattedBalance {
	NSNumberFormatter * format;
	NSString * formatted;

	format = [[NSNumberFormatter alloc] init];
	[format setNumberStyle:NSNumberFormatterDecimalStyle];
	[format setMinimumFractionDigits:2];

	formatted = [format stringFromNumber:balance];

	[format release];

	return formatted;
}

- (NSString *)formattedCloneSkillPoints {
	NSNumberFormatter * format;
	NSString * formatted;

	format = [[NSNumberFormatter alloc] init];
	[format setNumberStyle:NSNumberFormatterDecimalStyle];

	formatted = [format stringFromNumber:cloneSkillPoints];

	[format release];

	return formatted;
}

- (NSNumber *)skillsAtV {
	NSPredicate * pred;

	pred = [NSPredicate predicateWithFormat:@"level >= 5"];

	return [NSNumber numberWithUnsignedInteger:[[self.skillsArray filteredArrayUsingPredicate:pred] count]];
}

- (NSString *)totalSkillPoints {
	NSUInteger sp;
	EveSkill * skill;
	NSNumberFormatter * format;

	sp = 0;

	for (skill in self.skillsArray) sp += [skill.skillPoints unsignedIntegerValue];

	format = [[[NSNumberFormatter alloc] init] autorelease];
	[format setNumberStyle:NSNumberFormatterDecimalStyle];

	return [format stringFromNumber:[NSNumber numberWithUnsignedInteger:sp]];
}

- (void)updateSkillsArray {
	if (skills) self.skillsArray = [skills allValues];
	else self.skillsArray = nil;
}

/* Returns the speed in SP/hour
 */

- (NSNumber *)speedForSkill:(EveSkill *)skill {
	NSUInteger primary, secondary, speed;

	primary   = [(NSNumber *)[self valueForKey:skill.primaryAttribute] unsignedIntegerValue];
	secondary = [(NSNumber *)[self valueForKey:skill.secondaryAttribute] unsignedIntegerValue];

	speed = EveTrainingSpeed(primary, secondary);

	return [NSNumber numberWithInteger:speed];
}

- (void)consolidateSkillInTrainingWithDictionary:(NSDictionary *)trainingData {
	EveSkill * skill;

	if (trainingData) {
		for (skill in [self.skills allValues]) {
			skill.isTraining = NO;
			skill.startDate  = nil;
			skill.endDate    = nil;
		}

		self.skillInTraining = [self.skills objectForKey:[trainingData objectForKey:@"trainingTypeID"]];

		self.skillInTraining.isTraining  = YES;
		self.skillInTraining.inQueue     = YES;
		self.skillInTraining.startDate   = CCPDate([trainingData objectForKey:@"trainingStartTime"]);
		self.skillInTraining.endDate     = CCPDate([trainingData objectForKey:@"trainingEndTime"]);
		self.skillInTraining.skillPoints = self.skillInTraining.skillPoints;
	}
}

- (void)consolidateSkillQueueWithArray:(NSArray *)queue {
	NSDictionary * queueDict;
	EveSkill * queueSkill, * previousSkill;
	NSMutableDictionary * skillsQueued;

	if (queue) {
		for (queueSkill in [self.skills allValues]) queueSkill.inQueue = NO;

		self.trainingQueue = [NSMutableArray array];

		queue = [queue sortedArrayUsingComparator:^(NSDictionary * d1, NSDictionary * d2) {
			NSNumber * n1, * n2;

			n1 = [NSNumber numberWithInteger:[[d1 objectForKey:@"queuePosition"] integerValue]];
			n2 = [NSNumber numberWithInteger:[[d2 objectForKey:@"queuePosition"] integerValue]];

			return (NSComparisonResult) [n1 compare:n2];
		}];

		skillsQueued = [NSMutableDictionary dictionary];

		for (queueDict in queue) {
			queueSkill = [self.skills objectForKey:[queueDict objectForKey:@"typeID"]];

			if ((previousSkill = [skillsQueued objectForKey:queueSkill.key])) {
				// This means we have the same skill twice in the skill queue. We take the last
				// time the skill appeared in the queue, copy it and correct the parameters for
				// the next iteration of the skill on the queue. This skill object is marked as
				// a "queue-only skill", and it's NOT added to the main skill dictionary of the
				// character.

				queueSkill = [[previousSkill copy] autorelease];

				queueSkill.startDate   = CCPDate([queueDict objectForKey:@"startTime"]);
				queueSkill.endDate     = CCPDate([queueDict objectForKey:@"endTime"]);
				queueSkill.skillPoints = previousSkill.neededForNextLevel;
				queueSkill.level       = previousSkill.nextLevel;
				queueSkill.isTraining  = NO;
				queueSkill.queueSkill  = YES;
			}
			else if (!queueSkill.isTraining) {
				queueSkill.startDate = CCPDate([queueDict objectForKey:@"startTime"]);
				queueSkill.endDate   = CCPDate([queueDict objectForKey:@"endTime"]);
			}

			queueSkill.inQueue = YES;

			[skillsQueued setObject:queueSkill forKey:queueSkill.key];

			[[self mutableArrayValueForKey:@"trainingQueue"] addObject:queueSkill];
		}
	}
}

- (void)updateSkillInTraining:(NSTimer *)timer {
	NSNumber * skPoints;
	EveSkill * nextSkill, * queueSkill;
	NSMutableArray * queueProxy;

	if (self.skillInTraining) {
		skPoints = self.skillInTraining.skillPoints;
		self.skillInTraining.skillPoints = skPoints;

		while ((skPoints) && ([skPoints integerValue] >= [self.skillInTraining.neededForNextLevel integerValue])) {
			// Training has finished
			queueProxy = [self mutableArrayValueForKey:@"trainingQueue"];

			self.skillInTraining.skillPoints = self.skillInTraining.neededForNextLevel;
			self.skillInTraining.level       = self.skillInTraining.nextLevel;
			self.skillInTraining.isTraining  = NO;
			self.skillInTraining.inQueue     = NO;

			nextSkill = ([queueProxy count] > 1) ? [queueProxy objectAtIndex:1] : nil;

			[queueProxy removeObjectAtIndex:0];

			if (nextSkill.queueSkill) {
				// If the next skill is a queue-only skill, we need to exchange it for the
				// skill object which is actually in the skills dictionary of the character.

				queueSkill = nextSkill;
				nextSkill  = [self.skills objectForKey:[[nextSkill.data objectForKey:@"typeID"] stringValue]];

				nextSkill.endDate   = queueSkill.endDate;
				nextSkill.startDate = queueSkill.startDate;

				[queueProxy replaceObjectAtIndex:0 withObject:nextSkill];
			}

			self.skillInTraining = nextSkill;
			self.skillInTraining.isTraining = YES;
			self.skillInTraining.inQueue    = YES;

			skPoints = self.skillInTraining.skillPoints;
			self.skillInTraining.skillPoints = skPoints;
		}
	}
}

@end
