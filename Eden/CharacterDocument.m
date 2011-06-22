//
//	CharacterWindowController.m
//	Eden
//
//	Created by ugo pozo on 4/30/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "CharacterDocument.h"
#import "CharacterWindowController.h"
#import "CharacterInfoController.h"
#import "CharacterReloadController.h"
#import "EveCharacter.h"

@implementation CharacterDocument

@synthesize character, currentTask, viewSizes, windowOrigin;
@synthesize mainController;

- (id)init {
	if ((self = [super init])) {
		currentWrapper = nil;
		mainController   = nil;
		crController   = nil;

		[self setCharacter:nil];
		[self setCurrentTask:nil];
		[self setViewSizes:nil];
		[self setWindowOrigin:nil];

	}
	
	return self;
}

- (void)dealloc {
	if (currentWrapper) [currentWrapper autorelease];
	
	[self setCharacter:nil];
	[self setCurrentTask:nil];
	[self setViewSizes:nil];
	[self setWindowOrigin:nil];

	[super dealloc];
}


- (BOOL)isDocumentEdited {
	return NO;
}

- (NSString *)displayName {
	NSString * displayName;
	
	displayName = [super displayName];
	
	if (![self fileURL] && self.character) {
		// This means the document hasn't yet been saved and
		// that we already have loaded a character
		
		displayName = self.character.name;
	}
	return displayName;
}


- (void)makeWindowControllers {
	mainController = [[CharacterWindowController alloc] init];
	
	[self addWindowController:mainController];
	
	[mainController release];
}

- (CharacterReloadController *)reloadController {
	if (!crController) {
		crController = [[CharacterReloadController alloc] init];
		[self addWindowController:crController];
		[crController release];
	}
	
	return crController;
}

- (void)removeReloadController {
	if (crController) [self removeWindowController:crController];
	
	crController = nil;
}

- (void)showSheet:(NSWindowController *)controller {
	if (controller != mainController) {
		[NSApp beginSheet:[controller window]
		   modalForWindow:[self windowForSheet]
			modalDelegate:controller
		   didEndSelector:@selector(didEndSheet:returnCode:context:)
			  contextInfo:self];
		
	}
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)wrapper ofType:(NSString *)typeName error:(NSError **)error {
 	NSFileWrapper * item, * portrait;
	NSMutableDictionary * errDict;
	NSDictionary * data;
	BOOL fileRead;

	errDict = [NSMutableDictionary dictionary];
	item    = [[wrapper fileWrappers] objectForKey:@"character.data"];

	if (item) {
		@try {
			data = [NSKeyedUnarchiver unarchiveObjectWithData:[item regularFileContents]];

			[self unarchiveWithDictionary:data];
			
			portrait = [[wrapper fileWrappers] objectForKey:@"portrait.jpg"];

			if (portrait) character.portraitData = [portrait regularFileContents];

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

	if ((oldItem = [[newWrapper fileWrappers] objectForKey:@"portrait.jpg"])) {
		[newWrapper removeFileWrapper:oldItem];
	}

	[newWrapper addRegularFileWithContents:character.portraitData preferredFilename:@"portrait.jpg"];

	if (!currentWrapper) currentWrapper = newWrapper;

	return newWrapper;
}

- (NSDictionary *)dictionaryForArchival {
	return [NSDictionary dictionaryWithObjectsAndKeys:
							character, @"character",
							currentTask, @"currentTask",
							viewSizes, @"viewSizes",
							windowOrigin, @"windowOrigin",
							nil];
}

- (void)unarchiveWithDictionary:(NSDictionary *)data {
	[self setCharacter:[data objectForKey:@"character"]];
	[self setCurrentTask:[data objectForKey:@"currentTask"]];
	[self setViewSizes:[data objectForKey:@"viewSizes"]];
	[self setWindowOrigin:[data objectForKey:@"windowOrigin"]];
}

// Actions


@end
