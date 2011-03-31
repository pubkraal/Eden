//
//  MacEFTAppDelegate.m
//  MacEFT
//
//  Created by John Kraal on 3/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "MacEFTAppDelegate.h"

@implementation MacEFTAppDelegate

@synthesize window, label1, label2, label3, label4, label5;
@synthesize val1, val2, val3, val4, val5;
@synthesize max1, max2, max3, max4, max5;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	unsigned i;
	
	[self setLabel1:@"text 1"];
	[self setLabel2:@"text 2"];
	[self setLabel3:@"text 3"];
	[self setLabel4:@"text 4"];
	[self setLabel5:@"text 5"];
	
	URLList = [[NSDictionary alloc] initWithObjectsAndKeys:\
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/01%20%20Coldplay%20-%20Life%20In%20Technicolor.mp3", @"song1", \
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/02%20%20Coldplay%20-%20Cemeteries%20Of%20London.mp3", @"song2", \
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/03%20%20Coldplay%20-%20Lost.mp3", @"song3", \
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/04%20%20Coldplay%20-%2042.mp3", @"song4", \
			   nil];
	
	cbList = [[NSDictionary alloc] initWithObjectsAndKeys:\
			  EveMakeCallback(@selector(song1Finished:), self), @"song1", \
			  EveMakeCallback(@selector(song2Finished:), self), @"song2", \
			  EveMakeCallback(@selector(song3Finished:), self), @"song3", \
			  EveMakeCallback(@selector(song4Finished:), self), @"song4", \
			  nil];
	
	for (i = 1; i <= 5; i++) {
		[self setValue:[NSNumber numberWithInt:0] forKeyPath:[NSString stringWithFormat:@"val%u", i]];
		[self setValue:[NSNumber numberWithInt:100] forKeyPath:[NSString stringWithFormat:@"max%u", i]];
	}
	
}

- (IBAction)startDownloads:(id)aButton {
	EveDownload * download;
	
	download = [[EveDownload alloc] initWithURLList:URLList andCallbacks:cbList finished:EveMakeCallback(@selector(allFinished:), self)];
	
	[download addObserver:self forKeyPath:@"downloads.song1.expectedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song1.receivedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song2.expectedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song2.receivedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song3.expectedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song3.receivedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song4.expectedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"downloads.song4.receivedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"expectedLength" options:NSKeyValueObservingOptionNew context:nil];
	[download addObserver:self forKeyPath:@"receivedLength" options:NSKeyValueObservingOptionNew context:nil];
	
	[p1 setUsesThreadedAnimation:YES];
	[p2 setUsesThreadedAnimation:YES];
	[p3 setUsesThreadedAnimation:YES];
	[p4 setUsesThreadedAnimation:YES];
	[p5 setUsesThreadedAnimation:YES];
	
	[download start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	SEL selector;
	unsigned prop;
	
	selector = ([keyPath hasSuffix:@"receivedLength"]) ? @selector(setDoubleValue:) : @selector(setMaxValue:);
	
	if ([keyPath rangeOfString:@"song1"].location != NSNotFound) {
		prop = 1;
	}
	else if ([keyPath rangeOfString:@"song2"].location != NSNotFound) {
		prop = 2;
	}
	else if ([keyPath rangeOfString:@"song3"].location != NSNotFound) {
		prop = 3;
	}
	else if ([keyPath rangeOfString:@"song4"].location != NSNotFound) {
		prop = 4;
	}
	else {
		prop = 5;
	}
	
	[self performSelectorInBackground:selector withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:prop], @"number", [change objectForKey:NSKeyValueChangeNewKey], @"value", nil]];
	
	
}

- (void)setDoubleValue:(NSDictionary *)data {
	NSString * propIntValue;
	NSString * propString;
	NSString * propMax;
	NSString * propStringValue;
	NSNumber * num;
	NSNumber * value;
	NSAutoreleasePool * pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	num   = [data objectForKey:@"number"];
	value = [data objectForKey:@"value"];
	
	propMax         = [NSString stringWithFormat:@"max%@", num];
	propIntValue    = [NSString stringWithFormat:@"val%@", num];
	propString      = [NSString stringWithFormat:@"label%@", num];
	propStringValue = [NSString stringWithFormat:@"%@ of %@ bytes", value, [self valueForKeyPath:propMax]];
	
	[self setValue:value forKeyPath:propIntValue];
	[self setValue:propStringValue forKeyPath:propString];
	
	[pool drain];
	
}

- (void)setMaxValue:(NSDictionary *)data {
	NSString * propIntValue;
	NSString * propString;
	NSString * propVal;
	NSString * propStringValue;
	NSNumber * num;
	NSNumber * value;
	NSAutoreleasePool * pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	
	num   = [data objectForKey:@"number"];
	value = [data objectForKey:@"value"];
	
	propVal         = [NSString stringWithFormat:@"val%@", num];
	propIntValue    = [NSString stringWithFormat:@"max%@", num];
	propString      = [NSString stringWithFormat:@"label%@", num];
	propStringValue = [NSString stringWithFormat:@"%@ of %@ bytes", [self valueForKeyPath:propVal], value];
	
	[self setValue:value forKeyPath:propIntValue];
	[self setValue:propStringValue forKeyPath:propString];

	[pool drain];
}


- (void)song1Finished:(NSDictionary *)data {
	NSLog(@"Song 1 finished)");
	
	if ([data valueForKey:@"error"]) {
		NSLog(@"An error occurred: %@", [(NSError *) [data valueForKey:@"error"] localizedDescription]);
	}
}

- (void)song2Finished:(NSDictionary *)data {
	NSLog(@"Song 2 finished)");
	
	if ([data valueForKey:@"error"]) {
		NSLog(@"An error occurred: %@", [(NSError *) [data valueForKey:@"error"] localizedDescription]);
	}
}

- (void)song3Finished:(NSDictionary *)data {
	NSLog(@"Song 3 finished)");
	
	if ([data valueForKey:@"error"]) {
		NSLog(@"An error occurred: %@", [(NSError *) [data valueForKey:@"error"] localizedDescription]);
	}
}

- (void)song4Finished:(NSDictionary *)data {
	NSLog(@"Song 4 finished)");
	
	if ([data valueForKey:@"error"]) {
		NSLog(@"An error occurred: %@", [(NSError *) [data valueForKey:@"error"] localizedDescription]);
	}
}

- (void)allFinished:(NSData *)data {
	NSLog(@"All finished!");
}

- (void)dealloc {
	[URLList release];
	[cbList release];
	
	[super dealloc];
}

@end
