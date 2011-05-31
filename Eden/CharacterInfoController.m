//
//	CharacterInfoController.m
//	Eden
//
//	Created by ugo pozo on 4/30/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterInfoController.h"
#import "CharacterDocument.h"
#import "EveCharacter.h"
#import "EveSkill.h"
#import "SkillCell.h"
#import "SkillCellController.h"

@implementation CharacterInfoController

@synthesize skillSortDescriptors, skillControllers;

- (id)init {
	if ((self = [super initWithNibName:@"CharacterInfo" bundle:nil])) {
		self.skillControllers     = [NSMutableDictionary dictionary];
		self.skillSortDescriptors = [NSArray arrayWithObjects:
										[NSSortDescriptor sortDescriptorWithKey:@"skillGroup" ascending:YES],
										[NSSortDescriptor sortDescriptorWithKey:@"data.typeName" ascending:YES],
										nil];
		
	}
	
	return self;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"skillTree"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skills"];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}

- (NSArray *)skillTree {
	NSMutableArray * skillTree;
	NSMutableDictionary * skillDict, * group;
	EveSkill * skill;
	NSDictionary * item;
	NSArray * descriptors, * itemDescriptors;
	
	skillTree = [NSMutableArray array];
	skillDict = [NSMutableDictionary dictionary];
	
	for (skill in [self.document.character.skills allValues]) {
		group = [skillDict objectForKey:skill.skillGroup];
		
		if (!group) {
			group = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool:NO], @"leaf",
								[NSMutableArray array], @"children",
								skill.skillGroup, @"object", nil];
			
			[skillDict setObject:group forKey:skill.skillGroup];
		}
		
		item = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool:YES], @"leaf",
								[NSNull null], @"children",
								skill, @"object", nil];
		
		[[group objectForKey:@"children"] addObject:item];
	}
	
	descriptors     = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"object" ascending:YES]];
	itemDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"object.name" ascending:YES]];
	
	for (group in [[skillDict allValues] sortedArrayUsingDescriptors:descriptors]) {
		[group setObject:[[group objectForKey:@"children"] sortedArrayUsingDescriptors:itemDescriptors] forKey:@"children"];
		[skillTree addObject:group];
	}
	
	return [NSArray arrayWithArray:skillTree];
}

- (void)hideSkill:(NSDictionary *)node {
	SkillCellController * controller;
	NSDictionary * child;
	
	controller = [skillControllers objectForKey:node];
	
	if (controller) {
		[controller removeSubviews];
		
		if ([node objectForKey:@"children"] != [NSNull null]) {
			for (child in [node objectForKey:@"children"]) [self hideSkill:child];
		}
	}
}


#pragma mark Delegated from NSOutlineView

- (void)outlineView:(NSOutlineView *)view willDisplayCell:(id)cellObject forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	NSDictionary * node;
	SkillCellController * controller;
	SkillCell * cell;
	
	cell = (SkillCell *) cellObject;
	node = [item representedObject];

	controller = [skillControllers objectForKey:node];

	if (!controller) {
		controller = [SkillCellController controllerWithNode:node];
		controller.document = self.document;
		[skillControllers setObject:controller forKey:node];
	}
	
	cell.controller = controller;
}

- (NSCell *)outlineView:(NSOutlineView *)view dataCellForTableColumn:(NSTableColumn *)column item:(id)item {
	return [SkillCell cell];
}

- (CGFloat)outlineView:(NSOutlineView *)view heightOfRowByItem:(id)item {
	NSDictionary * node;
	CGFloat height;
	
	node   = [item representedObject];
	height = ([[node objectForKey:@"leaf"] boolValue]) ? 42.0 : 19.0;
	
	return height;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notif {
	NSDictionary * node, * child;
	
	node = [[[notif userInfo] objectForKey:@"NSObject"] representedObject];
	
	for (child in [node objectForKey:@"children"]) [self hideSkill:child];
	
}

- (void)outlineViewItemDidExpand:(NSNotification *)notif {
	SkillCellController * controller;
	
	for (controller in [skillControllers allValues]) {
		// removing the subviews forces them to be redrawn in the
		// right place and avoid overlaps
		[controller removeSubviews];
	}

}

#pragma mark -

- (IBAction)expandAll:(id)sender {
	id item;
	
	for (item in [[skillTreeController arrangedObjects] childNodes]) {
		[skillsView expandItem:item];
	}
}

- (IBAction)collapseAll:(id)sender {
	id item;
	
	for (item in [[skillTreeController arrangedObjects] childNodes]) {
		[skillsView collapseItem:item];
	}
	
}

- (void)documentWillClose {
	SkillCellController * controller;

	for (controller in [skillControllers allValues]) [controller documentWillClose];
	
	[super documentWillClose];
}

- (void)dealloc {
	skillsView.delegate = nil;
	
	self.skillSortDescriptors = nil;
	self.skillControllers = nil;	
	
	[super dealloc];
}


@end