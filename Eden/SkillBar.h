//
//	SkillBar.h
//	Eden
//
//	Created by ugo pozo on 6/18/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EveCharacter;

@interface SkillBar : NSView {
@private
	EveCharacter * character;
}

@property (assign) EveCharacter * character;
@property (readonly) NSArray * queue;

@end
