//
//  Character.m
//  MacEFT
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "Character.h"


@implementation Character

- (void)importFromAPI:(int)characterId {
    // Load the character from API.
    return;
}

- (void)updateFromAPI {
    // This basically does an import, but uses known information.
    return;
}

- (float)getTotalCPUBonus {
    return 0.0;
}

- (float)getTotalPowergridBonus {
    return 0.0;
}

- (void)loadSkills {
    // Not sure how to solve this
    return;
}

@synthesize name;

@end
