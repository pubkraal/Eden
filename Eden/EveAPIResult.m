//
//  EveAPIResult.m
//  Eden
//
//  Created by John Kraal on 3/28/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveAPIResult.h"


@implementation EveAPIResult

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)parseData:(NSString *)XMLdata {
    self.data = XMLdata;

    NSLog(@"%@", data);
    
    // Herpherp read XML, turn into Dictionary, herpherp
}

@synthesize data;

@end
