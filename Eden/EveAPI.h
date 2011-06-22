//
//  EveAPI.h
//  Eden
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

/**
 * Point of this is to fetch data from the Eve API provider and return the data
 * in a JSON like manner. If Objective-C supports such a scheme (Python
 * Dictionaries, where are you?).
 */

#import <Foundation/Foundation.h>
#import <stdarg.h>
#import "EveDownload.h"

#define API_REQUIRED_FULL 1<<0;
#define API_REQUIRED_LIMITED 1<<1;
#define BASE_URL "https://api.eveonline.com"
#define BASE_URL_TEST "https://apitest.eveonline.com"

#define EveAPIErrorDomain @"com.pleaseignore.Eden.APIError"
#define EveAPIBlockedDomain @"com.pleaseignore.Eden.BlockedAPIKeyError"
#define EveAPICachedDomain @"com.pleaseignore.Eden.CachedError"

#define EveAPICacheClearedNotification @"EveAPICacheClearedNotification"

#define EveAPICacheCallKey @"EveAPICacheCallKey"
#define EveAPICacheAccountKey @"EveAPICacheAccountKey"
#define EveAPICacheCharacterKey @"EveAPICacheCharacterKey"

@class EveCharacter;
@class EveAccount;
@class EveAPI;

@protocol APIDelegate <NSObject>

- (void)request:(EveAPI *)apiObj finishedWithErrors:(NSDictionary *)errors;

@optional

- (void)request:(EveAPI *)apiObj changedTotalDownloadSize:(NSNumber *)bytes;
- (void)request:(EveAPI *)apiObj changedDownloadedBytes:(NSNumber *)bytes;

@end

@interface EveAPI : NSObject <EveDownloadDelegate> {
@private
	EveCharacter * character;
	id <APIDelegate> delegate;
	NSMutableSet * lastCalls;
	NSMutableSet * currentDownloads;
	NSError * failedStart;
	
	NSMutableDictionary * temporaryData;

	// Filled when -retrieveAccountData is called
	NSArray * characterList;
}

@property (retain) EveCharacter * character;
@property (retain) NSMutableSet * lastCalls;
@property (retain) NSMutableSet * currentDownloads;
@property (retain) NSArray * characterList;
@property (retain) NSError * failedStart;

@property (assign) id <APIDelegate> delegate;

// We don't need an EveAPI stand-alone object running all the time so that
// we can call API functions from it. We should create them on the fly,
// as needed, input a EveCharacter object into it, and remove all the
// apiKey/characterID parameters from the methods (since they can be
// pulled from character.account.apiKey and character.characterID,
// respectively).
//
// Also, if we get the API to pull all the necessary data for the character
// at once, we should use fewer methods.

// Initialization

- (id)initWithCharacter:(EveCharacter *)character;
- (id)initWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey;
+ (id)requestWithCharacter:(EveCharacter *)character;
+ (id)requestWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey;

// Methods starting/stopping requests

- (void)retrievePortraitList;
- (void)retrievePortrait;
- (void)retrieveAccountData;
- (void)retrieveCharacterData;
- (void)cancelRequests;
- (void)startDownload:(EveDownload *)download;

// Methods returning relevant data for creating requests

+ (NSString *)URLForKey:(NSString *)key, ...;
+ (NSDictionary *)URLListForKeys:(NSArray *)keys;
+ (NSDictionary *)URLDict;
- (NSDictionary *)accountInfoForPost;
- (NSDictionary *)characterInfoForPost;

// Methods for handling caching

+ (NSMutableDictionary *)cache;
- (void)cacheCall:(NSString *)callKey withXML:(NSXMLDocument *)xmlDoc;
+ (void)cleanCache:(NSTimer *)timer;
+ (NSSet *)doNotBroadcast;

// Methods for specific calls

- (void)characterListWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)accountStatusWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)portraitListWithData:(NSData *)data forCharID:(NSString *)charID error:(NSError **)error;
- (void)portraitWithData:(NSData *)data error:(NSError **)error;
- (void)characterSheetWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)corporationSheetWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)skillInTrainingWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)skillQueueWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;

- (void)processErrorWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)blockAPIKey;


@end

inline NSDate * CCPDate(NSString *);
inline NSDictionary * NSDictionaryFromAttributes(NSXMLElement *);
inline NSDictionary * NSDictionaryFromChildren(NSXMLElement *);

NSDictionary * EveMakeCacheKey(NSString *, NSString *, NSString *);