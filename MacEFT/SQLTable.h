//
//  SQLTable.h
//  MacEFT
//
//  Created by ugo pozo on 4/24/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLView.h"

@class SQLBridge;

@interface SQLTable : SQLView {
@private
	NSString * numericPrimaryKey;
	NSArray * primaryKeys;
	
	NSDictionary * rowsByPK; 
}

@property (retain) NSString * numericPrimaryKey;
@property (retain) NSArray * primaryKeys;
@property (retain) NSDictionary * rowsByPK;

- (void)updateLookup;

- (NSArray *)keyForRow:(NSDictionary *)row;
- (NSArray *)keyForRowAtIndex:(NSUInteger)idx;
- (id)rowWithKey:(NSArray *)key;
- (NSUInteger)indexOfRowWithKey:(NSArray *)key;


- (NSDictionary *)foreignObjectForKey:(NSString *)key inRow:(NSDictionary *)row;
- (NSDictionary *)foreignObjectForKey:(NSString *)key inRowAtIndex:(NSUInteger)idx;

- (NSArray *)foreignObjectsInTable:(id)tableInfo usingColumn:(NSString *)otherKey forRow:(NSDictionary *)row;
- (NSArray *)foreignObjectsInTable:(id)tableInfo usingColumn:(NSString *)otherKey forRowAtIndex:(NSUInteger)idx;
- (NSArray *)foreignObjectsInTable:(id)tableInfo usingPrimaryKeyForRow:(NSDictionary *)row;
- (NSArray *)foreignObjectsInTable:(id)tableInfo usingPrimaryKeyForRowAtIndex:(NSUInteger)idx;

@end
