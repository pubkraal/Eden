//
//  EveCorporation.h
//  Eden
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EveCorporation : NSObject <NSCoding> {
    NSString * name;
	NSString * corporationID;
	NSString * ticker;
}

@property (retain) NSString * name;
@property (retain) NSString * corporationID;
@property (retain) NSString * ticker;

- (id)initWithName:(NSString *)corpName andCorporationID:(NSString *)corpID;
+ (id)corporationWithName:(NSString *)corpName andCorporationID:(NSString *)corpID;

@end
