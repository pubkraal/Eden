//
//  MacEFTAppDelegate.h
//  MacEFT
//
//  Created by John Kraal on 3/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EveDownload.h"

@interface MacEFTAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
	NSString * label1, * label2, * label3, * label4, * label5;
	IBOutlet NSProgressIndicator * p1, * p2, * p3, * p4, * p5;
	NSDictionary * URLList, * cbList;
	NSNumber * max1, * max2, * max3, * max4, * max5;
	NSNumber * val1, * val2, * val3, * val4, * val5;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSString * label1, * label2, * label3, * label4, * label5;
@property (retain) NSNumber * max1, * max2, * max3, * max4, * max5;
@property (retain) NSNumber * val1, * val2, * val3, * val4, * val5;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

- (IBAction)startDownloads:(id)aButton;

- (void)song1Finished:(NSData *)data;
- (void)song2Finished:(NSData *)data;
- (void)song3Finished:(NSData *)data;
- (void)song4Finished:(NSData *)data;

- (void)allFinished:(NSData *)data;

- (void)setDoubleValue:(NSDictionary *)data;
- (void)setMaxValue:(NSDictionary *)data;

- (void)dealloc;
@end
