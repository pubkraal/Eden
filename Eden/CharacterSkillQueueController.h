//
//	CharacterSkillQueueController.h
//	Eden
//
//	Created by ugo pozo on 5/31/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EveViewController.h"

@class SkillBar;

@interface CharacterSkillQueueController : EveViewController {
@private
	IBOutlet NSTableView * skillQueueView;
	IBOutlet SkillBar * skillBar;
	
	NSMutableDictionary * skillControllers;
}

@property (readonly) NSArray * skillsInQueue;

@property (readonly) NSString * currentlyTraining;
@property (readonly) NSColor * skillColor;

@property (readonly) NSString * trainingSpeed;
@property (readonly) NSString * timeLeft;
@property (readonly) NSString * nextSkillIn;
@property (readonly) NSString * queueFinishes;
@property (readonly) NSString * attributes;



@end
