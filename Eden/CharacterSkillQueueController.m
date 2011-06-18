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
#import "SkillBar.h"

@implementation CharacterSkillQueueController

- (id)init {
	if ((self = [super initWithNibName:@"CharacterSkillQueue" bundle:nil])) {
		skillControllers = [[NSMutableDictionary alloc] init];
		
		[self addObserver:self forKeyPath:@"skillsInQueue" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
	return self;
}

- (void)awakeFromNib {
	[skillBar bind:@"character" toObject:self withKeyPath:@"document.character" options:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SkillCellController * controller;
	
	if ([keyPath isEqualToString:@"skillsInQueue"]) {
		for (controller in [skillControllers allValues]) {
			[controller removeSubviews];
		}
	}
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"skillsInQueue"]) {
		rootKeys = [NSSet setWithObject:@"document.character.trainingQueue"];
	}
	else if ([dependentKey isEqualToString:@"currentlyTraining"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining"];
	}
	else if ([dependentKey isEqualToString:@"skillColor"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining"];
	}
	else if ([dependentKey isEqualToString:@"trainingSpeed"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining"];
	}
	else if ([dependentKey isEqualToString:@"timeLeft"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining.finishesIn"];
	}
	else if ([dependentKey isEqualToString:@"attributes"]) {
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
	NSMutableDictionary * node;
	NSMutableArray * queue;
	EveSkill * skill;

	queue    = [NSMutableArray array];
	
	for (skill in self.document.character.trainingQueue) {
		node = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"leaf",
																	skill.nextLevel, @"toLevel",
																	skill, @"object",
																	nil];
																	
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

- (NSColor *)skillColor {
	return (self.document.character.skillInTraining) ? [NSColor blackColor] : [NSColor redColor];
}

- (NSString *)trainingSpeed {
	EveSkill * skill;
	EveCharacter * theChar;
	
	theChar = self.document.character;
	skill   = theChar.skillInTraining;
	
	return (skill) ? [NSString stringWithFormat:@"%@ SP/hour", [theChar speedForSkill:skill]] : nil;
}

- (NSString *)timeLeft {
	EveSkill * skill;
	
	skill = self.document.character.skillInTraining;
	
	return (skill) ? skill.finishesIn : nil;
}

- (NSString *)attributes {
	EveSkill * skill;

	skill = self.document.character.skillInTraining;
	
	return (skill) ? [NSString stringWithFormat:@"%@, %@", [skill.primaryAttribute capitalizedString], [skill.secondaryAttribute capitalizedString]]: nil;
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
	
	[skillBar unbind:@"queue"];

	for (controller in [skillControllers allValues]) [controller documentWillClose];
	
	[super documentWillClose];
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"skillsInQueue"];
	
	skillQueueView.delegate = nil;
	
	[skillControllers release];
	
	
	[super dealloc];
}

@end
