//
//	PreferencesGeneralController.h
//	Eden
//
//	Created by ugo pozo on 6/3/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesBaseController.h"

@class PreferencesDelegate;

@interface PreferencesGeneralController : PreferencesBaseController {
@private
	NSNumber * selectedTag;
}

@property (retain) NSNumber * selectedTag;
@property (readonly) BOOL customDocumentSelected;

@property (retain) NSURL * customDocument;
@property (readonly) NSImage * customDocumentIcon;
@property (readonly) NSString * customDocumentTitle;

- (id)initWithDelegate:(PreferencesDelegate *)prefsDelegate;

- (IBAction)reloadOnOpenChanged:(id)sender;
- (IBAction)chooseCustomDocument:(id)sender;

@end
