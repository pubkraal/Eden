//
//  SQLBridge.h
//  MacEFT
//
//  Created by ugo pozo on 4/8/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface SQLBridge : NSObject {
@private
    sqlite3 * database;
	NSError * lastError;
}

@property (readonly) sqlite3 * database;
@property (retain) NSError * lastError;

- (id)initWithPath:(NSString *)dbPath error:(NSError **)error;



- (void)dealloc;


- (void)setErrorWithDesc:(NSString *)description andCode:(long)code;


@end
