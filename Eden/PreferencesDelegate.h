//
//  PreferencesDelegate.h
//  Eden
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: separate panels into different xibs

@interface PreferencesDelegate : NSObject {
@private
	IBOutlet NSWindow * mainWindow;
    IBOutlet NSToolbar * toolbar;
	IBOutlet NSView * loaderView;
	
	NSDictionary * panes;

	NSView * currentView;
	NSView * nextView;
}

@property (readonly) NSWindow * window;

- (IBAction)selectPane:(id)sender;

- (void)switchView:(NSView *)newView animate:(BOOL)animate;

- (void)loadPanes;

@end
