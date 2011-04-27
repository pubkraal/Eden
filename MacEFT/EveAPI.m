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

    EveAPIResult *res = [[EveAPIResult alloc]init];
    return res;
}

@end
