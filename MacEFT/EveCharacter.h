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
	// UPDATE: changed my mind. we can ditch EveAccount, it's more trouble than good.
	NSString * accountID;
	NSString * APIKey;
	NSString * characterID;
	BOOL fullAPI;

	NSImage * portrait;

	NSString *name;

	NSString * allianceID;		// Normalized!
	NSString *race;			// Normalize?
	NSDate *dateOfBirth;
	NSString *bloodLine;	// Normalize/ignore?
	NSString *ancestry;		// Normalize/ignore?
	NSString *gender;		// Normalize?
	NSString *cloneName;
	uint cloneSkillPoints;
	double balance;

	NSArray *skills;

	EveCorporation *corporation;
	EveAlliance *alliance;
}

@property (retain) NSString * accountID, * APIKey, * characterID;
@property (assign) BOOL fullAPI;

@property (retain) NSString * name;
@property (retain) NSImage * portrait;
@property (retain) EveCorporation * corporation;


- (id)initWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey;
- (id)initWithCharacter:(EveCharacter *)character;
+ (id)characterWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey;
+ (id)characterWithCharacter:(EveCharacter *)character;

// TODO: make @properties for all the attributes in the character

- (void)importFromAPI:(int)characterId;
- (void)updateFromAPI;

- (void)loadSkills;
- (float)getTotalCPUBonus;
- (float)getTotalPowergridBonus;

// We also need these functions for capacitor, but they're currently less
// important.


@end
