//
//	CharacterCreateSheetController.m
//	Eden
//
//	Created by ugo pozo on 5/2/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterCreateSheetController.h"
#import "CharacterWindowController.h"
#import "CharacterDocument.h"
#import "EveCharacter.h"

@implementation CharacterCreateSheetController

@synthesize controlsEnabled, retrieveFailed, inputAPIKey, inputAccountID, characterList, currentRequest, lastError;

- (id)init {
	if ((self = [super initWithWindowNibName:@"CharacterCreateSheet"])) {
		controlsEnabled     = YES;
		retrieveFailed      = NO;
		self.inputAPIKey    = nil;
		self.inputAccountID = nil;
		self.characterList  = nil;
		self.currentRequest = nil;
		self.lastError      = nil;
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
	self.currentRequest = nil;
	self.lastError      = nil;
	
	[mainWindow autorelease];
	[charactersWindow autorelease];

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
			self.currentRequest = nil;
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
		
		case EVE_RETRIEVE_DATA:
			[self.document updateChangeCount:NSChangeDone];
			[(CharacterWindowController *) self.document.mainController scheduleSkillTimer];
			self.currentRequest = nil;
			break;

		default:
			break;
	
	}
}

- (void)request:(EveAPI *)apiObj finishedWithErrors:(NSDictionary *)errors {
	EveCharacter * theChar;

	if ([apiObj.lastCalls containsObject:@"CharacterList"]) {
		if (![errors count]) {
			for (theChar in apiObj.characterList) {
				theChar.fullAPI = apiObj.character.fullAPI;
			}

			[apiObj retrievePortraitList];
		}
		else {
			[progress stopAnimation:self];
			self.controlsEnabled = YES;
			self.retrieveFailed  = YES;
			self.lastError       = [(NSError *) [errors objectForKey:@"CharacterList"] localizedDescription];

			NSLog(@"%@", errors);
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
			
			self.document.character = apiObj.character;
			self.characterList      = nil;
			self.controlsEnabled    = YES;
			
			[self.document.character updateSkillsArray];
			
			[NSApp endSheet:[self window] returnCode:EVE_RETRIEVE_DATA];
		}
		else NSLog(@"%@", errors);
	}

	
}

- (IBAction)close:(id)sender {
	[NSApp endSheet:[self window] returnCode:EVE_CANCEL];
}


- (IBAction)send:(id)sender {
	if (inputAPIKey &&
		inputAccountID &&
		![inputAPIKey isEqualToString:@""] &&
		![inputAccountID isEqualToString:@""]) {

		self.inputAPIKey    = inputAPIKey;
		self.inputAccountID = inputAccountID;

		self.retrieveFailed  = NO;
		self.controlsEnabled = NO;
		[progress startAnimation:self];

		self.currentRequest = [EveAPI requestWithAccountID:inputAccountID andAPIKey:inputAPIKey];
		self.currentRequest.delegate = self;

		[self.currentRequest retrieveAccountData];
		
		if (self.currentRequest.failedStart) {
			self.retrieveFailed  = YES;
			self.lastError       = [self.currentRequest.failedStart localizedDescription];
			self.controlsEnabled = YES;
			[progress stopAnimation:self];
		}
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
	self.controlsEnabled = NO;
	[progressCharWindow startAnimation:self];

	self.currentRequest = [EveAPI requestWithCharacter:(EveCharacter *) sender];
	self.currentRequest.delegate = self;

	[self.currentRequest retrieveCharacterData];
}

@end
