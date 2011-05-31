//
//  SkillCell.h
//  Eden
//
//  Created by ugo pozo on 5/23/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SkillCellController;

@interface SkillCell : NSCell {
@private
	SkillCellController * controller;
}

@property (assign) SkillCellController * controller;

+ (id)cell;

@end
