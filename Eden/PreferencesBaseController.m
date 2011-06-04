//
//	PreferencesBaseController.m
//	Eden
//
//	Created by ugo pozo on 6/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "PreferencesBaseController.h"


@implementation PreferencesBaseController

@synthesize preferencesDelegate;

- (id)initWithNibName:(NSString *)nibName andDelegate:(PreferencesDelegate *)prefsDelegate {
	if ((self = [super initWithNibName:nibName bundle:nil])) {
		preferencesDelegate = prefsDelegate;
	}
	
	return self;
}

@end
