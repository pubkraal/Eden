//
//  PreferencesDelegate.m
//  Eden
//
//  Created by ugo pozo on 4/29/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <QuartzCore/CoreAnimation.h>
#import "PreferencesDelegate.h"
#import "PreferencesControllers.h"

@implementation PreferencesDelegate

@synthesize window = mainWindow;

- (id)init {
    if ((self = [super init])) {
		currentView = nil;
		nextView    = nil;
		panes       = nil;
    }
    
    return self;
}

- (void)awakeFromNib {
	NSToolbarItem * firstItem;
	CAAnimation * autoresize;

	autoresize = [CABasicAnimation animation];
	[autoresize setDelegate:self];
	[mainWindow setAnimations:[NSDictionary dictionaryWithObject:autoresize forKey:@"frame"]];
	
	[self loadPanes];
	
	firstItem = [[toolbar items] objectAtIndex:1]; // The first item is actually the spacer.
	
	[self selectPane:firstItem];

}

- (void)loadPanes {
	NSString * paneName;
	NSMutableDictionary * loadedPanes;
	NSViewController * pane;
	NSUInteger i;
	
	loadedPanes = [NSMutableDictionary dictionary];
	
	for (i = 0; preferencesNames[i]; i++) {
		paneName = [NSString stringWithUTF8String:preferencesNames[i]];
		pane     = [[NSClassFromString(paneName) alloc] initWithDelegate:self];
		
		[loadedPanes setObject:pane forKey:paneName];
		
		[pane release];
	}
	
	panes = [[NSDictionary alloc] initWithDictionary:loadedPanes];
}

- (IBAction)selectPane:(id)sender {
	NSString * identifier;
	NSView * pane;
	
	identifier = [sender itemIdentifier];
	pane       = [[panes objectForKey:identifier] view];
	
	[mainWindow setTitle:[NSString stringWithFormat:@"Preferences - %@", [sender label]]];
	
	[toolbar setSelectedItemIdentifier:identifier];
	[self switchView:pane animate:!!currentView];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if (nextView && finished) {
		[loaderView addSubview:nextView];
		
		currentView = nextView;
		nextView    = nil;
	}

}


- (void)switchView:(NSView *)newView animate:(BOOL)animate {
	NSRect windowFrame, loaderFrame, newFrame;
	
	if (!nextView && newView) {
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
	[mainWindow setAnimations:[NSDictionary dictionary]];
	[panes release];
	
    [super dealloc];
}

@end
