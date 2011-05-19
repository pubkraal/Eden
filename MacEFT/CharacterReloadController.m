//
//	CharacterReloadController.m
//	MacEFT
//
//	Created by ugo pozo on 5/11/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterReloadController.h"
#import "CharacterWindowController.h"
#import "EveAPI.h"
#import "CharacterDocument.h"
#import "EveCharacter.h"

@implementation CharacterReloadController

@synthesize maxValue, currentValue, currentRequest;

- (id)init {
	if ((self = [super initWithWindowNibName:@"CharacterReload"])) {
		self.maxValue       = nil;
		self.currentValue   = nil;
		self.currentRequest = nil;
	}
	
	return self;
}

- (void)setDocument:(CharacterDocument *)document {
	[super setDocument:document];
}

- (CharacterDocument *)document {
	return [super document];
}

- (void)windowDidLoad {
	[progressBar setUsesThreadedAnimation:YES];
}

- (IBAction)stopReload:(id)sender {
	[self.currentRequest cancelRequests];
	[NSApp endSheet:[self window] returnCode:0];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)code context:(void *)context {
	[[self window] orderOut:self];
	
	self.maxValue       = nil;
	self.currentValue   = nil;
	self.currentRequest = nil;
	
	[(CharacterWindowController *) self.document.mainController scheduleSkillTimer];
	[(CharacterWindowController *) self.document.mainController setReloadEnabled:YES];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	[(CharacterWindowController *) self.document.mainController setReloadEnabled:NO];

	self.currentRequest = [EveAPI requestWithCharacter:self.document.character];
	self.currentRequest.delegate = self;
	
	[self.currentRequest retrieveCharacterData];

}

- (void)request:(EveAPI *)api finishedWithErrors:(NSArray *)errors {
	[NSApp endSheet:[self window] returnCode:0];
	[self.document.character updateSkillsArray];
}

- (void)request:(EveAPI *)api changedTotalDownloadSize:(NSNumber *)bytes {
	[self performSelectorInBackground:@selector(updateData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:bytes, @"value", @"maxValue", @"keyPath", nil]];
}

- (void)request:(EveAPI *)api changedDownloadedBytes:(NSNumber *)bytes {
	[self performSelectorInBackground:@selector(updateData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:bytes, @"value", @"currentValue", @"keyPath", nil]];
}

- (void)updateData:(NSDictionary *)data {
	NSAutoreleasePool * pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	[self setValue:[data objectForKey:@"value"] forKeyPath:[data objectForKey:@"keyPath"]];
	
	[pool drain];
}

- (void)dealloc {
	self.maxValue       = nil;
	self.currentValue   = nil;
	self.currentRequest = nil;
	
	[super dealloc];
}

@end
