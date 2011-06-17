//
//	SkillCellController.m
//	Eden
//
//	Created by ugo pozo on 5/23/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "SkillCellController.h"
#import "CharacterDocument.h"
#import "EveSkill.h"

@implementation SkillCellController

@synthesize skill, node, isGroup, textColor;

- (id)initWithNode:(NSDictionary *)aNode {
	if ((self = [super initWithNibName:@"SkillView" bundle:nil])) {
		self.node    = aNode;
		self.isGroup = ![[node objectForKey:@"leaf"] boolValue];
		self.skill   = (!isGroup) ? (EveSkill *) [node objectForKey:@"object"] : nil;
		
		[self loadView];
	}
	
	return self;
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"groupSkillPoints"]) {
		rootKeys = [NSSet setWithObject:@"document.character.skillInTraining.skillPoints"];
	}
	else if ([dependentKey isEqualToString:@"warningValue"]) {
		rootKeys = [NSSet setWithObject:@"skill.queueSkill"];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}


+ (id)controllerWithNode:(NSDictionary *)aNode {
	return [[[self alloc] initWithNode:aNode] autorelease];
}

- (NSRect)frame {
	return (isGroup) ? [groupView frame] : [[self view] frame];
}

- (NSView *)mainView {
	return (isGroup) ? groupView : [self view];
}

- (void)addSubviewsToView:(NSView *)parent frame:(NSRect)frame highlight:(BOOL)highlight {
	NSView * view;
	
	if (highlight) self.textColor = [NSColor whiteColor];
	else self.textColor = [NSColor blackColor];
	
	view = (isGroup) ? groupView : [self view];
	
	[view setFrame:frame];
	
	if ([view superview] != parent) {
		[parent addSubview:view];
	}
}

- (void)removeSubviews {
	[self.mainView removeFromSuperview];
}


- (NSString *)groupSkillPoints {
	NSUInteger sp;
	NSDictionary * child;
	EveSkill * childSkill;
	NSNumber * gsp;
	NSNumberFormatter * formatter;
	
	formatter = [[[NSNumberFormatter alloc] init] autorelease];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	if (isGroup) {
		sp = 0;
		
		for (child in [node objectForKey:@"children"]) {
			childSkill = [child objectForKey:@"object"];
			sp        += [childSkill.skillPoints unsignedIntegerValue];
		}
	}
	else sp = [skill.skillPoints unsignedIntegerValue];
	
	gsp = [NSNumber numberWithUnsignedInteger:sp];
	
	return [formatter stringFromNumber:gsp];
}

- (NSNumber *)warningValue {
	NSUInteger value;
	
	value = (skill.queueSkill) ? 5 : 0;
	
	return [NSNumber numberWithInteger:value];
}

- (NSString *)description {
	return (isGroup) ? [node objectForKey:@"object"] : [(EveSkill *) [node objectForKey:@"object"] name];
}

- (void)dealloc {
	self.node  = nil;
	self.textColor = nil;
	
	[super dealloc];
}

@end
