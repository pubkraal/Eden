//
//	CharacterSkillQueueController.m
//	Eden
//
//	Created by ugo pozo on 5/31/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterSkillQueueController.h"
#import "SkillCell.h"
#import "SKillCellController.h"
#import "EveCharacter.h"
#import "CharacterDocument.h"
#import "EveSkill.h"

@implementation CharacterSkillQueueController

- (id)init {
	if ((self = [super initWithNibName:@"CharacterSkillQueue" bundle:nil])) {
		skillControllers = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"skillsInQueue"]) {
		rootKeys = [NSSet setWithObject:@"document.character.trainingQueue"];
	}
	else if ([dependentKey isEqualToString:@"currentlyTraining"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining"];
	}
	else if ([dependentKey isEqualToString:@"nextSkillIn"]) {
		rootKeys = [NSSet setWithObjects:@"document.character.trainingQueue", @"document.character.skillInTraining", nil];
	}
	else if ([dependentKey isEqualToString:@"queueFinishes"]) {
		rootKeys = [NSSet setWithObjects:@"document.character.trainingQueue", @"document.character.skillInTraining", nil];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}

- (NSArray *)skillsInQueue {
	NSDictionary * node;
	NSMutableArray * queue;
	EveSkill * skill;
	
	queue = [NSMutableArray array];
	
	for (skill in self.document.character.trainingQueue) {
		node = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"leaf", skill, @"object", nil];
		
		[queue addObject:node];
	}
	
	return queue;
}

- (NSString *)currentlyTraining {
	EveSkill * training;
	NSString * ct;
	
	training = self.document.character.skillInTraining;
	ct       = (training) ? [NSString stringWithFormat:@"%@ %ld", training.name, [training.level integerValue] + 1] : nil;
	
	return ct;
}

- (NSString *)nextSkillIn {
	EveSkill * nextSkill;
	NSString * next;
	NSArray * queue;
	NSDateFormatter * formatter;
	
	queue     = self.skillsInQueue;
	nextSkill = ([queue count] > 1) ? [[queue objectAtIndex:1] objectForKey:@"object"] : nil;
	formatter = [[NSDateFormatter alloc] init];
	
	[formatter setDateStyle:NSDateFormatterLongStyle];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	
	next      = (self.document.character.skillInTraining && nextSkill) ? [formatter stringFromDate:nextSkill.startDate] : nil;
	
	[formatter release];
	
	return next;
}

- (NSString *)queueFinishes {
	EveSkill * lastSkill;
	NSArray * queue;
	NSDateFormatter * formatter;
	NSString * finishes;
	
	queue     = self.skillsInQueue;
	lastSkill = ([queue count] > 0) ? [[queue objectAtIndex:[queue count] - 1] objectForKey:@"object"] : nil;
	formatter = [[NSDateFormatter alloc] init];
	
	[formatter setDateStyle:NSDateFormatterLongStyle];
	[formatter setTimeStyle:NSDateFormatterMediumStyle];
	
	finishes  = (self.document.character.skillInTraining && lastSkill) ? [formatter stringFromDate:lastSkill.endDate] : nil;
	
	return finishes;
}

- (void)tableView:(NSTableView *)view willDisplayCell:(id)cellObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
	NSDictionary * node;
	SkillCellController * controller;
	SkillCell * cell;
	
	cell = (SkillCell *) cellObject;
	node = [self.skillsInQueue objectAtIndex:rowIndex];

	controller = [skillControllers objectForKey:node];

	if (!controller) {
		controller = [SkillCellController controllerWithNode:node];
		controller.document = self.document;
		[skillControllers setObject:controller forKey:node];
	}
	
	cell.controller = controller;
}

- (NSCell *)tableView:(NSTableView *)view dataCellForTableColumn:(NSTableColumn *)column row:(NSInteger)rowIndex {
	return [SkillCell cell];
}

- (void)documentWillClose {
	SkillCellController * controller;

	for (controller in [skillControllers allValues]) [controller documentWillClose];
	
	[super documentWillClose];
}

- (void)dealloc {
	skillQueueView.delegate = nil;
	
	[skillControllers release];
	
	
	[super dealloc];
}

@end
