//
//  EveAPI.m
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveAPI.h"
#import "EveCharacter.h"
#import "EveAPIResult.h"
#import "EveCorporation.h"
#import "EveAlliance.h"
#import "EveSkill.h"

NSDictionary * URLDict = nil;

@implementation EveAPI 

@synthesize character, characterList, delegate, lastCalls;

- (id)initWithAccountID:(NSString *)accountID andAPIKey:(NSString *)APIKey {
	
	if ((self = [super init])) {
		self.character  = [EveCharacter characterWithAccountID:accountID andAPIKey:APIKey];
		self.lastCalls  = [NSSet set];
		self.characterList = nil;
	}

	return self;
}

- (id)initWithCharacter:(EveCharacter *)theChar {
	if ((self = [super init])) {
		self.character = theChar;
		self.lastCalls = [NSSet set];
		self.characterList = nil;
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
	self.character  = nil;
	self.lastCalls  = nil;
	self.characterList = nil;

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
	
	URLList  = [[self class] URLListForKeys:calls];
	download = [EveDownload downloadWithURLList:URLList];

	[download setDelegate:self];

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
	
	download = [EveDownload downloadWithURLList:URLList];

	download.delegate = self;

	self.lastCalls = [NSSet setWithObject:@"PortraitList"];

	[download start];
}

- (void)retrieveLimitedData {
	EveDownload * download;
	NSArray * calls;
	NSDictionary * URLList;
	NSString * call;

	calls = [NSArray arrayWithObjects:
						@"CharacterSheet",
						nil];
	
	URLList  = [[self class] URLListForKeys:calls];
	download = [EveDownload downloadWithURLList:URLList];

	download.delegate = self;

	for (call in calls) {
		[download setPostBodyToDictionary:[self characterInfoForPost] forKey:call];
	}

	self.lastCalls = [NSSet setWithArray:calls];

	[download start];
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


- (NSString *)buildRequestURL:(NSString *)group method:(NSString *)method {
    NSString *retURL = [[NSString alloc]initWithFormat:@"%@/%@/%@.xml.aspx", BASE_URL, group, method];
    return retURL;
}

- (EveAPIResult *)listCharacters:(uint)userID apiKey:(NSString*)apiKey {
    
    NSString *URL = [self buildRequestURL:@"account" method:@"Characters"];
    NSLog(@"%@", URL);

    // Turn URL into NSString data here (Eve API returns UTF-8, allways)
    // Right now I'm using my own data:
    // User ID: 7452925
    // API:
    // (No, that's not my full api)
    NSString *XMLData = [[NSString alloc]initWithString:@"<?xml version='1.0' encoding='UTF-8'?>"
        "<eveapi version=\"2\">"
        "<currentTime>2011-04-27 19:34:27</currentTime>"
        "<result>"
        "<rowset name=\"characters\" key=\"characterID\" columns=\"name,characterID,corporationName,corporationID\">"
        "<row name=\"SPAECMARNIES\" characterID=\"90296398\" corporationName=\"Dreddit\" corporationID=\"1018389948\" />"
        "</rowset>"
        "</result>"
        "<cachedUntil>2011-04-27 20:31:27</cachedUntil>"
        "</eveapi>"];
    
    EveAPIResult *res = [[EveAPIResult alloc]init];
    [res parseData:XMLData];
    return res;
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

	root     = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/rowset/row" error:error];

	if (!(*error)) {
		chars = [NSMutableArray array];

		for (node in nodeList) {
			newChar = [EveCharacter characterWithCharacter:character];
			newCorp = [EveCorporation corporationWithName:[[node attributeForName:@"corporationName"] stringValue]
										 andCorporationID:[[node attributeForName:@"corporationID"] stringValue]];
			
			newChar.name          = [[node attributeForName:@"name"] stringValue];
			newChar.characterID   = [[node attributeForName:@"characterID"] stringValue];
			newChar.corporation   = newCorp;

			[chars addObject:newChar];
		}

		self.characterList = [NSArray arrayWithArray:chars];
	}
}

- (void)accountStatusWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSArray * nodeList;

	nodeList = [[xmlDoc rootElement] nodesForXPath:@"/eveapi/result/paidUntil" error:error];

	if (!(*error)) {
		if ([nodeList count]) self.character.fullAPI = YES;
		else self.character.fullAPI = NO;
	}
}

- (void)characterSheetWithXML:(NSXMLDocument *)xmlDoc error:(NSError **)error {
	NSXMLElement * root, * node;
	NSArray * nodeList;
	EveCorporation * corp;
	EveAlliance * alliance;
	NSDictionary * corpDict, * allianceDict;
	NSString * nodeName, * propName, * propValue;
	EveSkill * skill;
	double balance;
	
	root     = [xmlDoc rootElement];
	nodeList = [root nodesForXPath:@"/eveapi/result/*" error:error];

	if (!(*error)) {
		allianceDict = nil;
		corpDict     = nil;
		
		for (node in nodeList) {
			nodeName = [node name];
			
			if ([nodeName isEqualToString:@"DoB"]) {
				[self.character setDateOfBirthWithString:[node stringValue]];
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
				balance = [[node stringValue] doubleValue] * 100.0;
				self.character.balance = [NSNumber numberWithInteger:(NSInteger) (balance + 0.5)];
			}
			else if ([nodeName isEqualToString:@"rowset"]) {
				if ([[[node attributeForName:@"name"] stringValue] isEqualToString:@"skills"]) {
					for (node in [node children]) {
						if ([[[node attributeForName:@"published"] stringValue] integerValue]) {
							skill = [EveSkill skillWithSkillID:[[node attributeForName:@"typeID"] stringValue]];
							
							skill.skillPoints = [NSNumber numberWithInteger:[[[node attributeForName:@"skillpoints"] stringValue] integerValue]];
							skill.level       = [NSNumber numberWithInteger:[[[node attributeForName:@"level"] stringValue] integerValue]];
							
							//NSLog(@"%@", skill.data);

							[[self.character mutableArrayValueForKey:@"skills"] addObject:skill];
						}
					}
				}
			}
			else {
				[self.character setValue:[node stringValue] forKeyPath:nodeName];
			}
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
	xmlDoc       = nil;

	NSString * xmlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@", xmlStr);
	[xmlStr release];

	if (!error) {
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

		// Test call please ignore
		else if ([key isEqualToString:@"Echo"]) {
			processError = [NSError errorWithDomain:EveAPIErrorDomain
											   code:-1
										   userInfo:[NSDictionary dictionaryWithObject:@"Testing" forKey:NSLocalizedDescriptionKey]];
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

}

- (void)didFinishDownload:(EveDownload *)download withResults:(NSDictionary *)results {
	__block NSMutableDictionary * errors;
	
	errors = [NSMutableDictionary dictionary];

	[results enumerateKeysAndObjectsUsingBlock:^(NSString * key, NSDictionary * obj, BOOL * stop) {
		if ([obj objectForKey:@"error"] != [NSNull null]) [errors setObject:[obj objectForKey:@"error"] forKey:key];
	}];
	
	[self.delegate request:self finishedWithErrors:[NSDictionary dictionaryWithDictionary:errors]];

}

@end
