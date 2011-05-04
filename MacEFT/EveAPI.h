//
//  EveAPI.h
//  MacEFT
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

#define EveAPIErrorDomain @"EVE API Error"

@class EveAPIResult;
@class EveCharacter;
@class EveAccount;

typedef unsigned int uint;

@class EveAPI;

@protocol APIDelegate <NSObject>

- (void)request:(EveAPI *)apiObj finishedWithErrors:(NSDictionary *)errors;




@end

@interface EveAPI : NSObject <EveDownloadDelegate> {
@private
	EveCharacter * character;
	id <APIDelegate> delegate;
	NSSet * lastCalls;

	// Filled when -retrieveAccountData is called
	NSArray * characterList;
}

@property (retain) EveCharacter * character;
@property (retain) NSSet * lastCalls;
@property (retain) NSArray * characterList;

@property (assign) id <APIDelegate> delegate;

// We don't need an EveAPI stand-alone object running all the time so that
// we can call API functions from it. We should create them on the fly,
// as needed, input a EveCharacter object into it, and remove all the
// apiKey/characterID parameters from the methods (since they can be
// pulled from character.account.apiKey and character.characterID,
// respectively).
//
// Also, if we get the API to pull all the necessary data for the character
// at once, we should use fewer methods, such as:

- (id)initWithCharacater:(EveCharacter *)character;
- (id)initWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey;
+ (id)requestWithCharacter:(EveCharacter *)character;
+ (id)requestWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey;
+ (NSString *)URLForKey:(NSString *)key, ...;
+ (NSDictionary *)URLListForKeys:(NSArray *)keys;

- (void)retrievePortraitList;
- (void)retrieveAccountData;
- (void)retrieveLimitedData;
- (void)retrieveFullData;
- (void)retrieveAssets;
- (void)retrieveMarketOrders;

- (NSDictionary *)accountInfoForPost;
- (NSDictionary *)characterInfoForPost;


// Methods for specific calls

- (void)characterListWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error;
- (void)portraitListWithData:(NSData *)data forCharID:(NSString *)charID error:(NSError **)error;


// There may be a little redundance here, but we can figure it out later.
// Also, I thought about that idea of making EveAPI a subclass of
// EveDownload, but their interface don't mesh well. As we have fewer
// "retriever" methods, and if we have the all the relevant URLs in a plist,
// it's easier to create a EveDownload for each method, each with several URLs,
// and set the EveAPI itself as its delegate.


/**
 * Utility calls
 */
- (NSString *)buildRequestURL:(NSString *)group method:(NSString *)method;

/**
 * Account calls.
 */
- (EveAPIResult *)listCharacters:(uint)userID apiKey:(NSString*)apiKey;
- (EveAPIResult *)accountStatus:(uint)userID apiKey:(NSString*)apiKey;

/**
 * Character calls
 */
- (EveAPIResult *)accountBalances:(uint)userID apiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)assetList:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
// Omitted "Calender Event Attendees"
- (EveAPIResult *)contactList:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)contactNotifications:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)factionalWarfareStatus:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)industryJobs:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)killLog:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
// Omittted - (EveAPIResult *)mailBodies:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)mailingLists:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)mailMessages:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)marketOrders:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)medals:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)notifications:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
// Omitted - (EveAPIResult *)notificationTexts:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)research:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)skillInTraining:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)skillQueue:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)standings:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)upcomingCalendarEvents:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)walletJournal:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)walletTransactions:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;

/**
 * Corporation calls
 * 
 * All these calls are prefixed with "corp" since they have the same goddamn
 * name as the character counterparts. :ccp:
 */
- (EveAPIResult *)corpAccountBalances:(uint)userID apiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpAssetList:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpContactList:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpContainerLog:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corporationSheet:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpFactionalWarfareStatus:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpIndustryJobs:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpKillLog:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpMarketOrders:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpMedals:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpMemberMedals:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpMemberSecurity:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpMemberSecurityLog:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpMemberTracking:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpOutpostList:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpShareholders:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpStandings:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpStarbaseDetail:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpStarbaseList:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpWalletJournal:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;
- (EveAPIResult *)corpWalletTransactions:(uint)userID apiKeyapiKey:(NSString*)apiKey characterID:(uint)characterID;

/**
 * Eve
 */
- (EveAPIResult *)allianceList;
- (EveAPIResult *)certificateTree;
- (EveAPIResult *)characterID;
- (EveAPIResult *)characterInfo;
- (EveAPIResult *)characterName;
- (EveAPIResult *)conquerableStationList;
- (EveAPIResult *)errorList;
- (EveAPIResult *)factionalWarfareStatus;
- (EveAPIResult *)factionalWarfareTop100Stats;
- (EveAPIResult *)refTypesList;
- (EveAPIResult *)skillTree;

/**
 * Map
 */
- (EveAPIResult *)factionalWarfareSystem;
- (EveAPIResult *)jumps;
- (EveAPIResult *)kills;
- (EveAPIResult *)sovereignty;
// This shouldn't return anything, please review
// http://www.eveonline.com/ingameboard.asp?a=topic&threadID=1228297
- (EveAPIResult *)sovereigntyStatus;

/**
 * Server
 */
- (EveAPIResult *)serverStatus;

@end
