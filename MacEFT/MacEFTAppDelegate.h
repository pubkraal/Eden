//
//  MacEFTAppDelegate.h
//  MacEFT
//
//  Created by John Kraal on 3/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MacEFTAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
	NSWindowController * dumpNavWindow;
	NSWindowController * preferencesWindow;

	IBOutlet NSProgressIndicator * progress;

	BOOL appStarted;
	BOOL dbLoaded;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) BOOL dbLoaded;

- (IBAction)openDumpNav:(id)aButton;

- (void)loadDatabase:(id)arg;
- (void)postLoadDatabase:(id)arg;

- (void)dealloc;
@end

