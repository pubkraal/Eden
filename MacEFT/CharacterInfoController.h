//
//  CharacterInfoController.h
//  MacEFT
//
//  Created by ugo pozo on 4/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EveViewController.h"


@interface CharacterInfoController : EveViewController {
@private
	NSArray * skillSortDescriptors;
}

@property (retain) NSArray * skillSortDescriptors;


@end
