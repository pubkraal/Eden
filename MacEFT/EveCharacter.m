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
@synthesize name, corporation, portrait;

- (id)initWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey {

	if ((self = [super init])) {
		[self setAccountID:accID];
		[self setAPIKey:APKey];
		[self setCharacterID:nil];
		[self setFullAPI:NO];
		[self setName:nil];
		[self setCorporation:nil];
		[self setPortrait:nil];
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
	return [NSString stringWithFormat:@"Character {\n\tname: %@;\n\tcharacterID: %@;\n\taccountID: %@;\n\tcorporation.ID: %@;\n\tcorporation.name: %@\n}",
					name, characterID, accountID, corporation.corporationID, corporation.name];
}

- (void)dealloc {
	[self setAccountID:nil];
	[self setAPIKey:nil];
	[self setCharacterID:nil];
	[self setName:nil];
	[self setCorporation:nil];
	[self setPortrait:nil];

	[super dealloc];
}

/*- (void)encodeWithCoder:(NSCoder *)coder {
	if ([coder isKindOfClass:[NSKeyedArchiver class]]) {
		

	}
	else {
		[NSException raise:NSInvalidArchiveOperationException
					format:@"Only supports NSKeyedArchiver coders"];
	}

}

- (id)initWithCoder:(NSCoder *)coder {

}*/


- (void)importFromAPI:(int)characterId {
    // Load the character from API.
}

- (void)updateFromAPI {
    // This basically does an import, but uses known information.
}

- (float)getTotalCPUBonus {
    return 0.0;
}

- (float)getTotalPowergridBonus {
    return 0.0;
}

- (void)loadSkills {
    // Not sure how to solve this
}


@end
