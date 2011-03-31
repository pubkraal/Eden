//
//  EveDownload.m
//  MacEFT
//
//  Created by ugo pozo on 3/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveDownload.h"

@implementation EveCallback

@synthesize selector, object;

- (id)initWithSelector:(SEL)aSelector andObject:(id)anObject {
	if ((self = [super init])) {
		[self setSelector:aSelector];
		[self setObject:anObject];
	}
	
	return self;
}

- (void)callWithObject:(id)anObject {
	[[self object] performSelector:[self selector] withObject:anObject];
}

- (void)dealloc {
	[self setObject:nil];
	
	[super dealloc];
}

+ (EveCallback *)callbackWithSelector:(SEL)aSelector andObject:(id)anObject {
	return [[[EveCallback alloc] initWithSelector:aSelector andObject:anObject] autorelease];
}

@end


@implementation EveThreadInfo

@synthesize URL, error, expectedLength, receivedLength, result, callback, connection;

- (id)initWithURLString:(NSString *) url {
	if ((self = [super init])) {
		[self setURL:url];

		[self setError:nil];
		[self setResult:nil];
		[self setCallback:nil];

		[self setExpectedLength:0L];
		[self setReceivedLength:0L];
		
		[self setConnection:nil];
}
	
	return self;
}

- (void)dealloc {
	[self setURL:nil];
	[self setError:nil];
	[self setResult:nil];
	[self setCallback:nil];
	[self setConnection:nil];
	
	[super dealloc];
}

@end


@implementation EveDownload

@synthesize downloads, expectedLength, receivedLength, mainCallback;

- (id)initWithURLList:(NSDictionary *)urls andCallbacks:(NSDictionary *)callbacks finished:(EveCallback *)finished {
	NSMutableDictionary * d;
	NSString * name, * str_url;
	EveThreadInfo * info;
	
	if ((self = [super init])) {
		d = [[NSMutableDictionary alloc] initWithCapacity:10];
		
		for (name in [urls allKeys]) {
			str_url = [urls objectForKey: name];
			info    = [[EveThreadInfo alloc] initWithURLString:str_url];
			
			[d setObject:info forKey:name];
			
			[info release];
		}
		
		if (callbacks) {
			for (name in [d allKeys]) {
				if ([[callbacks allKeys] indexOfObject:name] != NSNotFound) {
					[(EveThreadInfo *) [d objectForKey:name] setCallback:[callbacks objectForKey:name]];
				}
			}
		}
		
		non_finished = 0;
		
		[self setMainCallback:finished];
		
		downloads = [[NSDictionary alloc] initWithDictionary:d];
		[d release];
	}
	
	return self;
}

- (id)initWithURLList:(NSDictionary *)urls finished:(EveCallback *)finished {
	return [self initWithURLList:urls andCallbacks:nil finished:finished];
}

- (void)start {
	NSURLRequest * request;
	NSURLConnection * connection;
	NSURL * url;
	EveThreadInfo * info;
	
	non_finished = (unsigned) [downloads count];
	
	for (info in [downloads allValues]) {
		url        = [NSURL URLWithString:[info URL]];
		request    = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		[info setConnection:connection];
		[info setResult:[NSMutableData data]];
		
		[connection start];
		
		[connection release];
		[request release];
	}
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	EveThreadInfo * info;
	
	info = [self infoForConnection:connection];
	
	if ([response expectedContentLength] != NSURLResponseUnknownLength) {
		[info setExpectedLength:((uint64_t) [response expectedContentLength])];
		[self setExpectedLength:([self expectedLength] + [response expectedContentLength])];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	EveThreadInfo * info;
	
	info = [self infoForConnection:connection];
	
	[[info result] appendData:data];
	[info setReceivedLength:([info receivedLength] + [data length])];
	[self setReceivedLength:([self receivedLength] + [data length])];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	EveThreadInfo * info;
	NSDictionary * retval;

	info   = [self infoForConnection:connection];
	retval = [[NSDictionary alloc] initWithObjectsAndKeys:nil, @"data", error, @"error", nil];
	
	[info setError:error];
	
	[[info callback] callWithObject:retval];
	
	[retval release];
	
	non_finished--;
	
	if (!non_finished) {
		[[self mainCallback] callWithObject:downloads];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	EveThreadInfo * info;
	NSDictionary * retval;
	
	info   = [self infoForConnection:connection];
	retval = [[NSDictionary alloc] initWithObjectsAndKeys:(NSData *) [info result], @"data", nil, @"error", nil];
	
	[[info callback] callWithObject:retval];
	
	[retval release];
	
	non_finished--;
	
	if (!non_finished) {
		[[self mainCallback] callWithObject:downloads];
	}
	
}

- (uint64_t)expectedLengthForName:(NSString *)name {
	@try {
		return [(EveThreadInfo *) [downloads objectForKey:name] expectedLength];
	}
	@catch (NSException *exception) {
		return 0;
	}
}

- (uint64_t)receivedLengthForName:(NSString *)name {
	@try {
		return [(EveThreadInfo *) [downloads objectForKey:name] receivedLength];
	}
	@catch (NSException *exception) {
		return 0;
	}
}

- (EveThreadInfo *)infoForConnection:(NSURLConnection *)connection {
	EveThreadInfo * info, * cursor;
	
	info = nil;
	
	for (cursor in [downloads allValues]) {
		if ([cursor connection] == connection) info = cursor;
	}
	
	return info;
}

- (void)dealloc {
	[self setMainCallback:nil];
	[downloads release];
	
	[super dealloc];
}

@end

EveCallback * EveMakeCallback(SEL selector, id object) {
	return [EveCallback callbackWithSelector:selector andObject:object];
}