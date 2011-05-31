//
//  Account.h
//  Eden
//
//  Created by John Kraal on 3/26/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EveAccount : NSObject {
@private
	NSString * userID;
	NSString * apiKey;
	BOOL isFullAPI;

	NSDictionary * characters;
    
}

@property (retain) NSString * userID, * apiKey;
@property (retain) NSDictionary * characters;

@property (assign) BOOL isFullAPI;

@end
