//
//  SQLView.h
//  MacEFT
//
//  Created by ugo pozo on 4/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLBridge.h"

@class SQLBridge;

@interface SQLView : NSObject {
@private
    NSString * tableName;
	SQLBridge * bridge;
	
	NSArray * columns;
	NSDictionary * rows;
}

@property (readonly) NSString * tableName;
@property (readonly) SQLBridge * bridge;

@property (retain) NSArray * columns;
@property (retain) NSDictionary * rows;

- (id)initWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName;
+ (SQLView *) viewWithBridge:(SQLBridge *)aBridge andTableName:(NSString *)aTableName;

- (BOOL)loadValues;

@end
