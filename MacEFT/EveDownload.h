//
//  EveDownload.h
//  MacEFT
//
//  Created by ugo pozo on 3/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <stdlib.h>
#include <unistd.h>


// A simple callback structure, so we can warn the application when the download
// has finished and/or has an error. Number of arguments TBD, but I'm thinking an
// NSData * for the result and an NSError ** for any errors that happen.

// Change: callback_t will now be EveCallback, and it will be an full-fledged class
// instead of an structure. The reason for this is that we need an NSArray of
// callbacks passed to EveDownload, and NSArray can only hold objects of type id.


@interface EveCallback : NSObject {
@private
    SEL selector;
	id object;
}

- (id)initWithSelector:(SEL)aSelector andObject:(id)anObject;
- (void)callWithObject:(id)anObject;
- (void)dealloc;

+ (EveCallback *)callbackWithSelector:(SEL)aSelector andObject:(id)anObject;

@property (retain) id object;
@property (assign) SEL selector;

@end


typedef struct callback callback_t;

struct callback {
	SEL selector;
	id object;
};

// Information for each download thread.

@interface EveThreadInfo : NSObject {
@private
    NSString * URL;
	uint64_t expectedLength;
	uint64_t receivedLength;
	NSError * error;
	NSMutableData * result;
	EveCallback * callback;
	NSURLConnection * connection;
}

- (id)initWithURLString:(NSString *) url;
- (void)dealloc;


@property (retain) NSURLConnection * connection;
@property (retain) NSString * URL;
@property (retain) NSError * error;
@property (assign) uint64_t expectedLength;
@property (assign) uint64_t receivedLength;
@property (retain) NSMutableData * result;
@property (retain) EveCallback * callback;

@end

// The object which performs the download and the multitasking. It will call the callbacks
// when it's finished downloading. It will also allow querying for dynamic update of the interface.
// Querying will be KVC-compliant.

@interface EveDownload : NSObject {
	NSDictionary * downloads;
	uint64_t expectedLength;
	uint64_t receivedLength;
	EveCallback * mainCallback;
	unsigned non_finished;
}

@property (readonly) NSDictionary * downloads;
@property (retain) EveCallback * mainCallback;

- (id)initWithURLList:(NSArray *)urls andCallbacks:(NSArray *)callbacks finished:(EveCallback *)finished;
- (id)initWithURLList:(NSArray *)urls finished:(EveCallback *)finished;

- (void)start;

// Delegated messages from NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

// Querying messages

@property (assign) uint64_t expectedLength;
@property (assign) uint64_t receivedLength;

- (uint64_t)expectedLengthForURL:(NSString *)url;
- (uint64_t)receivedLengthForURL:(NSString *)url;

// Etc

- (EveThreadInfo *)infoForConnection:(NSURLConnection *)connection;
- (void)dealloc;

@end

// Convenience function for creating callbacks.

EveCallback * EveMakeCallback(SEL, id);