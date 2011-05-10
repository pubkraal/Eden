//
//	MacEFTAppDelegate.m
//	MacEFT
//
//	Created by John Kraal on 3/24/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "MacEFTAppDelegate.h"
#import "EveDatabase.h"
#import "EveSkill.h"


@implementation MacEFTAppDelegate

@synthesize window, dbLoaded;


- (id)init {
	if ((self = [super init])) {
		appStarted = NO;
		dbLoaded   = NO;
	}
	
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	preferencesWindow = nil;
	dumpNavWindow     = nil;

	[progress startAnimation:self];
	[self performSelectorInBackground:@selector(loadDatabase:) withObject:nil];
}

- (void)loadDatabase:(id)arg {
	NSError * error;
	SQLBridge * bridge;
	NSAutoreleasePool * pool;

	pool = [[NSAutoreleasePool alloc] init];

	bridge = [EveDatabase sharedBridge];
	error  = (bridge) ? nil : [EveDatabase initError];
	
	if (!error) [EveSkill cacheRawSkills];
	
	[pool drain];
	
	[self performSelectorOnMainThread:@selector(postLoadDatabase:) withObject:error waitUntilDone:NO];
}

- (void)postLoadDatabase:(id)arg {
	NSError * error;
	NSAlert * alert;

	error = (NSError *) arg;
	
	[progress stopAnimation:self];

	if (!error) {
		self.dbLoaded = YES;
		[window orderOut:self];

		if ([self applicationShouldOpenUntitledFile:[NSApplication sharedApplication]]) {
			[[NSDocumentController sharedDocumentController] newDocument:self];
		}

		appStarted = YES;
	}
	else {
		alert = [NSAlert alertWithError:error];

		[alert runModal];

		[[NSApplication sharedApplication] terminate:self];
	}
}

- (BOOL)validateUserInterfaceItem:(id)item {
	return dbLoaded;
}

- (IBAction)openDumpNav:(id)aButton {
	if (!dumpNavWindow) {
		dumpNavWindow = [[NSWindowController alloc] initWithWindowNibName:@"DumpNavigator"];
		
		[dumpNavWindow loadWindow];
	}
	[[dumpNavWindow window] makeKeyAndOrderFront:dumpNavWindow];
	
}

- (IBAction)showPreferencesWindow:(id)sender {
	if (!preferencesWindow) {
		preferencesWindow = [[NSWindowController alloc] initWithWindowNibName:@"Preferences"];

		[preferencesWindow loadWindow];
	}

	[[preferencesWindow window] makeKeyAndOrderFront:preferencesWindow];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	NSDocumentController * controller;
	NSArray * documents;
	NSError * error;
	BOOL untitled;

	untitled = YES;
	error    = nil;

	if (!appStarted) {
		controller = [NSDocumentController sharedDocumentController];
		documents  = [controller recentDocumentURLs];
		
		if ([documents count] > 0) {
			[controller openDocumentWithContentsOfURL:[documents objectAtIndex:0]
											  display:YES
												error:&error];
			
			if (!error) untitled = NO;
		}
	}
	
	return untitled;
}




- (void)dealloc {
	[dumpNavWindow release];
	
	[super dealloc];
}

@end

