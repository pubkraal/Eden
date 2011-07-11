//
//	SkillBar.m
//	Eden
//
//	Created by ugo pozo on 6/18/11.
//	Copyright 2011 Netframe. All rights reserved.
//

#import "SkillBar.h"
#import "EveSkill.h"
#import "EveCharacter.h"
#import <stdlib.h>
#import <string.h>

@implementation SkillBar

@synthesize character;

+ (void)initialize {
	[self exposeBinding:@"character"];
}

- (id)initWithFrame:(NSRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.character = nil;
		
		[self addObserver:self forKeyPath:@"queue" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"queue"]) {
		[self setNeedsDisplay:YES];
	}
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)dependentKey {
	NSSet * rootKeys;
	
	if ([dependentKey isEqualToString:@"queue"]) {
		rootKeys = [NSSet setWithObjects:@"character.trainingQueue", @"character.skillInTraining.skillPoints", nil];
	}
	else rootKeys = [NSSet set];
	
	return rootKeys;
}

- (Class)valueClassForBinding:(NSString *)binding {
	Class cls;
	
	if ([binding isEqualToString:@"character"]) cls = [EveCharacter class];
	else cls = [super valueClassForBinding:binding];
	
	return cls;
}

- (NSArray *)queue {
	NSDate * tomorrow, * now, * start, * end;
	NSMutableArray * includedTimeFrames;
	NSDictionary * info;
	EveSkill * skill;
	NSComparisonResult cmp;
	NSTimeInterval usedInterval, emptyInterval;
	
	includedTimeFrames = [NSMutableArray array];
	now                = [NSDate date];
	tomorrow           = [NSDate dateWithTimeInterval:86400.0 sinceDate:now]; // 24 hours
	info               = nil;
	
	for (skill in self.character.trainingQueue) {
		// CCP should guarantee that every skill in the training queue
		// starts in less than 24 hours, we will not check this
		
		cmp = [now compare:skill.startDate];
		
		if (cmp == NSOrderedAscending) {
			// The skill will start after now
			
			start = skill.startDate;
		}
		else {
			// The skill has already started or is starting
			
			start = now;
		}
		
		cmp = [tomorrow compare:skill.endDate];
		
		if (cmp == NSOrderedAscending) {
			// The skill finishes after 24 hours
			
			end = tomorrow;
		}
		else {
			// The skill finishes before or in exactly 24 hours
			
			end = skill.endDate;
		}
		
		usedInterval = [end timeIntervalSinceDate:start];
		
		info = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%@ %d", skill.name, [skill.level integerValue] + 1], @"name",
											[NSNumber numberWithDouble:usedInterval], @"interval",
											end, @"endDate",
											nil];
		
		[includedTimeFrames addObject:info];
	}
	
	if (info == nil) emptyInterval = 86400;
	else emptyInterval = [tomorrow timeIntervalSinceDate:[info objectForKey:@"endDate"]];
	
	if (emptyInterval > 0) {
		info = [NSDictionary dictionaryWithObjectsAndKeys:
											[NSNull null], @"name",
											[NSNumber numberWithDouble:emptyInterval], @"interval",
											tomorrow, @"endDate",
											nil];
		
		[includedTimeFrames addObject:info];
	}
	
	return includedTimeFrames;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"queue"];
	
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
	NSRect bounds, outer, inner, part;
	NSBezierPath * bz;
	CGFloat radius, lastStart;
	NSDictionary * info;
	NSColor * color;
	NSTimeInterval interval;
	BOOL alternate;
	NSInteger partsLeft;
	NSArray * queue;
	
	bounds = [self bounds];
	outer  = NSInsetRect(bounds, 2.0, 2.0);
	radius = outer.size.height / 2.0;
	bz     = [NSBezierPath bezierPathWithRoundedRect:outer xRadius:radius yRadius:radius];
	
	bz.lineWidth = 3.0;
	
	[[NSColor blackColor] set];
	[bz stroke];
	
	inner  = NSInsetRect(outer, 4.0, 4.0);
	radius = inner.size.height / 2.0;
	bz    = [NSBezierPath bezierPathWithRoundedRect:inner xRadius:radius yRadius:radius];
	
	bz.lineWidth = 1.0;

	[bz addClip];

	queue     = self.queue;
	alternate = NO;
	lastStart = 0.0;
	partsLeft = [queue count];
	
	for (info in queue) {
		memcpy(&part, &inner, sizeof(NSRect));
		
		interval = [[info objectForKey:@"interval"] doubleValue];
		
		part.size.width = floor(inner.size.width * interval / 86400.0);
		part.origin.x  += lastStart;
		
		if (partsLeft == 1) {
			// This is the last part, let's make sure it covers
			// all the space available.
			
			//part.size.width += (outer.origin.x + outer.size.width) - (part.origin.x + part.size.width);
			part.size.width = outer.origin.x + outer.size.width - part.origin.x;
			
		}
		
		if ([info objectForKey:@"name"] == [NSNull null]) color = [NSColor controlColor];
		else color = (alternate) ? [NSColor lightGrayColor] : [NSColor darkGrayColor];
		
		[color set];
		NSRectFill(part);
		
		alternate = !alternate;
		lastStart = (part.origin.x + part.size.width) - inner.origin.x;
		partsLeft--;
	}
}

@end
