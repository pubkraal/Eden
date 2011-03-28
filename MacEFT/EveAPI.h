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

// For use of this lib look at http://code.google.com/p/json-framework/
#import "JSON.h"

typedef unsigned int uint;

@interface EveAPI : NSObject {
    
}

/**
 * Account calls.
 */
- (EveAPIResult *)listCharacters;
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
 */

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

/**
 * Misc
 */

/**
 * Server
 */

@end
