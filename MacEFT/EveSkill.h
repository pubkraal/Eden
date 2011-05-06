//
//  Skill.h
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EveSkill : NSObject <NSCoding> {
@private
	NSDictionary * data;
	
	NSString * primaryAttribute;
	NSString * secondaryAttribute;
	
	NSNumber * skillPoints, * level;
}

@property (retain) NSDictionary * data;
@property (retain) NSString * primaryAttribute, * secondaryAttribute;
@property (retain) NSNumber * skillPoints, * level;
@property (readonly) NSNumber * neededForNextLevel;
@property (readonly) NSNumber * neededForCurrentLevel;
@property (readonly) NSString * currentStatus;
@property (readonly) NSString * attributesDescription;

- (id)initWithSkillID:(NSString *)skillID;

+ (id)skillWithSkillID:(NSString *)skillID;
+ (NSDictionary *)cachedRawSkillWithSkillID:(NSString *)skillID;

- (NSUInteger)neededForLevel:(NSUInteger)level;
@end
