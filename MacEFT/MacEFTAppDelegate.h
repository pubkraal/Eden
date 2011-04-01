//
//  MacEFTAppDelegate.h
//  MacEFT
//
//  Created by John Kraal on 3/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EveDownload.h"

@interface MacEFTAppDelegate : NSObject <NSApplicationDelegate, EveDownloadDelegate> {
@private
    NSWindow *window;
	IBOutlet NSProgressIndicator * p1, * p2, * p3, * p4, * p5;
	NSDictionary * URLList;
	
	NSMutableDictionary * maxValues;
	NSMutableDictionary * currentValues;
	NSMutableDictionary * labels;

	NSDictionary * indicators;
	
}

@property (assign) IBOutlet NSWindow *window;

@property (retain) NSMutableDictionary * maxValues;
@property (retain) NSMutableDictionary * currentValues;
@property (retain) NSMutableDictionary * labels;
@property (retain) NSDictionary * indicators;

- (IBAction)startDownloads:(id)aButton;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

- (void)updateWithData:(id)theData;


- (void)dealloc;
@end
