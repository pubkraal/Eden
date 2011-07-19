//
//	EveAPIResult.m
//	Eden
//
//	Created by ugo pozo on 7/18/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "EveAPIResult.h"
#import "EveAPI.h"

@implementation EveAPIResult

@synthesize currentTime, cachedUntil, data, rawData;

- (id)initWithData:(NSData *)aData {
	NSXMLDocument * doc;
	
	if ((self = [super init])) {
		currentTime   = nil;
		cachedUntil   = nil;
		data          = nil;
		CCPError      = nil;
		internalError = nil;
		rawData       = [aData retain];
		
		doc = [[NSXMLDocument alloc] initWithData:aData options:0 error:&internalError];
		
		if (!internalError) [self processDates:doc];
		if (!internalError) [self processResult:doc];
		if (!internalError) [self processCCPError:doc];
		
		// If anything was set, retain it, as it will be released in
		// dealloc. If not, it's just nil receiving a message, we're
		// cool.

		[currentTime retain];
		[cachedUntil retain];
		[data retain];
		[internalError retain];
		[CCPError retain];
		
		[doc release];
	}
	
	return self;
}

+ (id)resultWithData:(NSData *)aData {
	return [[[EveAPIResult alloc] initWithData:aData] autorelease];
}

- (void)dealloc {
	[currentTime release];
	[cachedUntil release];
	[data release];
	[CCPError release];
	[internalError release];
	[rawData release];
	
	[super dealloc];
}

- (NSError *)error {
	NSError * actualError;
	
	// Internal errors should have priority over CCP errors.
	
	if (internalError) actualError = internalError;
	else if (CCPError) actualError = CCPError;
	else actualError = nil;
	
	return actualError;
}

- (void)processDates:(NSXMLDocument *)doc {
	NSXMLNode * root, * node;
	NSArray * nodeList;
	
	root     = [doc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/currentTime | /eveapi/cachedUntil" error:&internalError];
	
	if (!internalError) {
		for (node in nodeList) {
			if ([[node name] isEqualToString:@"currentTime"]) currentTime = CCPDate([node stringValue]);
			else cachedUntil = CCPDate([node stringValue]);
		}
	}
}

- (void)processResult:(NSXMLDocument *)doc {
	NSXMLNode * root;
	NSArray * nodeList;
	
	root     = [doc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/*" error:&internalError];
	
	if (!internalError) data = [self processNodeList:nodeList];
}

- (void)processCCPError:(NSXMLDocument *)doc {
	NSXMLNode * root;
	NSXMLElement * node;
	NSArray * nodeList;
	NSInteger errorCode;
	
	root     = [doc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/error" error:&internalError];
	
	if ((!internalError) && ([nodeList count])) {
		node      = [nodeList objectAtIndex:0];
		errorCode = [[[node attributeForName:@"code"] stringValue] integerValue];
		CCPError  = [NSError errorWithDomain:EveAPIErrorDomain
										code:errorCode
									userInfo:[NSDictionary dictionaryWithObject:[node stringValue] forKey:NSLocalizedDescriptionKey]];
	}
	
}

- (NSDictionary *)processNodeList:(NSArray *)nodeList {
	NSXMLNode * node;
	NSXMLElement * element;
	NSMutableDictionary * mutableResult;
	NSDictionary * child;
	id value;
	NSString * key;
	NSUInteger i;

	i = 0;
	
	mutableResult = [NSMutableDictionary dictionary];
	
	for (node in nodeList) {
		if ([[node name] isEqualToString:@"rowset"]) {
			child   = [self processNodeList:[node children]];
			element = (NSXMLElement *) node;

			key   = [[element attributeForName:@"name"] stringValue];
			value = [child allValues];
		}
		else if ([[node name] isEqualToString:@"row"]) {
			element = (NSXMLElement *) node;
			
			value = [self processNodeList:[element attributes]];
			key   = [NSString stringWithFormat:kAttributeKey, i];
		}
		else if ([node childCount] > 1) {
			key   = [node name];
			value = [self processNodeList:[node children]];
		}
		else {
			key   = [node name];
			value = [node stringValue];
		}
		
		@try {
			[mutableResult setObject:value forKey:key];
		}
		@catch (id exception) {
			NSLog(@"\nKey: %@\nValue: %@\nException: %@", key, value, exception);
		}
		
		i++;
	}
	
	return mutableResult;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"{ EveAPIResult \n\tCurrent CCP Time: %@,\nCached until: %@,\t\nResult: %@,\t\n\tError: %@\n}",
						self.currentTime,
						self.cachedUntil,
						self.data,
						self.error];
}

@end
