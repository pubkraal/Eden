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

@synthesize maxValues, currentValues, indicators, labels, textFields;

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
	
	[self setTextFields:[NSDictionary dictionaryWithObjectsAndKeys:\
						 l1, @"song1", \
						 l2, @"song2", \
						 l3, @"song3", \
						 l4, @"song4", \
						 l5, @"total", \
						 nil]];

	
	URLList = [[NSDictionary alloc] initWithObjectsAndKeys:\
			   @"http://wiki.icmc.usp.br/images/7/73/SCC211Cap1.pdf", @"song1", \
			   @"http://wiki.icmc.usp.br/images/3/37/SCC211Cap2_1.pdf", @"song2", \
			   @"http://wiki.icmc.usp.br/images/7/71/SCC211Cap2_2.pdf", @"song3", \
			   @"http://wiki.icmc.usp.br/images/1/1e/SCC211Cap3.pdf", @"song4", \
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
	NSString * key, * type, * labelFormat;
	id value;

	value       = [change objectForKey:NSKeyValueChangeNewKey];
	labelFormat = @"%@ of %@ bytes downloaded";
	
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
	
	if ([type isEqualToString:@"expectedLength"]) {
		type = @"maxValues";
		[[self labels] setValue:[NSString stringWithFormat:labelFormat, [[self currentValues] objectForKey:key], value] forKey:key];
	}
	else {
		type = @"currentValues";
		[[self labels] setValue:[NSString stringWithFormat:labelFormat, value, [[self maxValues] objectForKey:key]] forKey:key];
	}
	
	[self performSelectorInBackground:@selector(updateWithData:) withObject:[NSDictionary dictionaryWithObjectsAndKeys: \
																			 key, @"key", \
																			 type, @"type", \
																			 value, @"value", \
																			 nil]];
}

- (void)updateWithData:(id)theData {
	NSAutoreleasePool * pool;
	NSDictionary * data;
	NSString * keyPath;
	
	pool = [[NSAutoreleasePool alloc] init];

	data    = (NSDictionary *) theData;
	keyPath = @"%@.%@";
	
	[self setValue:[data objectForKey:@"value"] forKeyPath:[NSString stringWithFormat:keyPath, [data objectForKey:@"type"], [data objectForKey:@"key"]]];
	
	
	[pool drain];
}

- (void)didFinishDownload:(EveDownload *)download forKey:(NSString *)key withData:(NSData *)data error:(NSError *)error {
	NSString * content;
	
	content = (error) ? [error localizedDescription] : [NSString stringWithFormat:@"Download %@ has finished.", key];

	[self setValue:content forKeyPath:[NSString stringWithFormat:@"labels.%@", key]];

}

- (void)didFinishDownload:(EveDownload *)download withResults:(NSDictionary *)results {
	NSString * key;
	NSDictionary * result;
	unsigned success, failure;
	
	success = 0;
	
	for (key in [results allKeys]) {
		result = [results objectForKey:key];
		
		if (![result objectForKey:@"error"]) success++;
	}
	
	failure = (unsigned) [results count] - success;
	
	[self setValue:[NSString stringWithFormat:@"All downloads have finished! Successes: %u - Failures %u", success, failure] forKeyPath:@"labels.total"];
	
	[download removeObserver:self];
	
	[download release];
}


- (void)dealloc {
	[URLList release];
	
	[super dealloc];
}

@end
