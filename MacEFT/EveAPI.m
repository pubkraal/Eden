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

- (EveAPIResult *)listCharacters:(uint)userID apiKey:(NSString*)apiKey {
    EveAPIResult *res = [[EveAPIResult alloc]init];

    NSDictionary *urls = [[NSDictionary alloc]init];    // Need to figure out
                                                        // what to put in here

    EveDownload *downloader = [[EveDownload alloc]initWithURLList:urls];
    [downloader start];

    // Output goes where?
    
    return res;
}

@end
