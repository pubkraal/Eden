//
//  Character.m
//  MacEFT
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveCharacter.h"
#import "EveSkill.h"
#import "EveCorporation.h"
#import "EveAlliance.h"
#import "EveAccount.h"

@implementation EveCharacter

@synthesize accountID, APIKey, characterID, fullAPI;
@synthesize portrait;
@synthesize corporation, alliance;
@synthesize name, race, bloodLine, ancestry, gender, cloneName;
@synthesize dateOfBirth;
@synthesize cloneSkillPoints, balance;
@synthesize intelligence, memory, charisma, perception, willpower;
@synthesize skills, certificates;

- (id)initWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey {

	if ((self = [super init])) {
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
		
		[self setSkills:[NSMutableArray array]];
		[self setCertificates:[NSMutableArray array]];
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

- (void)dealloc {
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

}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
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
	}

	return self;
}

- (void)setPortraitData:(NSData *)data {
	[portraitData release];
	portraitData = data;
	[portraitData retain];

	[portrait release];
	if (portraitData) portrait = [[NSImage alloc] initWithData:portraitData];
}

- (NSData *)portraitData {
	return portraitData;
}

- (void)setDateOfBirthWithString:(NSString *)date {
	date = [NSString stringWithFormat:@"%@ +0000", date];
	
	self.dateOfBirth = [NSDate dateWithString:date];
}
@end
