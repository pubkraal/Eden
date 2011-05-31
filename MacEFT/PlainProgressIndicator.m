//
//  PlainProgressIndicator.m
//  MacEFT
//
//  Created by ugo pozo on 5/17/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "PlainProgressIndicator.h"


@implementation PlainProgressIndicator

- (void)startAnimation:(id)sender {
	return;
}


- (void)drawRect:(NSRect)r {
	NSRect rect = NSInsetRect([self bounds], 1.5, 1.0);
	CGFloat radius = rect.size.height / 2;
	NSBezierPath *bz = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
	[bz setLineWidth:2.0];
	[[NSColor blackColor] set];
	[bz stroke];
	
	rect = NSInsetRect(rect, 2.0, 2.0);
	radius = rect.size.height / 2;
	bz = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius];
	[bz setLineWidth:1.0];
	[bz addClip];
	rect.size.width = floor(rect.size.width * (([self doubleValue] - [self minValue]) / ([self maxValue] - [self minValue])));
	NSRectFill(rect);
}

@end
