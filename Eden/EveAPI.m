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
#import "EveAPIResult.h"
#import "EveCorporation.h"
#import "EveAlliance.h"
#import "EveSkill.h"

NSDictionary * URLDict = nil;

@implementation EveAPI 

@synthesize character, characterList, delegate, lastCalls, currentDownloads;

- (id)initWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey {
	
	if ((self = [super init])) {
		self.character	= [EveCharacter characterWithAccountID:accountID andAPIKey:APIKey];
		self.lastCalls	= [NSSet set];
		self.characterList = nil;
		self.currentDownloads = [NSMutableSet set];
		
		temporaryData = nil;
	}

	return self;
}

- (id)initWithCharacter:(EveCharacter *)theChar {
	if ((self = [super init])) {
		self.character = theChar;
		self.lastCalls = [NSSet set];
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
	
	if (temporaryData) [temporaryData release];
	
	[super dealloc];
}

- (EveDownload *)downloadWithURLList:(NSDictionary *)URLList {
	EveDownload * download;
	
	download = [EveDownload downloadWithURLList:URLList];
	download.delegate = self;
	[download addTotalObserver:self];
	
	[self.currentDownloads addObject:download];
	
	temporaryData = [[NSMutableDictionary alloc] init];
	
	return download;
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
	download = [self downloadWithURLList:URLList];

	for (call in calls) {
		[download setPostBodyToDictionary:[self accountInfoForPost] forKey:call];
	}

	self.lastCalls = [NSSet setWithArray:calls];

	[download start];
}

- (void)retrievePortraitList {
	EveDownload * download;
	EveCharacter * pChar;
	NSMutableDictionary * URLList;

	URLList = [NSMutableDictionary dictionary];

	for (pChar in self.characterList) {
		[URLList setObject:[[self class] URLForKey:@"Portrait 1024", pChar.characterID] forKey:[NSString stringWithFormat:@"PortraitList %@", pChar.characterID]];
	}
	
	download = [self downloadWithURLList:URLList];

	self.lastCalls = [NSSet setWithObject:@"PortraitList"];

	[download start];
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
	download = [self downloadWithURLList:URLList];

	for (call in calls) {
		[download setPostBodyToDictionary:[self characterInfoForPost] forKey:call];
	}

	self.lastCalls = [NSSet setWithArray:calls];

	[download start];
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
	
	if (!URLDict) {
		URLDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EveURLs" ofType:@"plist"]];
	}
	
	urlStr = [[NSString alloc] initWithFormat:[URLDict objectForKey:key] arguments:args];

	[urlStr autorelease];

	va_end(args);

	return urlStr;
}

+ (NSDictionary *)URLListForKeys:(NSArray *)keys {
	NSArray * valueList;
	
	if (!URLDict) {
		URLDict = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EveURLs" ofType:@"plist"]];
	}

	valueList = [URLDict objectsForKeys:keys notFoundMarker:[NSNull null]];

	return [NSDictionary dictionaryWithObjects:valueList forKeys:keys];
	
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
	NSXMLElement * root, * node;
	NSArray * nodeList;
	NSMutableDictionary * trainingData;
	NSTimeInterval skillTimeOffset;
	
	root	 = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/*" error:error];
	
	if (!(*error)) {
		trainingData = [NSMutableDictionary dictionary];
		
		for (node in nodeList) {
			[trainingData setObject:[node stringValue] forKey:[node name]];
		}
		
		if ([[trainingData objectForKey:@"skillInTraining"] boolValue]) {
			skillTimeOffset = [CCPDate([trainingData objectForKey:@"currentTQTime"]) timeIntervalSinceDate:[NSDate date]];
			self.character.skillTimeOffset = [NSNumber numberWithDouble:skillTimeOffset];
			self.character.trainingData	   = [NSDictionary dictionaryWithDictionary:trainingData];
		}
		else self.character.trainingData = nil;
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

- (void)characterSheetWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSXMLElement * root, * node;
	NSArray * nodeList;
	EveCorporation * corp;
	EveAlliance * alliance;
	NSDictionary * corpDict, * allianceDict;
	NSString * nodeName, * propName, * propValue, * key;
	EveSkill * skill;
	time_t start;
	NSUInteger count;
	long double totalTime;
	
	root	 = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/*" error:error];

	if (!(*error)) {
		allianceDict = nil;
		corpDict	 = nil;
		
		for (node in nodeList) {
			nodeName = [node name];
			
			if ([nodeName isEqualToString:@"DoB"]) {
				self.character.dateOfBirth = CCPDate([node stringValue]);
			}
			else if ([nodeName isEqualToString:@"attributes"]) {
				for (node in [node children]) {
					[self.character setValue:[NSNumber numberWithInteger:[[node stringValue] integerValue]] forKey:[node name]];
				}
			}
			else if ([nodeName isEqualToString:@"attributeEnhancers"]) {
				// ?
			}
			else if ([nodeName hasPrefix:@"corporation"]) {
				if (corpDict) {
					propName  = [[corpDict allKeys] objectAtIndex:0];
					propValue = [corpDict objectForKey:propName];
					
					if ([propName isEqualToString:@"corporationName"]) {
						corp = [EveCorporation corporationWithName:propValue andCorporationID:[node stringValue]];
					}
					else {
						corp = [EveCorporation corporationWithName:[node stringValue] andCorporationID:propValue];
					}
					
					corpDict = nil;
					
					self.character.corporation = corp;
				}
				else {
					corpDict = [NSDictionary dictionaryWithObject:[node stringValue] forKey:nodeName];
				}
			}
			else if ([nodeName hasPrefix:@"alliance"]) {
				if (allianceDict) {
					propName  = [[allianceDict allKeys] objectAtIndex:0];
					propValue = [allianceDict objectForKey:propName];
					
					if ([propName isEqualToString:@"allianceName"]) {
						alliance = [EveAlliance allianceWithName:propValue andAllianceID:[node stringValue]];
					}
					else {
						alliance = [EveAlliance allianceWithName:[node stringValue] andAllianceID:propValue];
					}
					
					allianceDict = nil;
					
					self.character.alliance = alliance;
				}
				else {
					allianceDict = [NSDictionary dictionaryWithObject:[node stringValue] forKey:nodeName];
				}
			}
			else if ([nodeName isEqualToString:@"cloneSkillPoints"]) {
				self.character.cloneSkillPoints = [NSNumber numberWithInteger:[[node stringValue] integerValue]];
			}
			else if ([nodeName isEqualToString:@"balance"]) {
				self.character.balance = [NSNumber numberWithDouble:[[node stringValue] doubleValue]];
			}
			else if ([nodeName isEqualToString:@"rowset"]) {
				if ([[[node attributeForName:@"name"] stringValue] isEqualToString:@"skills"]) {
					totalTime = 0.0L;
					count = [node childCount];
					
					for (node in [node children]) {
						if ([[[node attributeForName:@"published"] stringValue] integerValue]) {
							start = time(NULL);
							
							key   = [[node attributeForName:@"typeID"] stringValue];
							skill = [self.character.skills objectForKey:key];
							
							if (!skill) {
								skill = [EveSkill skillWithSkillID:key];
								[self.character.skills setObject:skill forKey:key];
							}
							
							skill.skillPoints = [NSNumber numberWithInteger:[[[node attributeForName:@"skillpoints"] stringValue] integerValue]];
							skill.level		  = [NSNumber numberWithInteger:[[[node attributeForName:@"level"] stringValue] integerValue]];
							skill.character	  = self.character;
							
							//[[self.character mutableArrayValueForKey:@"skills"] addObject:skill];
							//[self.character setValue:skill forKey:[NSString stringWithFormat:@"skills.%@", [[node attributeForName:@"typeID"] stringValue]]];
							
							
							totalTime += (long double) time(NULL) - (long double) start;
						}
					}
					
					NSLog(@"Skills loaded: %lu skills, %Lgs total time, %Lgs average time.", count, totalTime, totalTime / (long double) count);

					//self.character.skills = self.character.skills;
				}
			}
			else {
				[self.character setValue:[node stringValue] forKeyPath:nodeName];
			}
		}
	}
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

- (void)didFinishDownload:(EveDownload *)download forKey:(NSString *)key withData:(NSData *)data error:(NSError *)error {
	NSXMLDocument * xmlDoc;
	NSError * processError, * authError;
	NSXMLElement * errorNode;
	NSArray * errorList;

	processError = nil;
	xmlDoc		 = nil;

	NSString * xmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@", xmlStr);
	[xmlStr release];

	if (error) {
		NSLog(@"%@", error);
		return;
	}

	// API call to Character List
	if ([key isEqualToString:@"CharacterList"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processError];

		if (!processError) [self characterListWithXML:xmlDoc error:&processError];

	}

	// API call to get portraits for a character list
	else if ([key hasPrefix:@"PortraitList"]) {
		[self portraitListWithData:data
						 forCharID:[[key componentsSeparatedByString:@" "] objectAtIndex:1]
							 error:&processError];
	}

	// API call to verify if it's a full API key or not
	else if ([key isEqualToString:@"AccountStatus"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processError];

		if (!processError) [self accountStatusWithXML:xmlDoc error:&processError];
	}

	// API call to get the character sheet
	else if ([key isEqualToString:@"CharacterSheet"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processError];

		if (!processError) [self characterSheetWithXML:xmlDoc error:&processError];
	}
	
	// API call to get the current training skill
	else if ([key isEqualToString:@"SkillInTraining"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processError];

		if (!processError) [self skillInTrainingWithXML:xmlDoc error:&processError];
	}

	// API call to get the training queue
	else if ([key isEqualToString:@"SkillQueue"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processError];

		if (!processError) [self skillQueueWithXML:xmlDoc error:&processError];
	}

	// API call to get the corporation sheet
	else if ([key isEqualToString:@"CorporationSheet"]) {
		xmlDoc = [[NSXMLDocument alloc] initWithData:data options:0 error:&processError];

		if (!processError) [self corporationSheetWithXML:xmlDoc error:&processError];
	}
	
	if (xmlDoc) {
		errorList = [[xmlDoc rootElement] nodesForXPath:@"/eveapi/error" error:&authError];

		if (!authError && [errorList count]) {
			errorNode = [errorList objectAtIndex:0];
			authError = [NSError errorWithDomain:EveAPIErrorDomain
											code:[[[errorNode attributeForName:@"code"] stringValue] integerValue]
										userInfo:[NSDictionary dictionaryWithObject:[errorNode stringValue] forKey:NSLocalizedDescriptionKey]];

			processError = authError;
		}
		
		[xmlDoc release];
	}

	if (processError) [[download.downloads objectForKey:key] setError:processError];
}

- (void)didFinishDownload:(EveDownload *)download withResults:(NSDictionary *)results {
	__block NSMutableDictionary * errors;
	
	[self.currentDownloads removeObject:download];
	
	errors = [NSMutableDictionary dictionary];

	[results enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSDictionary * obj, BOOL * stop) {
		if ([obj objectForKey:@"error"] != [NSNull null]) [errors setObject:[obj objectForKey:@"error"] forKey:key];
	}];
	
	[download removeTotalObserver:self];
	
	if ([self.lastCalls containsObject:@"SkillInTraining"]) [self.character consolidateSkillInTraining];
	if ([self.lastCalls containsObject:@"SkillQueue"]) [self.character consolidateSkillQueueWithArray:[temporaryData objectForKey:@"SkillQueue"]];
	if ([self.lastCalls containsObject:@"CorporationSheet"]) self.character.corporation.ticker = [temporaryData objectForKey:@"corpTicker"];
	
	[self.delegate request:self finishedWithErrors:[NSDictionary dictionaryWithDictionary:errors]];

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