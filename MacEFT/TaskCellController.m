//
//  TaskCellController.m
//  MacEFT
//
//  Created by ugo pozo on 5/28/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import "TaskCellController.h"

@implementation TaskCellController

@synthesize node, isGroup, textColor;

- (id)initWithNode:(NSDictionary *)aNode {
	if ((self = [super initWithNibName:@"TaskView" bundle:nil])) {
		self.node        = aNode;
		self.isGroup     = [[node objectForKey:@"groupItem"] boolValue];
		
		[self loadView];
	}
	
	return self;
}



+ (id)controllerWithNode:(NSDictionary *)aNode {
	return [[[self alloc] initWithNode:aNode] autorelease];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	rootKeys = [NSSet set];
	
	return rootKeys;
}

- (NSView *)mainView {
	return (isGroup) ? groupView : [self view];
}

- (void)addSubviewsToView:(NSView *)parent frame:(NSRect)frame highlight:(BOOL)highlight {
	if (highlight) self.textColor = [NSColor whiteColor];
	else self.textColor = [NSColor blackColor];
	
	[self.mainView setFrame:frame];
	
	if ([self.mainView superview] != parent) {
		[parent addSubview:self.mainView];
	}
}

- (void)removeSubviews {
	[self.mainView removeFromSuperview];
}

- (NSImage *)image {
	NSImage * img;
	NSString * iconPath;
	NSURL * iconURL;
	
	iconPath = [NSString stringWithFormat:@"%@_32", [node objectForKey:@"icon"]];
	
	iconPath = [[NSBundle mainBundle] pathForResource:iconPath ofType:@"png" inDirectory:@"Types"];

	if (iconPath) {
		iconURL  = [NSURL URLWithString:[NSString stringWithFormat:@"file:%@", iconPath]];

		img = [[[NSImage alloc] initWithContentsOfURL:iconURL] autorelease];
	}
	else {
		img = nil;
	}
	
	return img;
}

- (void)dealloc {
	self.node  = nil;
	self.textColor = nil;
	
	[super dealloc];
}

@end
