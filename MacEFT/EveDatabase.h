//
//	EveDatabase.h
//	MacEFT
//
//	Created by ugo pozo on 5/4/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLBridge.h"

@interface EveDatabase : NSObject <SQLBridgeDelegate> {
@private
	
}


+ (SQLBridge *)sharedBridge;
+ (EveDatabase *)sharedDatabase;
+ (NSError *)initError;

@end

@interface EveTable : SQLTable {

}

@end
