//
//  PreferencesDelegate.m
//  MacEFT
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "PreferencesDelegate.h"
#import <QuartzCore/CoreAnimation.h>

@implementation PreferencesDelegate

- (id)init {
    if ((self = [super init])) {
		currentView = nil;
		nextView    = nil;
    }
    
    return self;
}

- (void)awakeFromNib {
	CAAnimation * autoresize;

	autoresize = [CABasicAnimation animation];
	[autoresize setDelegate:self];
	[mainWindow setAnimations:[NSDictionary dictionaryWithObject:autoresize forKey:@"frame"]];

	[toolbar setSelectedItemIdentifier:[firstButton itemIdentifier]];
	[self switchView:firstPane animate:NO];

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if (nextView) {
		[loaderView addSubview:nextView];
		
		currentView = nextView;
		nextView    = nil;
	}

}

- (IBAction)showPref1:(id)sender {
	[self switchView:pref1 animate:YES];
}

- (IBAction)showPref2:(id)sender {
	[self switchView:pref2 animate:YES];

}

- (IBAction)showPref3:(id)sender {
	[self switchView:pref3 animate:YES];

}

- (void)switchView:(NSView *)newView animate:(BOOL)animate {
	NSRect windowFrame, loaderFrame, newFrame;
	
	if (!nextView) {
		if (currentView) [currentView removeFromSuperview];

		newFrame = [newView frame];
		
		newFrame.origin.x = 0;
		newFrame.origin.y = 0;

		[newView setFrame:newFrame];

		windowFrame = [mainWindow frame];
		loaderFrame = [loaderView frame];

		windowFrame.size.width  += newFrame.size.width  - loaderFrame.size.width;
		windowFrame.size.height += newFrame.size.height - loaderFrame.size.height;
		windowFrame.origin.y    -= newFrame.size.height - loaderFrame.size.height;

		// Keep centered horizontally...
		windowFrame.origin.x    -= (newFrame.size.width  - loaderFrame.size.width) / 2;

		if (animate) {
			nextView = newView;
		
			[[mainWindow animator] setFrame:windowFrame display:YES];
		}
		else {
			[mainWindow setFrame:windowFrame display:NO];
			[loaderView addSubview:newView];

			currentView = newView;
		}

	}
}


- (void)dealloc {
    [super dealloc];
}

@end
