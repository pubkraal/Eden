//
//	CharacterWindowController.m
//	MacEFT
//
//	Created by ugo pozo on 4/30/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterDocument.h"
#import "CharacterWindowController.h"
#import "CharacterInfoController.h"
#import "EveCharacter.h"
#import "CharacterCreateSheetController.h"

@implementation CharacterDocument

@synthesize character, currentTask, viewSizes;
@synthesize cwController, ccController;

- (id)init {
	if ((self = [super init])) {
		currentWrapper = nil;
		cwController   = nil;
		ccController   = nil;
		
		[self setCharacter:nil];
		[self setCurrentTask:nil];
		[self setViewSizes:nil];

	}
	
	return self;
}

- (void)dealloc {
	if (currentWrapper) [currentWrapper release];

	[self setCharacter:nil];
	[self setCurrentTask:nil];
	[self setViewSizes:nil];

	[super dealloc];
}


- (BOOL)isDocumentEdited {
	return NO;
}

- (void)makeWindowControllers {
	cwController = [[CharacterWindowController alloc] init];
	ccController = [[CharacterCreateSheetController alloc] init];
	
	[self addWindowController:cwController];
	[self addWindowController:ccController];
	
	[cwController release];
	[ccController release];
}

- (void)showSheet:(NSWindowController *)controller {
	if (controller != cwController) {
		[NSApp beginSheet:[controller window]
		   modalForWindow:[self windowForSheet]
			modalDelegate:controller
		   didEndSelector:@selector(didEndSheet:returnCode:context:)
			  contextInfo:self];
		
	}
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)wrapper ofType:(NSString *)typeName error:(NSError **)error {
 	NSFileWrapper * item;
	NSMutableDictionary * errDict;
	NSDictionary * data;
	BOOL fileRead;

	errDict = [NSMutableDictionary dictionary];
	item    = [[wrapper fileWrappers] objectForKey:@"character.data"];

	if (item) {
		@try {
			data = [NSKeyedUnarchiver unarchiveObjectWithData:[item regularFileContents]];

			[self unarchiveWithDictionary:data];

			fileRead      = YES;
			if (currentWrapper) [currentWrapper release];

			currentWrapper = [wrapper retain];

		}
		@catch (NSException * e) {
			[errDict setObject:@"File is corrupted" forKey:NSLocalizedDescriptionKey];
			if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:errDict];
			fileRead = NO;
		}

	}
	else {
		[errDict setObject:@"Package is incomplete" forKey:NSLocalizedDescriptionKey];
		if (error) *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:errDict];
		fileRead = NO;
	}
	 
	 if (!fileRead) NSLog(@"%@", errDict);

	return fileRead;

 }

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)error {
	NSData * characterData;
	NSFileWrapper * newWrapper, * oldItem;

	characterData = [NSKeyedArchiver archivedDataWithRootObject:[self dictionaryForArchival]];
	
	newWrapper = (currentWrapper) ? currentWrapper : [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];

	if ((oldItem = [[newWrapper fileWrappers] objectForKey:@"character.data"])) {
		[newWrapper removeFileWrapper:oldItem];
	}

	[newWrapper addRegularFileWithContents:characterData preferredFilename:@"character.data"];

	if (!currentWrapper) currentWrapper = newWrapper;

	return newWrapper;
}

- (NSDictionary *)dictionaryForArchival {
	return [NSDictionary dictionaryWithObjectsAndKeys:
							character, @"character",
							currentTask, @"currentTask",
							viewSizes, @"viewSizes",
							nil];
}

- (void)unarchiveWithDictionary:(NSDictionary *)data {
	[self setCharacter:[data objectForKey:@"character"]];
	[self setCurrentTask:[data objectForKey:@"currentTask"]];
	[self setViewSizes:[data objectForKey:@"viewSizes"]];
}

@end
