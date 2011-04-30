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

@implementation CharacterDocument

@synthesize hasFullAPI, accountID, currentTask, viewSizes;

- (id)init {
	if ((self = [super init])) {
		currentWrapper = nil;
		cwController = nil;

		hasFullAPI = NO;
		[self setAccountID:nil];
		[self setCurrentTask:nil];
		[self setViewSizes:nil];

	}
	
	return self;
}

- (void)dealloc {
	if (currentWrapper) [currentWrapper release];

	[self setAccountID:nil];
	[self setCurrentTask:nil];
	[self setViewSizes:nil];

	[super dealloc];
}


- (BOOL)isDocumentEdited {
	return NO;
}

- (void)makeWindowControllers {
	CharacterWindowController * mainWindow;
	
	mainWindow	 = [[CharacterWindowController alloc] init];
	cwController = mainWindow;
	
	[self addWindowController:mainWindow];
	
	[mainWindow release];
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

			[self setHasFullAPI:[[data objectForKey:@"hasFullAPI"] boolValue]];
			[self setAccountID:[data objectForKey:@"accountID"]];
			[self setCurrentTask:[data objectForKey:@"currentTask"]];
			[self setViewSizes:[data objectForKey:@"viewSizes"]];

			fileRead = YES;

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

	characterData = [NSKeyedArchiver archivedDataWithRootObject:[NSDictionary dictionaryWithObjectsAndKeys:
										accountID, @"accountID",
										[NSNumber numberWithBool:hasFullAPI], @"hasFullAPI",
										currentTask, @"currentTask",
										viewSizes, @"viewSizes",
										nil]];
	
	newWrapper = (currentWrapper) ? currentWrapper : [[NSFileWrapper alloc] initDirectoryWithFileWrappers:[NSDictionary dictionary]];

	if ((oldItem = [[newWrapper fileWrappers] objectForKey:@"character.data"])) {
		[newWrapper removeFileWrapper:oldItem];
	}

	[newWrapper addRegularFileWithContents:characterData preferredFilename:@"character.data"];

	if (!currentWrapper) currentWrapper = newWrapper;

	return newWrapper;
}
@end
