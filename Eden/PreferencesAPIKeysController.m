//
//	PreferencesAPIKeysController.m
//	Eden
//
//	Created by ugo pozo on 6/3/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "PreferencesAPIKeysController.h"
#import "PreferencesDelegate.h"

@implementation PreferencesAPIKeysController

@synthesize selectedPairs;

- (id)initWithDelegate:(PreferencesDelegate *)prefsDelegate {
	if ((self = [super initWithNibName:@"PreferencesAPIKeys" andDelegate:prefsDelegate])) {
		[self loadView];
		
		self.selectedPairs = nil;
	}
	
	return self;
}

- (void)dealloc {
	self.selectedPairs = nil;

	[super dealloc];
}

@end
