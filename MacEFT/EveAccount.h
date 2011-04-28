//
//  Account.h
//  MacEFT
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
    
}

@property (retain) NSString * userID, * apiKey;
@property (assign) BOOL isFullAPI;

@end
