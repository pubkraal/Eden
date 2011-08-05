//
//  EdenAppDelegate.h
//  Eden
//
//  Created by John Kraal on 3/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EdenAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
	NSWindowController * dumpNavWindow;
	NSWindowController * preferencesWindow;

	IBOutlet NSProgressIndicator * progress;

	BOOL appStarted;
	BOOL dbLoaded;
	BOOL willOpenFile;
	
	NSString * dbVersion;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) BOOL dbLoaded;
@property (retain) NSString * dbVersion;

- (IBAction)openDumpNav:(id)aButton;

- (NSData *)dataForUserFile:(NSString *)file ofType:(NSString *)type;
- (BOOL)writeData:(NSData *)data toUserFile:(NSString *)file ofType:(NSString *)type;
- (NSString *)applicationSupportFolder;

- (void)loadDatabase:(id)arg;
- (void)postLoadDatabase:(id)arg;
- (void)delayedOpening:(id)arg;
- (void)postDelayedOpening:(id)arg;

- (void)dealloc;
@end

