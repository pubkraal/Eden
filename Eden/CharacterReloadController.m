//
//	CharacterReloadController.m
//	Eden
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

@synthesize maxValue, currentValue, currentRequest, reloadType;

- (id)init {
	if ((self = [super initWithWindowNibName:@"CharacterReload"])) {
		self.maxValue       = nil;
		self.currentValue   = nil;
		self.currentRequest = nil;
		self.reloadType     = kReloadData;
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
	[sheet orderOut:self];
	
	self.maxValue       = nil;
	self.currentValue   = nil;
	self.currentRequest = nil;
	
	[self.document.mainController scheduleSkillTimer];
	self.document.mainController.reloadEnabled = YES;
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
	self.document.mainController.reloadEnabled = NO;

	self.currentRequest = [EveAPI requestWithCharacter:self.document.character];
	self.currentRequest.delegate = self;
	
	if (reloadType == kReloadData) [self.currentRequest retrieveCharacterData];
	else if (reloadType == kReloadPortrait) [self.currentRequest retrievePortrait];
	
	if (self.currentRequest.failedStart) {
		[NSTimer scheduledTimerWithTimeInterval:0.25
										 target:self
									   selector:@selector(failStart:)
									   userInfo:self.currentRequest.failedStart
										repeats:NO];
	}

}

- (void)failStart:(NSTimer *)timer {
	NSError * error;
	
	error = [timer userInfo];
	
	if (![[error domain] isEqualToString:EveAPICachedDomain]) {
		self.document.mainController.errors   = [NSDictionary dictionaryWithObject:error forKey:@"All"];
		self.document.mainController.hasError = YES;
	}
	
	self.currentRequest = nil;
	
	[timer invalidate];
	
	[NSApp endSheet:[self window] returnCode:0];
}

- (void)request:(EveAPI *)api finishedWithErrors:(NSDictionary *)errors {
	if ([errors count]) {
		self.document.mainController.errors   = errors;
		self.document.mainController.hasError = YES;
	}
	else {
		self.document.mainController.hasError = NO;
	}
	
	[NSApp endSheet:[self window] returnCode:0];
	[self.document.character updateSkillsArray];
	[self.document updateChangeCount:NSChangeDone];
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
