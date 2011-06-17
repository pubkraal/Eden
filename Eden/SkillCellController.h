//
//	SkillCellController.h
//	Eden
//
//	Created by ugo pozo on 5/23/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EveViewController.h"

@class EveSkill;

@interface SkillCellController : EveViewController {
@private
	IBOutlet NSView * groupView;

	EveSkill * skill;
	BOOL isGroup;

	NSDictionary * node;
	NSColor * textColor;
}

@property (assign) EveSkill * skill;
@property (assign) BOOL isGroup;

@property (retain) NSDictionary * node;
@property (retain) NSColor * textColor;
@property (readonly) NSNumber * warningValue;

@property (readonly) NSRect frame;
@property (readonly) NSView * mainView;

@property (readonly) NSString * groupSkillPoints;

- (id)initWithNode:(NSDictionary *)aNode;
+ (id)controllerWithNode:(NSDictionary *)aNode;

- (void)addSubviewsToView:(NSView *)parent frame:(NSRect)frame highlight:(BOOL)highlight;
- (void)removeSubviews;

@end
