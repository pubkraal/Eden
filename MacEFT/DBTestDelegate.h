//
//  DBTestDelegate.h
//  MacEFT
//
//  Created by ugo pozo on 4/20/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacEFTAppDelegate.h"

@interface DBTestDelegate : NSObject {
@private
	IBOutlet NSWindow * win;
	IBOutlet MacEFTAppDelegate * parent;
}

@property (retain) NSWindow * win;
@property (retain) MacEFTAppDelegate * parent;

- (void)awakeFromNib;
- (void)handleCloseWindow:(NSNotification *)notification;

@end

@interface VerboseWindow : NSWindow {
	
}

- (void)dealloc;
- (void)release;

@end