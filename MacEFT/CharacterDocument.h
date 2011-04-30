//
//	CharacterWindowController.h
//	MacEFT
//
//	Created by ugo pozo on 4/30/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// TODO: Autosave, NSCoding

@class CharacterWindowController;

@interface CharacterDocument : NSDocument {
@private
	// Saved properties
	BOOL hasFullAPI;
	NSString * accountID;
	NSString * currentTask;
	NSDictionary * viewSizes;

	// Instance properties
	NSFileWrapper * currentWrapper;
	CharacterWindowController * cwController;
}

@property (assign) BOOL hasFullAPI;

@property (retain) NSString * accountID;
@property (retain) NSString * currentTask;
@property (retain) NSDictionary * viewSizes;



@end
