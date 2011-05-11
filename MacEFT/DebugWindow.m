//
//  DebugWindow.m
//  MacEFT
//
//  Created by ugo pozo on 5/10/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "DebugWindow.h"


@implementation DebugWindow

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
	NSString * title;
	
	title = [[self title] retain];
    [super dealloc];
	NSLog(@"window gone - %@", title);
	[title release];
}

@end
