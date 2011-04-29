//
//  PreferencesDelegate.h
//  MacEFT
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PreferencesDelegate : NSObject {
@private
	IBOutlet NSWindow * mainWindow;
    IBOutlet NSToolbar * toolbar;
	IBOutlet NSToolbarItem * firstButton;
	IBOutlet NSView * loaderView;
	IBOutlet NSView * firstPane;

	IBOutlet NSView * pref1, * pref2, * pref3;

	NSView * currentView;
	NSView * nextView;
}


- (IBAction)showPref1:(id)sender;
- (IBAction)showPref2:(id)sender;
- (IBAction)showPref3:(id)sender;

- (void)switchView:(NSView *)newView animate:(BOOL)animate;
- (void)selectToolbarItem:(NSToolbarItem *)tbItem;

@end
