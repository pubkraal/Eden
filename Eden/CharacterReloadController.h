//
//  CharacterReloadController.h
//  Eden
//
//  Created by ugo pozo on 5/11/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EveAPI.h"

@class CharacterDocument;
@class EveDownload;

typedef enum reload_type_e ReloadType;

enum reload_type_e {
	kReloadData = 0,
	kReloadPortrait = 1
};

@interface CharacterReloadController : NSWindowController <NSWindowDelegate, APIDelegate> {
@private
	IBOutlet NSProgressIndicator * progressBar;
	NSNumber * maxValue, * currentValue;
	EveAPI * currentRequest;
	ReloadType reloadType;
}

@property (assign) CharacterDocument * document;
@property (retain) NSNumber * maxValue, * currentValue;
@property (retain) EveAPI * currentRequest;
@property (assign) ReloadType reloadType;

- (IBAction)stopReload:(id)sender;
- (void)updateData:(NSDictionary *)data;
- (void)failStart:(NSTimer *)timer;

@end
