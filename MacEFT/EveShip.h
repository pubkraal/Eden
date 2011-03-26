//
//  EveShip.h
//  MacEFT
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EveObject.h"

typedef unsigned int uint;

@interface EveShip : EveObject {
    uint highSlots;
    uint medSlots;
    uint lowSlots;
    
    uint missileHardpoints;
    uint turretHardpoints;

    float basePowergrid;
    float baseCPU;
}

@property(readwrite) uint highSlots, medSlots, lowSlots, missileHardPoints, turretHardpoints;
@property(readwrite) float basePowergrid, baseCPU;

@end
