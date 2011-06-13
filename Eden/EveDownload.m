//
//  EveDownload.m
//  Eden
//
//  Created by ugo pozo on 3/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveDownload.h"


@implementation EveDownloadInfo

@synthesize URL, error, expectedLength, receivedLength, result, connection, postBody, chunked, cached;

- (id)initWithURLString:(NSString *) url {
	if ((self = [super init])) {
		[self setURL:url];

		[self setError:nil];
		[self setResult:nil];

		[self setExpectedLength:0L];
		[self setReceivedLength:0L];
		
		[self setConnection:nil];

		[self setPostBody:nil];
		
		[self setChunked:NO];
		[self setCached:NO];
	}
	
	return self;
}

- (NSData *)data {
	return [NSData dataWithData:[self result]];
}

- (void)setPostBodyToString:(NSString *)string withEncoding:(NSStringEncoding)encoding {
	NSData * data;
	
	if ([string canBeConvertedToEncoding:encoding]) {
		string = [string stringByAddingPercentEscapesUsingEncoding:encoding];
		data   = [string dataUsingEncoding:encoding];		
		
		[self setPostBody:data];
	}
}

- (void)setPostBodyToUTF8String:(NSString *)string {
	[self setPostBodyToString:string withEncoding:NSUTF8StringEncoding];
}

- (void)setPostBodyToDict:(NSDictionary *)dict {
	__block NSMutableArray * data;
	__block NSString * keyPair, * key;

	data = [NSMutableArray array];

	[dict enumerateKeysAndObjectsUsingBlock:^(id idKey, id obj, BOOL * stop) {
		key = (NSString *) idKey;

		if ([obj isKindOfClass:[NSArray class]]) {
			[(NSArray *) obj enumerateObjectsUsingBlock:^(id deepObj, NSUInteger idx, BOOL * stop) {
				keyPair = [NSString stringWithFormat:@"%@=%@", key, [deepObj description]];

				[data addObject:keyPair];
			}];
		}
		else {
			keyPair = [NSString stringWithFormat:@"%@=%@", key, [obj description]];

			[data addObject:keyPair];
		}
	}];

	[self setPostBodyToUTF8String:[data componentsJoinedByString:@"&"]];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"URL: %@", [self URL]];
}

- (void)dealloc {
	[self setURL:nil];
	[self setError:nil];
	[self setResult:nil];
	[self setConnection:nil];
	[self setPostBody:nil];
	
	[super dealloc];
}

@end


@implementation EveDownload

@synthesize downloads, expectedLength, receivedLength, delegate;

- (id)initWithURLList:(NSDictionary *)urls {
	NSString * name, * strURL;
	EveDownloadInfo * info;
	
	if ((self = [super init])) {
		downloads = [[NSMutableDictionary alloc] init];
		
		for (name in [urls allKeys]) {
			strURL = [urls objectForKey: name];
			info   = [[EveDownloadInfo alloc] initWithURLString:strURL];
			
			[downloads setObject:info forKey:name];
			
			[info release];
		}
		
		non_finished = 0;
	}
	
	return self;
}

+ (id)downloadWithURLList:(NSDictionary *)urls {
	return [[[self alloc] initWithURLList:urls] autorelease];
}


- (void)start {
	NSURLRequest * request;
	NSMutableURLRequest * mutableRequest;
	NSURLConnection * connection;
	NSURL * url;
	EveDownloadInfo * info;
	
	non_finished = (unsigned) [downloads count];
	
	for (info in [downloads allValues]) {
		url = [NSURL URLWithString:[info URL]];

		if (![info postBody]) {
			request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
		}
		else {
			mutableRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0];
			
			[mutableRequest setHTTPMethod:@"POST"];
			[mutableRequest setHTTPBody:[info postBody]];
			[mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

			request = (NSURLRequest *) mutableRequest;
		}
		
		if (![info cached]) {
			[info setResult:[NSMutableData data]];

			connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

			[info setConnection:connection];

			[connection start];

			[connection release];
		}
		else {
			[info setConnection:[info URL]];
			[self performSelectorInBackground:@selector(cachedDownloadBegan:) withObject:info];
		}
		
		[request release];
	}
}

- (void)cancel {
	EveDownloadInfo * info;
	
	if (non_finished) {
		for (info in [downloads allValues]) {
			if ([info connection]) [[info connection] cancel];
		}
	}
}

- (void)setPostBodyToDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
	[(EveDownloadInfo *) [self.downloads objectForKey:key] setPostBodyToDict:dictionary];
}

- (void)useCachedData:(NSData *)data forKey:(NSString *)key {
	EveDownloadInfo * info;
	
	info = [self.downloads objectForKey:key];
	
	[info setCached:YES];
	[info setResult:[NSMutableData dataWithData:data]];
}

- (void)cancelDownloadForKey:(NSString *)key {
	[downloads removeObjectForKey:key];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	EveDownloadInfo * info;
	NSHTTPURLResponse * httpResponse;
	NSError * error;
	NSDictionary * errorInfo;
	NSString * errorDesc;
	long statusCode;
	statusCode = -1;
	
	if ([response respondsToSelector:@selector(statusCode)]) {
		httpResponse = (NSHTTPURLResponse *) response;
		statusCode   = [httpResponse statusCode];

		if (statusCode >= 400) {
			[connection cancel];
			
			errorDesc = [NSString stringWithFormat:@"Server returned status code %d", statusCode];
			errorInfo = [NSDictionary dictionaryWithObject:errorDesc forKey:NSLocalizedDescriptionKey];
			error     = [NSError errorWithDomain:@"HTTPError" code:statusCode userInfo:errorInfo];

			[self connection:connection didFailWithError:error];
		}
	}
	
	if (statusCode < 400) {
		info = [self infoForConnection:connection];
		
		if ([response expectedContentLength] != NSURLResponseUnknownLength) {
			[info setExpectedLength:((uint64_t) [response expectedContentLength])];
			[self setExpectedLength:([self expectedLength] + [response expectedContentLength])];
		}
		else [info setChunked:YES];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	EveDownloadInfo * info;
	
	info = [self infoForConnection:connection];
	
	[[info result] appendData:data];
	[info setReceivedLength:([info receivedLength] + [data length])];
	[self setReceivedLength:([self receivedLength] + [data length])];
	
	if ([info chunked]) {
		[info setExpectedLength:([info expectedLength] + (uint64_t) [data length])];
		[self setExpectedLength:([self expectedLength] + (uint64_t) [data length])];
	}
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self downloadFinished:connection withError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self downloadFinished:connection withError:nil];
}

- (void)downloadFinished:(NSURLConnection *)connection withError:(NSError *)error {
	EveDownloadInfo * info;
	NSData * data;
	NSString * key;
	
	info = [self infoForConnection:connection];
	data = (error) ? nil : [info data];
	key  = [[downloads allKeysForObject:info] objectAtIndex:0];

	[info setError:error];
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(didFinishDownload:forKey:withData:error:)]) {
		[[self delegate] didFinishDownload:self forKey:key withData:data error:error];
	}
	
	non_finished--;
	
	if ([self delegate] && !non_finished)
		[[self delegate] didFinishDownload:self withResults:[self results]];
	
	[info setConnection:nil];
}

- (void)cachedDownloadBegan:(id)rawInfo {
	EveDownloadInfo * info;
	NSAutoreleasePool * pool;
	
	pool = [[NSAutoreleasePool alloc] init];
	
	info = (EveDownloadInfo *) rawInfo;
	
	[info setExpectedLength:(uint64_t) [[info data] length]];
	[info setReceivedLength:(uint64_t) [[info data] length]];
	
	[self performSelectorOnMainThread:@selector(cachedDownloadFinished:) withObject:info waitUntilDone:NO];
	
	[pool drain];
}

- (void)cachedDownloadFinished:(id)rawInfo {
	EveDownloadInfo * info;
	
	info = (EveDownloadInfo *) rawInfo;
	
	[self downloadFinished:[info connection] withError:nil];
}

- (void)addObserver:(id)anObserver {
	NSString * keyPath, * key;
	
	keyPath = @"downloads.%@.%@";
	
	[self addTotalObserver:anObserver];
	
	for (key in [downloads allKeys]) {
		[self addObserver:anObserver forKeyPath:[NSString stringWithFormat:keyPath, key, @"expectedLength"] \
				  options:NSKeyValueObservingOptionNew context:self];

		[self addObserver:anObserver forKeyPath:[NSString stringWithFormat:keyPath, key, @"receivedLength"] \
				  options:NSKeyValueObservingOptionNew context:self];
	}
}

- (void)removeObserver:(id)anObserver {
	NSString * keyPath, * key;
	
	keyPath = @"downloads.%@.%@";

	[self removeTotalObserver:anObserver];
	
	for (key in [downloads allKeys]) {
		[self removeObserver:anObserver forKeyPath:[NSString stringWithFormat:keyPath, key, @"expectedLength"]];
		[self removeObserver:anObserver forKeyPath:[NSString stringWithFormat:keyPath, key, @"receivedLength"]];
	}
}

- (void)addTotalObserver:(id)anObserver {
	[self addObserver:anObserver forKeyPath:@"expectedLength" \
			  options:NSKeyValueObservingOptionNew context:self];

	[self addObserver:anObserver forKeyPath:@"receivedLength" \
			  options:NSKeyValueObservingOptionNew context:self];

	
}

- (void)removeTotalObserver:(id)anObserver {
	[self removeObserver:anObserver forKeyPath:@"expectedLength"];
	[self removeObserver:anObserver forKeyPath:@"receivedLength"];
	
}


- (EveDownloadInfo *)infoForConnection:(NSURLConnection *)connection {
	EveDownloadInfo * info, * cursor;
	
	info = nil;
	
	for (cursor in [downloads allValues]) {
		if ([cursor connection] == connection) {
			info = cursor;
			break;
		}
	}
	
	return info;
}


- (void)dealloc {
	[downloads release];
	
	[super dealloc];
}

- (NSDictionary *)results {
	NSMutableDictionary * results;
	NSDictionary * retval, * data;
	NSString * key;
	NSError * error;
	EveDownloadInfo * info;
	
	results = [[NSMutableDictionary alloc] init];
	
	for (key in [downloads allKeys]) {
		info  = [downloads objectForKey:key];
		error = [info error];
		
		data  = [[NSDictionary alloc] initWithObjectsAndKeys: \
				 (error) ? [NSNull null] : [info data], @"data", \
				 (error) ? error : [NSNull null], @"error", \
				 nil];
		
		[results setValue:data forKey:key];
		
		[data release];
	}
	
	retval = [NSDictionary dictionaryWithDictionary:results];
	
	[results release];
	
	return retval;
}

@end



