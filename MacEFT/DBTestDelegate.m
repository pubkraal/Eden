//
//  DBTestDelegate.m
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "DBTestDelegate.h"


@implementation DBTestDelegate

@synthesize win, parent;

- (id)init {
	
    if ((self = [super init])) {
		NSLog(@"been alloc'ed!");
    }
    
    return self;
}

- (void)dealloc {
	NSLog(@"I'm dying here!");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)awakeFromNib {
	NSNotificationCenter * nc;

	nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleCloseWindow:) name:NSWindowWillCloseNotification object:[self win]];
	
	NSLog(@"Hi! I'm awake!");
	
	[[self win] makeKeyAndOrderFront:nil];
}

- (void)handleCloseWindow:(NSNotification *)notification {
	NSLog(@"Notification: %@", notification);
	[self release];
}

@end

@implementation VerboseWindow

- (void)dealloc {
	NSLog(@"This window is going bye bye!");
	
	[super dealloc];
}

- (void)release {
	NSLog(@"They see me showing, they hating, releasing, tryin to catch me dealloc'ing...");
	
	[super release];
}

@end
