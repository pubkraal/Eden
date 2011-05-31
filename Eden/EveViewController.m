//
//  EveViewController.m
//  Eden
//
//  Created by ugo pozo on 4/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveViewController.h"
#import "CharacterDocument.h"


@implementation EveViewController

@synthesize document;

- (id)init {
	NSLog(@"Subclass me.");

	return nil;
}

+ (id)viewController {
	return [[[self alloc] init] autorelease];
}

- (void)documentWillClose {
	self.document = nil;
}

- (void)dealloc {
    [super dealloc];
}


@end
