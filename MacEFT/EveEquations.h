//
//  EveEquations.h
//  MacEFT
//
//  Created by ugo pozo on 5/17/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSUInteger EveSkillPointsForLevel(NSUInteger level, NSUInteger rank);
NSUInteger EveTrainingSpeed(NSUInteger primaryValue, NSUInteger secondaryValue);
double EveTrainingSpeedInMinutes(NSUInteger primaryValue, NSUInteger secondaryValue);