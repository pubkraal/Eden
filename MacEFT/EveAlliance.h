//
//  EveAlliance.h
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EveAlliance : NSObject <NSCoding> {
   NSString * allianceID;
   NSString * name;
}

@property (retain) NSString * allianceID, * name;

- (id)initWithName:(NSString *)allName andAllianceID:(NSString *)allID;
+ (id)allianceWithName:(NSString *)allName andAllianceID:(NSString *)allID;

@end
