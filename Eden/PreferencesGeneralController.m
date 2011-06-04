//
//	PreferencesGeneralController.m
//	Eden
//
//	Created by ugo pozo on 6/3/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "PreferencesGeneralController.h"
#import "PreferencesDelegate.h"

NSString * openOnStart[3] = {
	@"lastDocument",
	@"newDocument",
	@"customDocument"
};

@implementation PreferencesGeneralController

@synthesize selectedTag;

- (id)initWithDelegate:(PreferencesDelegate *)prefsDelegate {
	NSUserDefaults * prefs;
	NSUInteger i;
	NSString * currentOpenOnStart;
	
	if ((self = [super initWithNibName:@"PreferencesGeneral" andDelegate:prefsDelegate])) {
		prefs              = [NSUserDefaults standardUserDefaults];
		currentOpenOnStart = [prefs stringForKey:@"openOnStart"];
		
		for (i = 0; i < 3; i++) {
			if ([currentOpenOnStart isEqualToString:openOnStart[i]]) break;
		}
		
		if (i >= 3) {
			// The value in the preferences file is invalid
			i = 0;
			[prefs setObject:openOnStart[i] forKey:@"openOnStart"];
		}
		
		selectedTag = [[NSNumber alloc] initWithUnsignedInteger:i];

		[self loadView];
		[self addObserver:self forKeyPath:@"selectedTag" options:NSKeyValueObservingOptionNew context:NULL];
	}
	
	return self;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"customDocumentSelected"]) {
		rootKeys = [NSSet setWithObject:@"selectedTag"];
	}
	else if ([dependentKey isEqualToString:@"customDocumentIcon"]) {
		rootKeys = [NSSet setWithObject:@"customDocument"];
	}
	else if ([dependentKey isEqualToString:@"customDocumentTitle"]) {
		rootKeys = [NSSet setWithObject:@"customDocument"];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSString * newOpenOnStart;
	NSUserDefaults * prefs;
	
	if ([keyPath isEqualToString:@"selectedTag"]) {
		prefs          = [NSUserDefaults standardUserDefaults];
		newOpenOnStart = openOnStart[[self.selectedTag integerValue]];

		[prefs setObject:newOpenOnStart forKey:@"openOnStart"];
	}
}

- (BOOL)customDocumentSelected {
	NSUserDefaults * prefs;
	
	prefs = [NSUserDefaults standardUserDefaults];
	
	return [[prefs stringForKey:@"openOnStart"] isEqualToString:@"customDocument"];
}

- (NSURL *)customDocument {
	NSUserDefaults * prefs;
	NSURL * customDoc;
	
	prefs     = [NSUserDefaults standardUserDefaults];
	customDoc = [NSURL URLWithString:[prefs objectForKey:@"customDocument"]];
	
	return customDoc;
}

- (void)setCustomDocument:(NSURL *)url {
	NSUserDefaults * prefs;
	
	prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:[url absoluteString] forKey:@"customDocument"];
}

- (NSImage *)customDocumentIcon {
	NSImage * icon;
	NSURL * customDoc;
	
	if ((customDoc = self.customDocument)) {
		if (![customDoc getResourceValue:&icon forKey:NSURLEffectiveIconKey error:nil]) icon = nil;
	}
	else icon = nil;
	
	return icon;
}

- (NSString *)customDocumentTitle {
	NSString * title;
	NSURL * customDoc;
	
	if ((customDoc = self.customDocument)) {
		if (![customDoc getResourceValue:&title forKey:NSURLNameKey error:nil]) title = nil;
	}
	else title = nil;
	
	return title;
}

- (IBAction)reloadOnOpenChanged:(id)sender {
	NSUserDefaults * prefs;
	
	prefs = [NSUserDefaults standardUserDefaults];
	
	if (![prefs boolForKey:@"reloadOnFileOpened"]) [prefs setBool:NO forKey:@"reloadWhenCacheExpires"];
}

- (IBAction)chooseCustomDocument:(id)sender {
	__block NSOpenPanel * openPanel;
	
	openPanel = [NSOpenPanel openPanel];
	
	openPanel.canChooseFiles          = YES;
	openPanel.canChooseDirectories    = NO;
	openPanel.allowsMultipleSelection = NO;
	
	[openPanel beginSheetModalForWindow:self.preferencesDelegate.window completionHandler:^(NSInteger result) {
		NSURL * fileURL;
		
		if (result == NSFileHandlingPanelOKButton) {
			fileURL = [[openPanel URLs] objectAtIndex:0];
			
			self.customDocument = fileURL;
		}
	}];
}


- (void)dealloc {
	[self removeObserver:self forKeyPath:@"selectedTag"];
	
	self.selectedTag = nil;
	
	[super dealloc];
}

@end
