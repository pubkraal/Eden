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


// Information for each download.

@interface EveDownloadInfo : NSObject {
@private
    NSString * URL;
	uint64_t expectedLength;
	uint64_t receivedLength;
	NSError * error;
	NSMutableData * result;
	NSURLConnection * connection;
}

- (id)initWithURLString:(NSString *) url;
- (void)dealloc;


@property (retain) NSURLConnection * connection;
@property (retain) NSString * URL;
@property (retain) NSError * error;
@property (retain) NSMutableData * result;
@property (assign) uint64_t expectedLength;
@property (assign) uint64_t receivedLength;

- (NSData *)data; // returns a static version of the mutable result.

@end

// Declaring a protocol for delegates. Delegates should handle the completion
// of each individual download and the completion of the whole batch.

@class EveDownload;

@protocol EveDownloadDelegate <NSObject>

- (void)didFinishDownload:(EveDownload *)download withResults:(NSDictionary *)results;

@optional

- (void)didFinishDownload:(EveDownload *)download forKey:(NSString *)key withData:(NSData *)data error:(NSError *)error;

@end

// The object which performs the download and the multitasking. When each
// download finished, and when all of them are finished, it will call the
// respective methods in the delegate. The expectedLength and
// receivedLength properties of both the EveDownload object and each individual
// download are observable.


@interface EveDownload : NSObject {
	NSDictionary * downloads;
	uint64_t expectedLength;
	uint64_t receivedLength;
	unsigned non_finished;
	NSObject <EveDownloadDelegate> * delegate;
}

@property (retain) NSObject <EveDownloadDelegate> * delegate;
@property (readonly) NSDictionary * downloads;

// Starting up

- (id)initWithURLList:(NSDictionary *)urls;
- (void)start;

// Delegated messages from NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)downloadFinished:(NSURLConnection *) connection withError:(NSError *)error;

// Querying messages

@property (assign) uint64_t expectedLength;
@property (assign) uint64_t receivedLength;

- (void)addObserver:(NSObject *)anObserver; // Convenience method to observe all available properties.
- (void)removeObserver:(NSObject *)anObserver; // Convenience method to remove all observers.

- (NSDictionary *)results; // All the data downloaded and errors in a dictionary.

// Etc.

- (EveDownloadInfo *)infoForConnection:(NSURLConnection *)connection; // Look up the downloads dictionary for the corresponding info.

// Cleaning the house

- (void)dealloc;

@end




