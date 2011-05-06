//
//	CharacterCreateSheetController.m
//	MacEFT
//
//	Created by ugo pozo on 5/2/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterCreateSheetController.h"
#import "CharacterDocument.h"
#import "EveCharacter.h"

@implementation CharacterCreateSheetController

@synthesize controlsEnabled, retrieveFailed, inputAPIKey, inputAccountID, characterList;

- (id)init {
	if ((self = [super initWithWindowNibName:@"CharacterCreateSheet"])) {
		controlsEnabled     = YES;
		retrieveFailed      = NO;
		self.inputAPIKey    = nil;
		self.inputAccountID = nil;
		self.characterList  = nil;
	}
	
	return self;
}

- (CharacterDocument *)document {
	return [super document];
}

- (void)setDocument:(CharacterDocument *)document {
	[super setDocument:document];
}

- (void)dealloc {
	self.inputAPIKey    = nil;
	self.inputAccountID = nil;
	self.characterList  = nil;

	[mainWindow release];
	[charactersWindow release];

	[super dealloc];
}

- (void)windowDidLoad {
	[super windowDidLoad];

	[mainWindow retain];
	[charactersWindow retain];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)code context:(void *)context {
	[[self window] orderOut:self];

	switch (code) {
		case EVE_CANCEL:
			[self.document close];

			break;

		case EVE_RETRIEVE_CHARS:
			[self setWindow:charactersWindow];
			[self.document showSheet:self];

			break;

		case EVE_BACK:
			[self setWindow:mainWindow];
			[self.document showSheet:self];
			break;

		default:
			break;
	
	}
}

- (void)request:(EveAPI *)apiObj finishedWithErrors:(NSDictionary *)errors {
	NSError * error;
	EveCharacter * theChar;

	if ([apiObj.lastCalls containsObject:@"CharacterList"]) {
		if ((error = [errors objectForKey:@"CharacterList"])) {
			[progress stopAnimation:self];
			self.controlsEnabled = YES;
			self.retrieveFailed  = YES;

			NSLog(@"%@", error);
		}
		else {
			for (theChar in apiObj.characterList) {
				theChar.fullAPI = apiObj.character.fullAPI;
			}

			NSLog(@"%@", apiObj.characterList);

			[apiObj retrievePortraitList];
		}
	}
	else if ([apiObj.lastCalls containsObject:@"PortraitList"]) {
		if (![errors count]) {
			[progress stopAnimation:self];

			self.controlsEnabled = YES;
			self.characterList   = apiObj.characterList;

			[NSApp endSheet:[self window] returnCode:EVE_RETRIEVE_CHARS];
		}
		else NSLog(@"%@", errors);
	}
	else if ([apiObj.lastCalls containsObject:@"CharacterSheet"]) {
		if (![errors count]) {
			[progressCharWindow stopAnimation:self];
			
			self.controlsEnabled = YES;
			
			self.document.character = apiObj.character;
			
			[NSApp endSheet:[self window] returnCode:EVE_RETRIEVE_DATA];
		}
		else NSLog(@"%@", errors);
	}

	
}

- (IBAction)close:(id)sender {
	[NSApp endSheet:[self window] returnCode:EVE_CANCEL];
}


- (IBAction)send:(id)sender {
	EveAPI * api;

	if (inputAPIKey &&
		inputAccountID &&
		![inputAPIKey isEqualToString:@""] &&
		![inputAccountID isEqualToString:@""]) {

		self.inputAPIKey    = inputAPIKey;
		self.inputAccountID = inputAccountID;

		self.retrieveFailed  = NO;
		self.controlsEnabled = NO;
		[progress startAnimation:self];

		api = [EveAPI requestWithAccountID:inputAccountID andAPIKey:inputAPIKey];
		api.delegate = self;

		[api retrieveAccountData]; 
	}
	else NSBeep();
}

- (IBAction)eveWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[EveAPI URLForKey:@"APIKey"]]];
}

- (IBAction)back:(id)sender {
	[NSApp endSheet:[self window] returnCode:EVE_BACK];
}

- (IBAction)select:(id)sender {
	EveAPI * api;

	self.characterList      = nil;

	self.controlsEnabled = NO;
	[progressCharWindow startAnimation:self];

	api = [EveAPI requestWithCharacter:(EveCharacter *) sender];
	api.delegate = self;

	[api retrieveLimitedData];
}

@end
