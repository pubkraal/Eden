//
//  Skill.h
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EveSkill : NSObject {
@private
	NSDictionary * data;
	
}

@property (retain) NSDictionary * data;

- (id)initWithSkillID:(NSNumber *)skillID;

@end
