//
//	CharacterWindowController.h
//	MacEFT
//
//	Created by ugo pozo on 4/30/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// TODO: Autosave, NSCoding

@class EveCharacter;

@interface CharacterDocument : NSDocument {
@private
	// Saved properties
	EveCharacter * character;
	NSString * currentTask;
	NSDictionary * viewSizes;
	NSDictionary * windowOrigin;

	// Instance properties
	NSFileWrapper * currentWrapper;
	NSWindowController * cwController;
}

@property (assign) NSWindowController * cwController;

@property (retain) EveCharacter * character;
@property (retain) NSString * currentTask;
@property (retain) NSDictionary * viewSizes;
@property (retain) NSDictionary * windowOrigin;

- (void)showSheet:(NSWindowController *)controller;
- (NSDictionary *)dictionaryForArchival;
- (void)unarchiveWithDictionary:(NSDictionary *)data;


@end
