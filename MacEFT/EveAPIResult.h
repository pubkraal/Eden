//
//  EveAPIResult.h
//  MacEFT
//
//  Created by John Kraal on 3/28/11.
//  Copyright 2011 Netframe. All rights reserved.
//

/**
 * This object is a Dictionary like container for the results of the API. The
 * results the API returns are way to varied and unstructured to make an object
 * for every kind. With this you can easily extract what you need for your
 * methods, you just have to think more carefully about what you're doing.
 */

#import <Foundation/Foundation.h>


@interface EveAPIResult : NSObject {
    NSString *data;
}

@property(retain) NSString *data;

- (void)parseData:(NSString *)XMLdata;

@end
