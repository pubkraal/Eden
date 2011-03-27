//
//  Character.h
//  MacEFT
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Skill.h"
#import "EveCorporation.h"
#import "EveAlliance.h"

typedef unsigned int uint;

@interface Character : NSObject {
    // All information taken from the API as described on:
    // http://wiki.eve-id.net/APIv2_Char_CharacterSheet_XML
    // Please refer to that webpage for more information on the properties.

    uint userID;
    NSString *apiKey;
    uint characterID;

    NSString *name;
    NSString *race;         // Normalize?
    NSDate *dateOfBirth;
    NSString *bloodLine;    // Normalize/ignore?
    NSString *ancestry;     // Normalize/ignore?
    NSString *gender;       // Normalize?
    uint corporationID;     // Normalized!
    uint allianceID;        // Normalized!
    NSString *cloneName;
    uint cloneSkillPoints;
    double balance;

    NSArray *skills;
    EveCorporation *corporation;
    EveAlliance *alliance;
}

- (void)importFromAPI:(int)characterId;
- (void)updateFromAPI;

- (void)loadSkills;
- (float)getTotalCPUBonus;
- (float)getTotalPowergridBonus;

// We also need these functions for capacitor, but they're currently less
// important.

@property(readonly) NSString *name;

@end
