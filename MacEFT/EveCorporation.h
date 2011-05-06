//
//  EveCorporation.h
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EveCorporation : NSObject <NSCoding> {
    NSString * name;
	NSString * corporationID;
}

@property (retain) NSString * name;
@property (retain) NSString * corporationID;

- (id)initWithName:(NSString *)corpName andCorporationID:(NSString *)corpID;
+ (id)corporationWithName:(NSString *)corpName andCorporationID:(NSString *)corpID;

@end
