//
//	CharacterCreateSheetController.m
//	MacEFT
//
//	Created by ugo pozo on 5/2/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterCreateSheetController.h"
#import "CharacterDocument.h"

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

	switch (code) {
		case EVE_CANCEL:
			[[self window] orderOut:self];
			[self.document close];

			break;

		case EVE_RETRIEVE_CHARS:
			[[self window] orderOut:self];
			[self setWindow:charactersWindow];
			[self.document showSheet:self];

			break;

		case EVE_RETRIEVE_DATA:
			[[self window] orderOut:self];


			break;

		case EVE_BACK:
			[[self window] orderOut:self];
			[self setWindow:mainWindow];
			[self.document showSheet:self];
			break;

		default:
			break;
	
	}
}

- (void)request:(EveAPI *)apiObj finishedWithErrors:(NSDictionary *)errors {
	if (![errors count]) {
		if ([apiObj.lastCalls containsObject:@"CharacterList"]) {
			[apiObj retrievePortraitList];

		}
		else {
			[progress stopAnimation:self];
			self.controlsEnabled = YES;
			
			self.characterList = apiObj.characterList;

			[NSApp endSheet:[self window] returnCode:EVE_RETRIEVE_CHARS];
		}

	}
	else {
		[progress stopAnimation:self];
		self.controlsEnabled = YES;
		self.retrieveFailed = YES;
		NSLog(@"%@", errors);
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
	self.document.character = (EveCharacter *) sender;

	[NSApp endSheet:[self window] returnCode:EVE_RETRIEVE_DATA];
}

@end
