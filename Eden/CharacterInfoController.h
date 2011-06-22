//
//  CharacterInfoController.h
//  Eden
//
//  Created by ugo pozo on 4/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EveViewController.h"


@interface CharacterInfoController : EveViewController <NSOutlineViewDelegate> {
@private
	NSArray * skillSortDescriptors;
	IBOutlet NSOutlineView * skillsView;
	IBOutlet NSTreeController * skillTreeController;
	IBOutlet NSScrollView * scrollView;
	
	NSMutableDictionary * skillControllers;
}

@property (retain) NSArray * skillSortDescriptors;
@property (readonly) NSArray * skillTree;
@property (retain) NSMutableDictionary * skillControllers;


- (void)hideSkill:(NSDictionary *)node;

- (IBAction)expandAll:(id)sender;
- (IBAction)collapseAll:(id)sender;


@end
