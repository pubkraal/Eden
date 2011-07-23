//
//	EdenDocumentController.m
//	Eden
//
//	Created by Ugo Pozo on 7/21/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "EdenDocumentController.h"
#import "EdenAppDelegate.h"

@implementation EdenDocumentController

- (id)init {
	if ((self = [super init])) {
		// Initialization code here.
	}
	
	return self;
}

- (void)reopenDocumentForURL:(NSURL *)urlOrNil withContentsOfURL:(NSURL *)contentsURL display:(BOOL)displayDocument completionHandler:(void (^)(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error))completionHandler {
	EdenAppDelegate * appDelegate;
	NSDictionary * info;
	
	appDelegate = (EdenAppDelegate *) [[NSApplication sharedApplication] delegate];
	
	if (!appDelegate.dbLoaded) {
		info = [[NSDictionary alloc] initWithObjectsAndKeys:
									(urlOrNil) ? urlOrNil : [NSNull null], @"URL",
									contentsURL, @"contentsURL",
									[NSNumber numberWithBool:displayDocument], @"display",
									Block_copy(completionHandler), @"handler", nil];
		
		[self performSelectorInBackground:@selector(delayedOpening:) withObject:info];
	}
	else [super reopenDocumentForURL:urlOrNil withContentsOfURL:contentsURL display:displayDocument completionHandler:completionHandler];
}

- (void)delayedOpening:(id)info {
	EdenAppDelegate * appDelegate;
	NSAutoreleasePool * pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	appDelegate = (EdenAppDelegate *) [[NSApplication sharedApplication] delegate];
	
	while (!appDelegate.dbLoaded) ;
	
	[self performSelectorOnMainThread:@selector(postDelayedOpening:) withObject:info waitUntilDone:NO];
	
	[pool drain];
}

- (void)postDelayedOpening:(id)arg {
	NSDictionary * info;
	id url;
	
	info = (NSDictionary *) arg;
	url  = [info objectForKey:@"URL"];
	url  = (url != [NSNull null]) ? url : nil;
	
	[super reopenDocumentForURL:url
			  withContentsOfURL:[info objectForKey:@"contentsURL"]
						display:[[info objectForKey:@"display"] boolValue]
			  completionHandler:[info objectForKey:@"handler"]];
	
	[[info objectForKey:@"handler"] release];
	
	[info release];
}

@end
