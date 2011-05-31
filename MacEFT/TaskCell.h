//
//  TaskCell.h
//  MacEFT
//
//  Created by ugo pozo on 5/28/11.
//  Copyright 2011 Netframe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskCellController;

@interface TaskCell : NSCell {
@private
	TaskCellController * controller;
}

@property (assign) TaskCellController * controller;

+ (id)cell;

@end
