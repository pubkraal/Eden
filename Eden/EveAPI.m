//
//	EveAPI.m
//	Eden
//
//	Created by John Kraal on 3/27/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import <time.h>

#import "EveAPI.h"
#import "EveCharacter.h"
#import "EveCorporation.h"
#import "EveAlliance.h"
#import "EveSkill.h"
#import "EveAPIResult.h"

@implementation EveAPI 

@synthesize character, characterList, delegate, lastCalls, currentDownloads, failedStart;

- (id)initWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey {
	
	if ((self = [super init])) {
		self.character        = [EveCharacter characterWithAccountID:accountID andAPIKey:APIKey];
		self.lastCalls        = [NSMutableSet set];
		self.currentDownloads = [NSMutableSet set];
		self.characterList    = nil;
		self.failedStart      = nil;
		
		temporaryData = nil;
	}

	return self;
}

- (id)initWithCharacter:(EveCharacter *)theChar {
	if ((self = [super init])) {
		self.character = theChar;
		self.lastCalls = [NSMutableSet set];
		self.characterList = nil;
		self.currentDownloads = [NSMutableSet set];
		
	}

	return self;
}

+ (id)requestWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey {
	return [[[self alloc] initWithAccountID:accountID andAPIKey:APIKey] autorelease];
}

+ (id)requestWithCharacter:(EveCharacter *)theChar {
	return [[[self alloc] initWithCharacter:theChar] autorelease];
}

- (void)dealloc {
	self.character	= nil;
	self.lastCalls	= nil;
	self.characterList = nil;
	self.currentDownloads = nil;
	self.failedStart = nil;
	
	if (temporaryData) {
		[temporaryData release];
		temporaryData = nil;
	}
	
	[super dealloc];
}

- (void)retrieveAccountData {
	EveDownload * download;
	NSDictionary * URLList;
	NSArray * calls;
	NSString * call;

	calls = [NSArray arrayWithObjects:
						@"CharacterList",
						@"AccountStatus",
						nil];
	
	URLList	 = [[self class] URLListForKeys:calls];
	download = [EveDownload downloadWithURLList:URLList];

	for (call in calls) {
		[download setPostBodyToDictionary:[self accountInfoForPost] forKey:call];
	}

	self.lastCalls = [NSMutableSet setWithArray:calls];

	[self startDownload:download];
}

- (void)retrievePortraitList {
	EveDownload * download;
	EveCharacter * pChar;
	NSMutableDictionary * URLList;

	URLList = [NSMutableDictionary dictionary];

	for (pChar in self.characterList) {
		[URLList setObject:[[self class] URLForKey:@"Portrait 1024", pChar.characterID] forKey:[NSString stringWithFormat:@"PortraitList %@", pChar.characterID]];
	}
	
	download = [EveDownload downloadWithURLList:URLList];

	self.lastCalls = [NSMutableSet setWithObject:@"PortraitList"];

	[self startDownload:download];
}

- (void)retrievePortrait {
	EveDownload * download;
	NSDictionary * URLList;
	
	URLList  = [NSDictionary dictionaryWithObject:[[self class] URLForKey:@"Portrait 1024", self.character.characterID] forKey:@"Portrait"];
	download = [EveDownload downloadWithURLList:URLList];
	
	self.lastCalls = [NSMutableSet setWithObject:@"Portrait"];
	
	[self startDownload:download];
}

- (void)retrieveCharacterData {
	EveDownload * download;
	NSMutableArray * calls;
	NSDictionary * URLList;
	NSString * call;

	calls = [NSMutableArray arrayWithObjects:
						@"CharacterSheet",
						@"SkillInTraining",
						@"SkillQueue",
						@"CorporationSheet",
						nil];
	
	if (self.character.fullAPI) {
		// This thing is not ready, let's not piss off CCP.
		
		/*[calls addObjectsFromArray:[NSArray arrayWithObjects:
						@"MarketOrders",
						nil]];
		*/
	}
	
	URLList	 = [[self class] URLListForKeys:calls];
	download = [EveDownload downloadWithURLList:URLList];

	for (call in calls) {
		[download setPostBodyToDictionary:[self characterInfoForPost] forKey:call];
	}

	self.lastCalls = [NSMutableSet setWithArray:calls];

	[self startDownload:download];
}

- (void)startDownload:(EveDownload *)download {
	NSUserDefaults * prefs;
	NSDictionary * thisPair, * blockedPair, * errorInfo, * cacheKey;
	NSArray * blockedKeys, * callKeys;
	NSError * error;
	NSString * callKey;
	NSData * cachedData;
	BOOL canDownload;
	
	prefs       = [NSUserDefaults standardUserDefaults];
	blockedKeys = [prefs arrayForKey:@"blockedAPIKeys"];
	canDownload = YES;
	thisPair    = [NSDictionary dictionaryWithObjectsAndKeys:
								self.character.accountID, @"userID",
								self.character.APIKey, @"APIKey",
								nil];
	
	for (blockedPair in blockedKeys) {
		if ([blockedPair isEqualToDictionary:thisPair]) {
			errorInfo   = [NSDictionary dictionaryWithObject:@"The Account ID/API Key pair you are trying to use has been blocked." forKey:NSLocalizedDescriptionKey];
			error       = [NSError errorWithDomain:EveAPIBlockedDomain code:203 userInfo:errorInfo];
			canDownload = NO;
			
			break;
		}
	}
	
	if (canDownload) {
		if (temporaryData) [temporaryData release];
		temporaryData = [[NSMutableDictionary alloc] init];
		
		callKeys = [download.downloads allKeys];
		
		for (callKey in callKeys) {
			cacheKey = EveMakeCacheKey(callKey, character.accountID, character.characterID);
			
			if ((cachedData = [[[self class] cache] objectForKey:cacheKey])) {
				//[download useCachedData:cachedData forKey:callKey];
				[download cancelDownloadForKey:callKey];
				
				if ([lastCalls containsObject:callKey]) [lastCalls removeObject:callKey];
			}
		} 
		
		if ([download.downloads count] > 0) {
			download.delegate = self;
			[download addTotalObserver:self];

			[self.currentDownloads addObject:download];

			[download start];
		}
		else {
			errorInfo   = [NSDictionary dictionaryWithObject:@"All possible downloads are already cached." forKey:NSLocalizedDescriptionKey];
			error       = [NSError errorWithDomain:EveAPICachedDomain code:-1 userInfo:errorInfo];
			
			self.failedStart = error;
		}
	}
	else self.failedStart = error;
}

- (void)cancelRequests {
	EveDownload * download;
	
	for (download in self.currentDownloads) {
		[download cancel];
		[download removeTotalObserver:self];
	}
	
	self.currentDownloads = [NSMutableSet set];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:[EveDownload class]]) {
		if ([keyPath isEqualToString:@"expectedLength"]) {
			if ([self.delegate respondsToSelector:@selector(request:changedTotalDownloadSize:)]) {
				[self.delegate request:self changedTotalDownloadSize:(NSNumber *) [change objectForKey:NSKeyValueChangeNewKey]];
			}
		}
		else if ([keyPath isEqualToString:@"receivedLength"]) {
			if ([self.delegate respondsToSelector:@selector(request:changedDownloadedBytes:)]) {
				[self.delegate request:self changedDownloadedBytes:(NSNumber *) [change objectForKey:NSKeyValueChangeNewKey]];
			}
		}
	}
}


- (NSDictionary *)accountInfoForPost {
	return [NSDictionary dictionaryWithObjectsAndKeys:
							character.accountID, @"userID",
							character.APIKey, @"apiKey", nil];
}

- (NSDictionary *)characterInfoForPost {
	return [NSDictionary dictionaryWithObjectsAndKeys:
							character.accountID, @"userID",
							character.APIKey, @"apiKey",
							character.characterID, @"characterID",
							nil];
}


+ (NSString *)URLForKey:(NSString *)key, ... {
	NSString * urlStr;
	va_list args;

	va_start(args, key);
	
	urlStr = [[NSString alloc] initWithFormat:[[self URLDict] objectForKey:key] arguments:args];

	[urlStr autorelease];

	va_end(args);

	return urlStr;
}

+ (NSDictionary *)URLListForKeys:(NSArray *)keys {
	NSArray * valueList;
	
	valueList = [[self URLDict] objectsForKeys:keys notFoundMarker:[NSNull null]];

	return [NSDictionary dictionaryWithObjects:valueList forKeys:keys];
	
}

+ (NSDictionary *)URLDict {
	static NSDictionary * URLDict = nil;
	
	if (!URLDict) {
		URLDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EveURLs" ofType:@"plist"]];
	}
	
	return URLDict;
}

+ (NSMutableDictionary *)cache {
	static NSMutableDictionary * cache = nil;
	
	if (!cache) cache = [[NSMutableDictionary alloc] init];
	
	return cache;
}

- (void)cacheCall:(NSString *)callKey withResult:(EveAPIResult *)result {
	static NSTimeInterval interval = 5.0;
	NSDictionary * key;
	NSDate * trueCachedUntil;
	NSTimeInterval offset;
	
	key = EveMakeCacheKey(callKey, character.accountID, character.characterID);
	
	if (![[[self class] cache] objectForKey:key]) {

		/*
		 * Compensating possible discrepancies between user time and CCP time
		 * 
		 * Timelines:
		 *
		 * ... --[now]--[<- offset ->]--[currentTime]--- ... ---[trueCachedUntil]--[<- offset ->]--[cachedUntil]--- ...
		 *
		 * or:
		 *
		 * ... --[currentTime]--[<- offset ->]--[now]--- ... ---[cachedUntil]--[<- offset ->]--[trueCachedUntil]--- ...
		 *
		 * Assuming currentTime is ahead of now, offset is positive. So, we have to
		 * *subtract* offset from cachedUntil to get trueCachedUntil. If now is
		 * ahead of currentTime, offset is negative and we have to *add* offset to
		 * cachedUntil. Hence the minus signal.
		 */

		offset          = [result.currentTime timeIntervalSinceNow];
		trueCachedUntil = [result.cachedUntil dateByAddingTimeInterval:-offset];

		//[NSTimer scheduledTimerWithTimeInterval:interval
		[NSTimer scheduledTimerWithTimeInterval:[trueCachedUntil timeIntervalSinceNow]
										 target:[self class]
									   selector:@selector(cleanCache:)
									   userInfo:key
										repeats:NO];
		
		interval += 2.0;
		
		[[[self class] cache] setObject:result.rawData forKey:key];
	}
}

+ (void)cleanCache:(NSTimer *)timer {
	NSNotificationCenter * nc;
	NSDictionary * key;
	
	nc    = [NSNotificationCenter defaultCenter];
	key   = [timer userInfo];
	
	[[self cache] removeObjectForKey:key];

	if (![[self doNotBroadcast] containsObject:[key objectForKey:EveAPICacheCallKey]]) {
		[nc postNotificationName:EveAPICacheClearedNotification object:self userInfo:key];
	}
	
	[timer invalidate];
}

+ (NSSet *)doNotBroadcast {
	static NSSet * doNotBroadcast = nil;
	
	if (!doNotBroadcast) {
		doNotBroadcast = [[NSSet alloc] initWithObjects:@"CharacterList", @"AccountStatus", nil];
	}
	
	return doNotBroadcast;
}

- (void)characterListWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error{
	NSXMLElement * root, * node;
	NSMutableArray * chars;
	EveCharacter * newChar;
	EveCorporation * newCorp;
	NSArray * nodeList;

	root	 = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/rowset/row" error:error];

	if (!(*error)) {
		chars = [NSMutableArray array];

		for (node in nodeList) {
			newChar = [EveCharacter characterWithCharacter:character];
			newCorp = [EveCorporation corporationWithName:[[node attributeForName:@"corporationName"] stringValue]
										 andCorporationID:[[node attributeForName:@"corporationID"] stringValue]];
			
			newChar.name		  = [[node attributeForName:@"name"] stringValue];
			newChar.characterID	  = [[node attributeForName:@"characterID"] stringValue];
			newChar.corporation	  = newCorp;

			[chars addObject:newChar];
		}

		self.characterList = [NSArray arrayWithArray:chars];
	}
}

- (void)accountStatusWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSArray * nodeList;
	NSXMLElement * errorElement;

	nodeList = [[xmlDoc rootElement] nodesForXPath:@"/eveapi/error" error:error];

	if (!(*error)) {
		self.character.fullAPI = ![nodeList count];
		
		if (!self.character.fullAPI) {
			// Removes the error node so that it doesn't get caught by the
			// didFinishDownload: selector.
			
			errorElement = [nodeList objectAtIndex:0];
			
			[(NSXMLElement *) [errorElement parent] removeChildAtIndex:[errorElement index]];
		}
	}
}

- (void)skillInTrainingWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSXMLElement * root;
	NSArray * nodeList;
	NSDictionary * trainingData;
	NSTimeInterval skillTimeOffset;
	
	root	 = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result" error:error];
	
	if (!(*error)) {
		if ([nodeList count] > 0) {
			trainingData = NSDictionaryFromChildren([nodeList objectAtIndex:0]);
		}
		else trainingData = [NSDictionary dictionary];
		
		if ([[trainingData objectForKey:@"skillInTraining"] boolValue]) {
			skillTimeOffset = [CCPDate([trainingData objectForKey:@"currentTQTime"]) timeIntervalSinceNow];
			self.character.skillTimeOffset = [NSNumber numberWithDouble:skillTimeOffset];
			
			[temporaryData setObject:trainingData forKey:@"SkillInTraining"];
		}
	}
}

- (void)skillQueueWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSXMLElement * root, * node;
	NSArray * nodeList;
	NSDictionary * attributes;
	NSMutableArray * queue;
	
	root     = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/rowset/row" error:error];
	
	if (!(*error)) {
		queue = [NSMutableArray array];
		
		for (node in nodeList) {
			attributes = NSDictionaryFromAttributes(node);
			
			[queue addObject:attributes];
		}
		
		[temporaryData setObject:queue forKey:@"SkillQueue"];
	}
}

- (void)characterSheetWithResult:(EveAPIResult *)result {
	NSNumberFormatter * formatter;
	NSLocale * CCPLocale;
	NSString * key;
	NSDictionary * skillInfo;
	EveSkill * skill;
	NSUInteger count;
	long double totalTime;
	time_t start;
	NSSet * specialKeys;

	// These keys require special processing, which will be done afterwards
	specialKeys = [NSSet setWithObjects:@"DoB", @"attributes", @"corporationName", @"corporationID",
	 									@"allianceName", @"allianceID", @"cloneSkillPoints",
										@"balance", @"skills", nil];
	NSLog(@"%@", specialKeys);

	// Simple string keys processing
	for (key in [result.data allKeys]) {
		if (![specialKeys containsObject:key]) {
			@try {
				[self.character setValue:[result.data objectForKey:key] forKeyPath:key];
			}
			@catch (NSException * exception) {
				if (![[exception name] isEqualToString:@"NSUnknownKeyException"]) [exception raise];
			}
		}
	}
	
	// Setting up formatter
	formatter = [[NSNumberFormatter alloc] init];
	CCPLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	
	[formatter setLocale:CCPLocale];
	
	// Special key: DoB
	self.character.dateOfBirth = CCPDate([result.data objectForKey:@"DoB"]);
	
	// Special key: attributes
	for (key in [[result.data objectForKey:@"attributes"] allKeys]) {
		[self.character setValue:[formatter numberFromString:[[result.data objectForKey:@"attributes"] objectForKey:key]] forKey:key];
	}
	
	// Special keys: corporationName, corporationID
	self.character.corporation = [EveCorporation corporationWithName:[result.data objectForKey:@"corporationName"] andCorporationID:[result.data objectForKey:@"corporationID"]];
	
	// Special keys: allianceName, allianceID
	self.character.alliance = [EveAlliance allianceWithName:[result.data objectForKey:@"allianceName"] andAllianceID:[result.data objectForKey:@"allianceID"]];

	// Special key: cloneSkillPoints
	self.character.cloneSkillPoints = [formatter numberFromString:[result.data objectForKey:@"cloneSkillPoints"]];
	
	// Special key: balance
	self.character.balance = [formatter numberFromString:[result.data objectForKey:@"balance"]];
	
	// Special key: rowset name="skills"
	totalTime = 0.0L;
	count = [[result.data objectForKey:@"skills"] count];

	for (skillInfo in [result.data objectForKey:@"skills"]) {
		if ([[skillInfo objectForKey:@"published"] integerValue]) {
			start = time(NULL);
			
			key   = [skillInfo objectForKey:@"typeID"];
			skill = [self.character.skills objectForKey:key];
			
			if (!skill) {
				skill = [EveSkill skillWithSkillID:key];
				[self.character.skills setObject:skill forKey:key];
			}
			
			skill.skillPoints = [formatter numberFromString:[skillInfo objectForKey:@"skillpoints"]];
			skill.level		  = [formatter numberFromString:[skillInfo objectForKey:@"level"]];
			skill.character	  = self.character;
			
			totalTime += (long double) time(NULL) - (long double) start;
		}
	}

	NSLog(@"Skills loaded: %lu skills, %Lgs total time, %Lgs average time.", count, totalTime, totalTime / (long double) count);
	
	[formatter release];
}



- (void)corporationSheetWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSXMLElement * root, * node;
	NSArray * nodeList;
	
	root     = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/ticker" error:error];
	
	if (!(*error)) {
		if ([nodeList count] > 0) {
			node = [nodeList objectAtIndex:0];
			
			[temporaryData setObject:[node stringValue] forKey:@"corpTicker"];
		}
	}
}

- (void)portraitListWithData:(NSData *)data forCharID:(NSString *)charID error:(NSError **)error {
	EveCharacter * theChar;
	BOOL charFound;

	charFound = NO;

	for (theChar in self.characterList) {
		if ([theChar.characterID isEqualToString:charID]) {
			charFound = YES;
			break;
		}
	}

	if (charFound) {
		theChar.portraitData = data;

	}
	else if (error) {
		(*error) = [NSError errorWithDomain:EveAPIErrorDomain
									   code:-1
								   userInfo:[NSDictionary dictionaryWithObject:@"Portrait could not be found" forKey:NSLocalizedDescriptionKey]];
	}

	
}

- (void)portraitWithData:(NSData *)data error:(NSError **)error {
	self.character.portraitData = data;
}

- (void)processErrorWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error  {
	NSError * authError;
	NSXMLElement * errorNode;
	NSArray * errorList;
	NSInteger errorCode;
	
	errorList = [[xmlDoc rootElement] nodesForXPath:@"/eveapi/error" error:&authError];

	if (!authError && [errorList count]) {
		errorNode = [errorList objectAtIndex:0];
		errorCode = [[[errorNode attributeForName:@"code"] stringValue] integerValue];
		authError = [NSError errorWithDomain:EveAPIErrorDomain
										code:errorCode
									userInfo:[NSDictionary dictionaryWithObject:[errorNode stringValue] forKey:NSLocalizedDescriptionKey]];

		if (errorCode == 203) [self blockAPIKey]; // Authentication failure

		*error = authError;
	}
	
}

- (void)didFinishDownload:(EveDownload *)download forKey:(NSString *)key withData:(NSData *)data error:(NSError *)error {
	NSXMLDocument * xmlDoc;
	NSError * processingError;
	EveAPIResult * result;
	
#ifdef DEBUG_XML
	NSString * xmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@", xmlStr);
	[xmlStr release];
#endif

	if (error) {
		NSLog(@"%@", error);
		return;
	}

	xmlDoc          = nil;
	result          = [EveAPIResult resultWithData:data];
	processingError = result.error;

#ifdef DEBUG_XML
	NSLog(@"%@", result);
#endif

	// API call to get portraits for a character list
	if ([key hasPrefix:@"PortraitList"]) {
		processingError = nil;
		
		[self portraitListWithData:data
						 forCharID:[[key componentsSeparatedByString:@" "] objectAtIndex:1]
							 error:&processingError];
	}
	
	// API call to reload the character portrait
	else if ([key isEqualToString:@"Portrait"]) {
		processingError = nil;

		[self portraitWithData:data error:&processingError];
	}

	// API call to Character List
	if ([key isEqualToString:@"CharacterList"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processingError];

		if (!processingError) [self characterListWithXML:xmlDoc error:&processingError];

	}

	// API call to verify if it's a full API key or not
	else if ([key isEqualToString:@"AccountStatus"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processingError];

		if (!processingError) [self accountStatusWithXML:xmlDoc error:&processingError];
	}

	// API call to get the character sheet
	else if ([key isEqualToString:@"CharacterSheet"]) {
		if (!processingError) [self characterSheetWithResult:result];
	}
	
	// API call to get the current training skill
	else if ([key isEqualToString:@"SkillInTraining"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processingError];

		if (!processingError) [self skillInTrainingWithXML:xmlDoc error:&processingError];
	}

	// API call to get the training queue
	else if ([key isEqualToString:@"SkillQueue"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processingError];

		if (!processingError) [self skillQueueWithXML:xmlDoc error:&processingError];
	}

	// API call to get the corporation sheet
	else if ([key isEqualToString:@"CorporationSheet"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processingError];

		if (!processingError) [self corporationSheetWithXML:xmlDoc error:&processingError];
	}
	
	if (xmlDoc) {
		[self processErrorWithXML:xmlDoc error:&processingError];
		//[self cacheCall:key withXML:xmlDoc];
		
		[xmlDoc release];
	}
	
	if (result.data) [self cacheCall:key withResult:result];

	if (processingError) [[download.downloads objectForKey:key] setError:processingError];
}

- (void)didFinishDownload:(EveDownload *)download withResults:(NSDictionary *)results {
	__block NSMutableDictionary * errors;
	
	[self.currentDownloads removeObject:download];
	
	errors = [NSMutableDictionary dictionary];

	[results enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSDictionary * obj, BOOL * stop) {
		if ([obj objectForKey:@"error"] != [NSNull null]) [errors setObject:[obj objectForKey:@"error"] forKey:key];
	}];
	
	[download removeTotalObserver:self];
	
	if ([self.lastCalls containsObject:@"SkillInTraining"]) [self.character consolidateSkillInTrainingWithDictionary:[temporaryData objectForKey:@"SkillInTraining"]];
	if ([self.lastCalls containsObject:@"SkillQueue"]) [self.character consolidateSkillQueueWithArray:[temporaryData objectForKey:@"SkillQueue"]];
	if ([self.lastCalls containsObject:@"CorporationSheet"] && [temporaryData objectForKey:@"corpTicker"]) self.character.corporation.ticker = [temporaryData objectForKey:@"corpTicker"];
	
	[self.delegate request:self finishedWithErrors:[NSDictionary dictionaryWithDictionary:errors]];

}

- (void)blockAPIKey {
	NSMutableArray * blockedKeys;
	NSDictionary * blockDict, * cursor;
	NSUserDefaults * prefs;
	BOOL alreadyBlocked;
	
	prefs          = [NSUserDefaults standardUserDefaults];
	alreadyBlocked = NO;
	blockDict      = [NSDictionary dictionaryWithObjectsAndKeys:
								self.character.accountID, @"userID",
								self.character.APIKey, @"APIKey",
								nil];
	
	@synchronized(prefs) {
		blockedKeys = [NSMutableArray arrayWithArray:[prefs arrayForKey:@"blockedAPIKeys"]];

		for (cursor in blockedKeys) {
			if ([cursor isEqualToDictionary:blockDict]) {
				alreadyBlocked = YES;
				break;
			}
		}		

		if (!alreadyBlocked) {
			[blockedKeys addObject:blockDict];

			[prefs setObject:blockedKeys forKey:@"blockedAPIKeys"];
		}
	}
}



@end

NSDate * CCPDate(NSString * date) {
	// All times returned by CCP are GMT, so...
	
	return [NSDate dateWithString:[date stringByAppendingString:@" +0000"]];
}

NSDictionary * NSDictionaryFromAttributes(NSXMLElement * node) {
	NSArray * attributes;
	NSXMLNode * attr;
	NSMutableDictionary * dict;
	
	attributes = [node attributes];
	dict       = [NSMutableDictionary dictionary];
			
	if (attributes) {
		for (attr in attributes) {
			[dict setObject:[attr stringValue] forKey:[attr name]];
		}
	}
	
	return [NSDictionary dictionaryWithDictionary:dict];
}

NSDictionary * NSDictionaryFromChildren(NSXMLElement * node) {
	NSXMLNode * child;
	NSMutableDictionary * dict;
	
	dict = [NSMutableDictionary dictionary];
	
	for (child in [node children]) {
		[dict setObject:[child stringValue] forKey:[child name]];
	}
	
	return [NSDictionary dictionaryWithDictionary:dict];
}

NSDictionary * EveMakeCacheKey(NSString * callName, NSString * accountID, NSString * characterID) {
	id charID;
	
	charID = (characterID) ? characterID : [NSNull null];
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
					callName, EveAPICacheCallKey,
					accountID, EveAPICacheAccountKey,
					charID, EveAPICacheCharacterKey, nil];
}