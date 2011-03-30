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

typedef struct callback callback_t;

struct callback {
	SEL selector;
	id object;
};

// Information for each download thread.

@interface EveThreadInfo : NSObject {
@private
    NSString * URL;
	uint64_t totalBytes;
	uint64_t downloaded;
	NSError * error;
	NSData * result;
	callback_t callback;
}

- (id)initWithURL:(NSString *) url;
- (void)dealloc;


@property (retain) NSString * URL;
@property (retain) NSError * error;
@property (assign) uint64_t totalBytes;
@property (assign) uint64_t downloaded;
@property (retain) NSData * result;
@property callback_t callback;

@end

// The object which performs the download and the multitasking. It will call the callbacks
// when it's finished downloading. It will also allow querying for dynamic update of the interface.
// Querying will be KVC-compliant.

@interface EveDownload : NSObject {
	NSMutableDictionary * threads;
}

- (id)initWithURLList:(NSArray *)urls andCallbacks:(NSArray *)callbacks finished:(callback_t)finished;
- (id)initWithURLList:(NSArray *)urls finished:(callback_t)finished;

@property (readonly) NSMutableDictionary * threads;

@end

// Convenience function for creating callbacks.

callback_t EveMakeCallback(SEL, id);