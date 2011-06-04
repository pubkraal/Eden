//
//	PreferencesBaseController.h
//	Eden
//
//	Created by ugo pozo on 6/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PreferencesDelegate;

@interface PreferencesBaseController : NSViewController {
@private
	PreferencesDelegate * preferencesDelegate;
}

@property (assign) PreferencesDelegate * preferencesDelegate;

- (id)initWithNibName:(NSString *)nibName andDelegate:(PreferencesDelegate *)prefsDelegate;

@end
