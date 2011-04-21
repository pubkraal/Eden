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
	IBOutlet NSWindowController * parent;
	IBOutlet NSArrayController * dataController;
	NSMutableArray * data;
}

@property (assign) NSWindow * win;
@property (assign) NSWindowController * parent;
@property (assign) NSArrayController * dataController;

@property (retain) NSMutableArray * data;

- (void)awakeFromNib;

@end
