//
//	CharacterInfoController.m
//	MacEFT
//
//	Created by ugo pozo on 4/30/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterInfoController.h"

@implementation CharacterInfoController

@synthesize skillSortDescriptors;

- (id)init {
	if ((self = [super initWithNibName:@"CharacterInfo" bundle:nil])) {
		self.skillSortDescriptors = [NSArray arrayWithObjects:
										[NSSortDescriptor sortDescriptorWithKey:@"skillGroup" ascending:YES],
										[NSSortDescriptor sortDescriptorWithKey:@"data.typeName" ascending:YES],
										nil];
	}
	
	return self;
}

- (void)dealloc {
	self.skillSortDescriptors = nil;
	[super dealloc];
}



@end
