//
//  EveEquations.m
//  MacEFT
//
//  Created by ugo pozo on 5/17/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveEquations.h"
#import <math.h>

NSUInteger EveSkillPointsForLevel(NSUInteger level, NSUInteger rank) {
	double needed;
	
	needed = pow(2.0, (2.5 * (double) level) - 2.5) * 250.0 * (double) rank;

	return (NSUInteger) floor(needed + 0.5);
}

// In SP/hour

NSUInteger EveTrainingSpeed(NSUInteger primaryValue, NSUInteger secondaryValue) {
	double speed;
	
	speed = 60 * EveTrainingSpeedInMinutes(primaryValue, secondaryValue);
	
	return (NSUInteger) floor(speed + 0.5);
}

double EveTrainingSpeedInMinutes(NSUInteger primaryValue, NSUInteger secondaryValue) {
	return ((double) primaryValue + (0.5 * (double) secondaryValue));
}