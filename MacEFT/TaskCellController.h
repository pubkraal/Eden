//
//  TaskCellController.h
//  MacEFT
//
//  Created by ugo pozo on 5/28/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EveViewController.h"

@interface TaskCellController : EveViewController {
@private
	IBOutlet NSView * groupView;

	BOOL isGroup;
	NSColor * textColor;

	NSDictionary * node;
}

@property (assign) BOOL isGroup;

@property (retain) NSDictionary * node;
@property (retain) NSColor * textColor;

@property (readonly) NSView * mainView;
@property (readonly) NSImage * image;

- (id)initWithNode:(NSDictionary *)aNode;
+ (id)controllerWithNode:(NSDictionary *)aNode;

- (void)addSubviewsToView:(NSView *)parent frame:(NSRect)frame highlight:(BOOL)highlight;
- (void)removeSubviews;

@end
