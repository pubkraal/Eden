//
//  EveDownload.m
//  MacEFT
//
//  Created by ugo pozo on 3/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveDownload.h"


@implementation EveThreadInfo

@synthesize URL, error, totalBytes, downloaded, result;

- (id)initWithURL:(NSString *) url {
	if ((self = [super init])) {
		[self setURL:url];
		[self setError:nil];
		[self setTotalBytes:0L];
		[self setDownloaded:0L];
		[self setResult:nil];
		[self setCallback:EveMakeCallback(@selector(init), nil)];
	}
	
	return self;
}

- (void)dealloc {
	[self setURL:nil];
	[self setError:nil];
	[self setResult:nil];
	[self setCallback:EveMakeCallback(@selector(init), nil)];
	
	[super dealloc];
}

- (callback_t)callback {
	return callback;
}

- (void)setCallback:(callback_t)new_callback {
	// Making sure the object in the callback is available to us and
	// that we not spawn any zombies.
	
	[callback.object release];
	[new_callback.object retain];
	
	callback = new_callback;
}

@end


@implementation EveDownload

@synthesize threads;

- (id)initWithURLList:(NSArray *)urls andCallbacks:(NSArray *)callbacks finished:(callback_t)finished {
	if ((self = [super init])) {
		
	}
	
	return self;
}

- (id)initWithURLList:(NSArray *)urls finished:(callback_t)finished {
	return [self initWithURLList:urls andCallbacks:nil finished:finished];
}

@end

callback_t EveMakeCallback(SEL selector, id object) {
	callback_t cb;
	
	cb.selector = selector;
	cb.object   = object;
	
	return cb;
}