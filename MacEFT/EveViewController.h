//
//  EveViewController.h
//  MacEFT
//
//  Created by ugo pozo on 4/30/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CharacterDocument;

@interface EveViewController : NSViewController {
@private
	CharacterDocument * document;
    
}

@property (assign) CharacterDocument * document;

+ (id)viewController;

@end
