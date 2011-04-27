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
#import "EveAPIResult.h"
#import "EveDownload.h"

#define API_REQUIRED_FULL 1<<0;
#define API_REQUIRED_LIMITED 1<<1;
#define BASE_URL "https://api.eveonline.com"
#define BASE_URL_TEST "https://apitest.eveonline.com"

typedef unsigned int uint;

@interface EveAPI : EveDownload {

}

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
