//
//  MacEFTAppDelegate.m
//  MacEFT
//
//  Created by John Kraal on 3/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "MacEFTAppDelegate.h"

@implementation MacEFTAppDelegate

@synthesize window;

@synthesize maxValues, currentValues, indicators, labels;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self setMaxValues:[NSMutableDictionary dictionaryWithObjectsAndKeys:\
						[NSNumber numberWithInt:100], @"song1", \
						[NSNumber numberWithInt:100], @"song2", \
						[NSNumber numberWithInt:100], @"song3", \
						[NSNumber numberWithInt:100], @"song4", \
						[NSNumber numberWithInt:100], @"total", \
						nil]];

	[self setCurrentValues:[NSMutableDictionary dictionaryWithObjectsAndKeys:\
						[NSNumber numberWithInt:0], @"song1", \
						[NSNumber numberWithInt:0], @"song2", \
						[NSNumber numberWithInt:0], @"song3", \
						[NSNumber numberWithInt:0], @"song4", \
						[NSNumber numberWithInt:0], @"total", \
						nil]];
	
	[self setLabels:[NSMutableDictionary dictionaryWithObjectsAndKeys:\
						@"Song 1", @"song1", \
						@"Song 2", @"song2", \
						@"Song 3", @"song3", \
						@"Song 4", @"song4", \
						@"Total", @"total", \
						nil]];
	
	[self setIndicators:[NSDictionary dictionaryWithObjectsAndKeys:\
						p1, @"song1", \
						p2, @"song2", \
						p3, @"song3", \
						p4, @"song4", \
						p5, @"total", \
						nil]];	
	
	URLList = [[NSDictionary alloc] initWithObjectsAndKeys:\
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/01%20%20Coldplay%20-%20Life%20In%20Technicolor.mp3", @"song1", \
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/02%20%20Coldplay%20-%20Cemeteries%20Of%20London.mp3", @"song2", \
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/03%20%20Coldplay%20-%20Lost.mp3", @"song3", \
			   @"http://team.fatal1ty.free.fr/Damn%20That%20Music%20Made%20my%20Way/Coldplay/Viva%20La%20Vida/04%20%20Coldplay%20-%2042.mp3", @"song4", \
			   nil];
	
}

- (IBAction)startDownloads:(id)aButton {
	EveDownload * download;
	NSProgressIndicator * indic;
	
	download = [[EveDownload alloc] initWithURLList:URLList];
	
	
	[download addObserver:self];
	[download setDelegate:self];
	
	for (indic in [[self indicators] allValues]) {
		[indic setUsesThreadedAnimation:YES];
	}
	
	[download start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSArray * pathComponents;
	NSString * key, * type;
	
	pathComponents = [keyPath componentsSeparatedByString:@"."];
	
	if ([pathComponents count] < 3) {
		// This means it's an event relative to the download object itself
		
		key  = @"total";
		type = keyPath;
	}
	else {
		key  = [pathComponents objectAtIndex:1];
		type = [pathComponents objectAtIndex:2];
	}
	
	type = ([type isEqualToString:@"expectedLength"]) ? @"maxValues" : @"currentValues";
	
	[self performSelectorInBackground:@selector(updateWithData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys: \
																			 key, @"key", \
																			 type, @"type", \
																			 [change objectForKey:NSKeyValueChangeNewKey], @"value", \
																			 nil]];
}

- (void)updateWithData:(id)theData {
	NSAutoreleasePool * pool;
	NSDictionary * data;
	NSString * keyPath, * type, * key, * labelFormat;
	id value;
	
	pool = [[NSAutoreleasePool alloc] init];

	keyPath     = @"%@.%@";
	labelFormat = @"%@ of %@ bytes downloaded";
	
	data  = (NSDictionary *) theData;
	type  = [data objectForKey:@"type"];
	key   = [data objectForKey:@"key"];
	value = [data objectForKey:@"value"];
	
	[self setValue:value forKeyPath:[NSString stringWithFormat:keyPath, type, key]];
	
	if ([type isEqualToString:@"maxValues"]) {
		[[self labels] setValue:[NSString stringWithFormat:labelFormat, [[self currentValues] objectForKey:key], value] forKey:key];
	}
	else {
		[[self labels] setValue:[NSString stringWithFormat:labelFormat, value, [[self maxValues] objectForKey:key]] forKey:key];
	}
	
	[pool drain];
}

- (void)didFinishDownload:(EveDownload *)download forKey:(NSString *)key withData:(NSData *)data error:(NSError *)error {
	NSLog(@"Download %@ has finished.", key);
	
	if (error) {
		NSLog(@"An error occured: %@", [error localizedDescription]);
	}
}

- (void)didFinishDownload:(EveDownload *)download withResults:(NSDictionary *)results {
	NSString * key;
	NSDictionary * result;
	
	NSLog(@"All downloads have finished!");
	
	for (key in [results allKeys]) {
		result = [results objectForKey:key];
		
		NSLog(@"- %@: %@", key, ([result objectForKey:@"error"]) ? @"Failure" : @"Success");
	}
}


- (void)dealloc {
	[URLList release];
	
	[super dealloc];
}

@end
