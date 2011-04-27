//
//  EveAPI.m
//  MacEFT
//
//  Created by John Kraal on 3/27/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "EveAPI.h"


@implementation EveAPI : NSObject {

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

@end
