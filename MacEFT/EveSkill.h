//
//  Skill.h
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EveCharacter;

@interface EveSkill : NSObject <NSCoding, NSCopying> {
@private
	EveCharacter * character;
	
	NSDictionary * data;
	
	NSString * primaryAttribute;
	NSString * secondaryAttribute;
	
	NSNumber * skillPoints, * level;
	
	BOOL isTraining;
	NSDate * startDate;
	NSDate * endDate;
}

// Weak reference
@property (assign) EveCharacter * character;

@property (retain) NSDictionary * data;
@property (retain) NSString * primaryAttribute, * secondaryAttribute;
@property (retain) NSNumber * skillPoints, * level;
@property (assign) BOOL isTraining;
@property (retain) NSDate * startDate, * endDate;

@property (readonly) NSString * name;
@property (readonly) NSNumber * nextLevel;
@property (readonly) NSNumber * neededForNextLevel;
@property (readonly) NSNumber * neededForCurrentLevel;
@property (readonly) NSString * currentStatus;
@property (readonly) NSString * attributesDescription;
@property (readonly) NSString * skillGroup;
@property (readonly) NSNumber * percentComplete;
@property (readonly) NSString * finishesIn;


- (id)initWithSkillID:(NSString *)skillID;
+ (id)skillWithSkillID:(NSString *)skillID;
+ (NSDictionary *)cachedAttributedSkillWithSkillID:(NSString *)skillID;
+ (void)cacheRawSkills;

- (NSUInteger)neededForLevel:(NSUInteger)level;
@end
