//
//  TaskCell.m
//  MacEFT
//
//  Created by ugo pozo on 5/28/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "TaskCell.h"
#import "TaskCellController.h"

@implementation TaskCell

@synthesize controller;

- (id)init {
	if ((self = [super initTextCell:@""])) {

	}
	
	return self;
}

+ (id)cell {
	return [[[self alloc] init] autorelease];
}

#pragma mark Drawing

- (NSRect)titleRectForBounds:(NSRect)cellRect inView:(NSView*)controlView {
	/*cellRect.origin.x    += [controller frame].origin.x;
	cellRect.size.height  = [controller frame].size.height;
	*/
	return cellRect;
	
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView *)controlView {
	[controller addSubviewsToView:controlView frame:frame highlight:[self isHighlighted]];
}



#pragma mark -

- (void)dealloc {
	[super dealloc];
}

@end
