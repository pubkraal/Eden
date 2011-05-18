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
	NSWindowController * mainController, * crController;
}

@property (readonly) NSWindowController * mainController;
@property (readonly) NSWindowController * reloadController;

@property (retain) EveCharacter * character;
@property (retain) NSString * currentTask;
@property (retain) NSDictionary * viewSizes;
@property (retain) NSDictionary * windowOrigin;

- (void)showSheet:(NSWindowController *)controller;
- (void)removeReloadController;

- (NSDictionary *)dictionaryForArchival;
- (void)unarchiveWithDictionary:(NSDictionary *)data;

// Actions that can be called from Menus



@end
