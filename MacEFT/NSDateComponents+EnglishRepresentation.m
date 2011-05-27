//
//  NSDateComponents+EnglishRepresentation.m
//  MacEFT
//
//  Created by ugo pozo on 5/21/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "NSDateComponents+EnglishRepresentation.h"


@implementation NSDateComponents (EnglishRepresentation)

- (NSString *)englishRepresentation {
	NSMutableString * finishesIn;
	NSUInteger i, c;
	NSInteger * qty;
	NSInvocation * iv;
	NSString * unit;
	SEL ivs;
	const char * unitsNames[6] = { "month", "week", "day", "hour", "minute", "second" };
	
	finishesIn = [NSMutableString string];
	
	for (i = 0, c = 0; (i < 6) && (c < 3); i++) {
		unit = [NSString stringWithUTF8String:unitsNames[i]];
		
		ivs  = NSSelectorFromString(unit);
		iv   = [NSInvocation invocationWithMethodSignature:[[self class] instanceMethodSignatureForSelector:ivs]];
		
		[iv setSelector:ivs];
		[iv setTarget:self];
		
		qty  = malloc([[iv methodSignature] methodReturnLength]);
		
		[iv invoke];
		
		[iv getReturnValue:qty];
		
		if (*qty || c || i > 2) {
			[finishesIn appendFormat:@"%ld %@%s", *qty, unit, (*qty != 1) ? "s" : ""];
			
			if (!c) [finishesIn appendString:@", "];
			else if (c == 1) [finishesIn appendString:@" and "];
			
			c++;
		}
		
		free(qty);
	}
	
	return [NSString stringWithString:finishesIn];
}

@end
