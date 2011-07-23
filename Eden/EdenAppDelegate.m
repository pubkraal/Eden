//
//	EdenAppDelegate.m
//	Eden
//
//	Created by John Kraal on 3/24/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "EdenAppDelegate.h"
#import "EveDatabase.h"
#import "EveSkill.h"
#import "EdenDocumentController.h"


@implementation EdenAppDelegate

@synthesize window, dbLoaded;

+ (void)initialize {
	NSDictionary * defaults;
	
	defaults = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool:NO], @"reloadOnFileOpened",
				[NSNumber numberWithBool:NO], @"reloadWhenCacheExpires",
				@"lastDocument", @"openOnStart",
				[NSString string], @"customDocument",
				[NSArray array], @"blockedAPIKeys",
				nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


- (id)init {
	if ((self = [super init])) {
		appStarted   = NO;
		dbLoaded     = NO;
		willOpenFile = NO;
	}
	
	return self;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
	EdenDocumentController * docControl;
	
	// The shared document controller for the application is the first that is
	// created. According to the docs, it's guaranteed that a controller
	// created in applicationWillFinishLaunching: will assume this role, so
	// this is the proper way to ensure that our subclassed document
	// controller is used instead of the default one.
	
	docControl = [[[EdenDocumentController alloc] init] autorelease];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	preferencesWindow = nil;
	dumpNavWindow     = nil;

	[window makeKeyAndOrderFront:self];
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
	NSUserDefaults * prefs;
	NSDocumentController * controller;
	NSArray * documents;
	NSError * error;
	NSURL * file;
	NSString * openOnStart;
	BOOL untitled;

	prefs       = [NSUserDefaults standardUserDefaults];
	openOnStart = [prefs stringForKey:@"openOnStart"];
	untitled    = [openOnStart isEqualToString:@"newDocument"];
	error       = nil;

	if (!willOpenFile && !appStarted && !untitled) {
		controller = [NSDocumentController sharedDocumentController];

		if ([openOnStart isEqualToString:@"lastDocument"]) {
			documents = [controller recentDocumentURLs];
			file      = ([documents count] > 0) ? [documents objectAtIndex:0] : nil;
		}
		else file = [NSURL URLWithString:[prefs stringForKey:@"customDocument"]];
		
		if (file) {
			[controller openDocumentWithContentsOfURL:file display:YES error:&error];
			
			if (error) untitled = YES;
		}
		else untitled = YES;
	}
	
	return untitled;
}

- (BOOL)application:(NSApplication *)app openFile:(NSString *)filename {
	willOpenFile = YES;
	[self performSelectorInBackground:@selector(delayedOpening:) withObject:filename];
	
	return YES;
}

- (void)delayedOpening:(id)arg {
	NSAutoreleasePool * pool;
	NSURL * fileURL;
	
	while (!appStarted) ;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	fileURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"file:%@", [(NSString *) arg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	
	[self performSelectorOnMainThread:@selector(postDelayedOpening:) withObject:fileURL waitUntilDone:NO];
	
	[pool drain];
}

- (void)postDelayedOpening:(id)arg {
	NSURL * fileURL;
	NSError * error;
	NSAlert * alert;
	
	fileURL = (NSURL *) arg;
	error   = nil;
	
	[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:fileURL display:YES error:&error];

	[fileURL autorelease];
	
	if (error) {
		alert = [NSAlert alertWithError:error];

		[alert runModal];
	}
}


- (void)dealloc {
	[dumpNavWindow release];
	
	[super dealloc];
}

@end

