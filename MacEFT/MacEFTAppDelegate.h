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
}

@property (assign) IBOutlet NSWindow *window;

@end
