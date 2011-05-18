//
//	CharacterCreateSheetController.h
//	MacEFT
//
//	Created by ugo pozo on 5/2/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EveAPI.h"

@class CharacterDocument;

#define EVE_CANCEL 1 << 0
#define EVE_RETRIEVE_CHARS 1 << 1
#define EVE_RETRIEVE_DATA 1 << 2
#define EVE_BACK 1 << 3

@interface CharacterCreateSheetController : NSWindowController <APIDelegate> {
@private
	BOOL controlsEnabled;
	BOOL retrieveFailed;
	IBOutlet NSWindow * charactersWindow;
	IBOutlet NSWindow * mainWindow;
	IBOutlet NSProgressIndicator * progress;
	IBOutlet NSProgressIndicator * progressCharWindow;

	NSArray * characterList;


	NSString * inputAccountID;
	NSString * inputAPIKey;
	
	EveAPI * currentRequest;
	
}

@property (assign) BOOL controlsEnabled, retrieveFailed;
@property (assign) CharacterDocument * document;

@property (retain) NSString * inputAPIKey, * inputAccountID;

@property (retain) NSArray * characterList;

@property (retain) EveAPI * currentRequest;

- (IBAction)close:(id)sender;
- (IBAction)send:(id)sender;
- (IBAction)eveWebsite:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)select:(id)sender;

@end
