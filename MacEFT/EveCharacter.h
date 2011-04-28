//
//	Character.h
//	MacEFT
//
//	Created by John Kraal on 3/26/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EveSkill;
@class EveCorporation;
@class EveAlliance;
@class EveAccount;

// In Cocoa, unless you're inheriting from a specific class,
// or making a "generic" header for a list of subheaders,
// you do not include headers in other header files. You declare
// that the class exists somewhere with @class and include the
// header files in the .m file.

@interface EveCharacter : NSObject {
	// All information taken from the API as described on:
	// http://wiki.eve-id.net/APIv2_Char_CharacterSheet_XML
	// Please refer to that webpage for more information on the properties.

	/*uint userID;
	NSString *apiKey;
	uint characterID;
	*/

	// I changed that so that we can get our EveAccount model in here :)
	EveAccount * account;
	NSString * characterID;

	NSString *name;
	NSString *race;			// Normalize?
	NSDate *dateOfBirth;
	NSString *bloodLine;	// Normalize/ignore?
	NSString *ancestry;		// Normalize/ignore?
	NSString *gender;		// Normalize?
	uint corporationID;		// Normalized!
	uint allianceID;		// Normalized!
	NSString *cloneName;
	uint cloneSkillPoints;
	double balance;

	NSArray *skills;
	EveCorporation *corporation;
	EveAlliance *alliance;
}

@property (retain) EveAccount * account;

// TODO: make @properties for all the attributes in the character

- (void)importFromAPI:(int)characterId;
- (void)updateFromAPI;

- (void)loadSkills;
- (float)getTotalCPUBonus;
- (float)getTotalPowergridBonus;

// We also need these functions for capacitor, but they're currently less
// important.

@property(readonly) NSString *name;

@end
