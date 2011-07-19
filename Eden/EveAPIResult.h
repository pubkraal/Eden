//
//  EveAPIResult.h
//  Eden
//
//  Created by ugo pozo on 7/18/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAttributeKey @"_EDEN_ATTRIBUTE_%010d_"

typedef struct processed_node_s processed_node_t;

struct processed_node_s {
	NSString * key;
	id value;
};

@interface EveAPIResult : NSObject {
@private
	NSDate * currentTime;
	NSDate * cachedUntil;
	
	NSError * internalError, * CCPError;
	NSDictionary * data;
	NSData * rawData;
}

@property (readonly) NSDate * currentTime, * cachedUntil;
@property (readonly) NSError * error;
@property (readonly) NSDictionary * data;
@property (readonly) NSData * rawData;

- (id)initWithData:(NSData *)aData;
+ (id)resultWithData:(NSData *)aData;

- (void)processDates:(NSXMLDocument *)doc;
- (void)processResult:(NSXMLDocument *)doc;
- (void)processCCPError:(NSXMLDocument *)doc;

- (NSDictionary *)processNodeList:(NSArray *)nodeList;

@end