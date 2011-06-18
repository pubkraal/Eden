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

typedef enum skill_color_e {
	kColorGreen  = 1,
	kColorYellow = 2,
	kColorRed    = 3
} SkillColor;

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
@property (readonly) NSNumber * criticalValue;

@property (readonly) NSRect frame;
@property (readonly) NSView * mainView;

@property (readonly) NSString * groupSkillPoints;
@property (readonly) NSNumber * displayLevel;
@property (readonly) NSString * displayStringLevel;


- (id)initWithNode:(NSDictionary *)aNode;
+ (id)controllerWithNode:(NSDictionary *)aNode;

- (SkillColor)color;

- (void)addSubviewsToView:(NSView *)parent frame:(NSRect)frame highlight:(BOOL)highlight;
- (void)removeSubviews;

@end
