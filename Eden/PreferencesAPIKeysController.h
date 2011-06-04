//
//	PreferencesAPIKeysController.h
//	Eden
//
//	Created by ugo pozo on 6/3/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesBaseController.h"

@class PreferencesDelegate;

@interface PreferencesAPIKeysController : PreferencesBaseController {
@private
	NSArray * selectedPairs;
}

@property (retain) NSArray * selectedPairs;

- (id)initWithDelegate:(PreferencesDelegate *)prefsDelegate;

@end
