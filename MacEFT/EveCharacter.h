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

@interface EveCharacter : NSObject <NSCoding> {
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

	NSData * portraitData;
	NSImage * portrait;

	EveCorporation * corporation;
	EveAlliance * alliance;

	NSString *name;
	NSString * race;
	NSString * bloodLine;
	NSString * ancestry;
	NSString * gender;
	NSString * cloneName;

	NSDate *dateOfBirth;

	NSNumber * cloneSkillPoints;
	NSNumber * balance;

	NSNumber * intelligence;
	NSNumber * memory;
	NSNumber * charisma;
	NSNumber * perception;
	NSNumber * willpower;

	NSMutableArray * skills;
	NSMutableArray * certificates;
}

@property (retain) NSString * accountID, * APIKey, * characterID;
@property (assign) BOOL fullAPI;
@property (retain) NSData * portraitData;
@property (readonly) NSImage * portrait;

@property (retain) EveCorporation * corporation;
@property (retain) EveAlliance * alliance;

@property (retain) NSString * name, * race, * bloodLine, * ancestry;
@property (retain) NSString * gender, * cloneName;

@property (retain) NSDate * dateOfBirth;

@property (retain) NSNumber * cloneSkillPoints, * balance;
@property (retain) NSNumber * intelligence, * memory, * charisma;
@property (retain) NSNumber * perception, * willpower;

@property (retain) NSMutableArray * skills, * certificates;


- (id)initWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey;
- (id)initWithCharacter:(EveCharacter *)character;
+ (id)characterWithAccountID:(NSString *)accID andAPIKey:(NSString *)APKey;
+ (id)characterWithCharacter:(EveCharacter *)character;

- (void)setDateOfBirthWithString:(NSString *)date;

@end
