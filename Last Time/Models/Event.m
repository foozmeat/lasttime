//
//  Event.m
//  Last Time
//
//  Created by James Moore on 3/15/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Event.h"
#import "EventFolder.h"
#import "LogEntry.h"
#import "NSString+UUID.h"

@implementation Event

@dynamic eventName;
@dynamic lastTimeDisplayFormat;
@dynamic folder;
@dynamic logEntries;
@dynamic reminderDuration, notificationUUID;
@dynamic sectionIdentifier, primitiveSectionIdentifier;
@dynamic latestDate, primitiveLatestDate;
@dynamic reminderDate;

@synthesize logEntryCollection = _logEntryCollection;
@synthesize averageValue = _averageValue;
@synthesize averageInterval = _averageInterval;
@synthesize needsSorting;


//+ (Event *)randomEvent
//{
//	NSMutableArray *lec = [[NSMutableArray alloc] init];
//	
//	for (int i = 0; i < 3; i++) {
//		LogEntry *le = [LogEntry randomLogEntry];
//		[lec insertObject:le atIndex:i];
//	}
//	
//	NSArray *randomEventList = [NSArray arrayWithObjects:@"Got a Massage", @"Took Vacation", @"Watered Plants", @"Bought Cat Food", @"Had Coffee", nil];
//	
//	long eventIndex = arc4random() % [randomEventList count];
//	NSString *name = [randomEventList objectAtIndex:eventIndex];
//	
//	Event *newEvent = [[self alloc] initWithEventName:(NSString *)name
//																				 logEntries:(NSMutableArray *)lec];
//	return newEvent;
//	
//}

#pragma mark - Transient properties

- (NSString *)sectionIdentifier {
	
    // Create and cache the section identifier on demand.
	
	[self willAccessValueForKey:@"sectionIdentifier"];
	NSString *tmp = [self primitiveSectionIdentifier];
	[self didAccessValueForKey:@"sectionIdentifier"];
	
	if (!tmp) {
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateStyle:NSDateFormatterFullStyle];
		tmp = [df stringFromDate:self.latestDate];
		
		if (!tmp) {
			tmp = @"";
		}
		
		[self setPrimitiveSectionIdentifier:tmp];
	}
	return tmp;
}

- (void)updateLatestDate
{
	LogEntry *le = [self latestEntry];
	if (!le) {
		self.latestDate = nil;
	} else {
		self.latestDate = [le logEntryDateOccured];
	}
	[self updateReminderNotification];
}

- (void)setEventName:(NSString *)newEventName
{
	[self willChangeValueForKey:@"eventName"];
	[self setPrimitiveValue:newEventName forKey:@"eventName"];
	[[self folder] refreshItems];
	[self didChangeValueForKey:@"eventName"];

}

- (void)setLatestDate:(NSDate *)newDate {
	
    // If the time stamp changes, the section identifier become invalid.
	[self willChangeValueForKey:@"latestDate"];
	[self setPrimitiveLatestDate:newDate];
	[self didChangeValueForKey:@"latestDate"];
	
	[self setPrimitiveSectionIdentifier:nil];
}

#pragma mark - Key path dependencies

+ (NSSet *)keyPathsForValuesAffectingSectionIdentifier {
    // If the value of timeStamp changes, the section identifier may change as well.
	return [NSSet setWithObject:@"latestDate"];
}

- (void)awakeFromFetch
{
	needsSorting = YES;
}

- (void)addLogEntry:(LogEntry *)entry
{
	[self addLogEntriesObject:entry];
	[[EventStore defaultStore] saveChanges];
	[self refreshItems];
}

- (void)removeLogEntry:(LogEntry *)logEntry
{
	
	[self removeLogEntriesObject:logEntry];
	[[EventStore defaultStore] removeLogEntry:logEntry];
	[[EventStore defaultStore] saveChanges];
	[self refreshItems];

}

- (void)refreshItems
{
	self.needsSorting = YES;
	_averageValue = nil;
	_averageInterval = nil;
	_logEntryCollection = nil;

	[self updateLatestDate];

	[[self folder] refreshItems];

}

- (void)sortEntries
{
	if (needsSorting && [self.logEntryCollection count] > 0) {
		[_logEntryCollection sortUsingComparator:^(id a, id b) {
			NSDate *first = [(LogEntry*)a logEntryDateOccured];
			NSDate *second = [(LogEntry*)b logEntryDateOccured];
			return [second compare:first];
		}];
		
		needsSorting = NO;
	}
}

- (NSMutableArray *)logEntryCollection
{
	
	if (!_logEntryCollection) {
		_logEntryCollection = [[NSMutableArray alloc] initWithArray:[self.logEntries allObjects]];
		needsSorting = YES;
		[self sortEntries];
	}

	return _logEntryCollection;
}

- (BOOL)showAverage
{
	if ([self.logEntryCollection count] < 2) {
		return NO;
	} else {
		return YES;
	}
}

- (BOOL)showAverageValue
{
	if ([self averageValue] == nil) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Average

- (NSNumber *)averageInterval
{
	
	if (_averageInterval) {
		return _averageInterval;
	}
	
	double collectionCount = [self.logEntryCollection count];
	
	[self sortEntries];
	
	double runningTotal = 0.0;
	LogEntry *lastEntry = [self latestEntry];
	double count = 0;
	int limit = collectionCount - 1;
	if (limit > 4) {
		limit = 4;
	}
	
	@autoreleasepool {
		for (count = 0; count <= limit; count++) {
			LogEntry *entry = [self.logEntryCollection objectAtIndex:count];
			runningTotal += ABS([[entry logEntryDateOccured] timeIntervalSinceDate:[lastEntry logEntryDateOccured]]);
			lastEntry = entry;
		}
	}
	
	float average = ABS(runningTotal / (count - 1));
	_averageInterval = [NSNumber numberWithFloat:average];
	return _averageInterval;
	
}

- (NSString *)averageStringInterval;
{
	return [LogEntry stringFromInterval:[[self averageInterval] doubleValue] withSuffix:NO withDays:NO displayFormat:nil];
}

- (NSNumber *)averageValue
{
	
	if (![self showAverage]) {
		return [NSNumber numberWithFloat:0.0];
	}
	
	if (_averageValue) {
		return _averageValue;
	}
	
	double collectionCount = [self.logEntryCollection count];

	[self sortEntries];

	float runningTotal = 0.0;
	double totalCount = 0;
	
	int limit = collectionCount - 1;
	if (limit > 4) {
		limit = 4;
	}

	@autoreleasepool {
		for (int count = 0; count <= limit; count++) {
			LogEntry *entry = [self.logEntryCollection objectAtIndex:count];
			if ([entry logEntryValue] != nil) {
				runningTotal += [[entry logEntryValue] floatValue];
				totalCount++;
			}
		}
		
	}
	
	if (totalCount == 0.0) {
		return nil;
	}
	
	float average = runningTotal / totalCount;
	_averageValue = [NSNumber numberWithFloat:average];
	return _averageValue;
	
}

- (NSString *)averageStringValue
{
	nf = [[NSNumberFormatter alloc] init];
	nf.numberStyle = NSNumberFormatterDecimalStyle;
	nf.roundingIncrement = [NSNumber numberWithDouble:0.1];
	NSString *value = [nf stringFromNumber:[self averageValue]];
	
	return value;
	
}

#pragma mark - Last

-(void)cycleLastTimeDisplayFormat
{
	NSString *oldFormat = self.lastTimeDisplayFormat;
	if (oldFormat == NULL) {
		self.lastTimeDisplayFormat = @"days";
	} else if ([oldFormat isEqualToString:@"days"]) {
		self.lastTimeDisplayFormat = @"weeks";
	} else if ([oldFormat isEqualToString:@"weeks"]) {
		self.lastTimeDisplayFormat = NULL;
	}
#ifdef DEBUG
	NSLog(@"Last Time Display format changed to: %@", self.lastTimeDisplayFormat);
#endif
}

- (NSTimeInterval)lastDuration
{
	return [[self latestEntry] secondsSinceNow];
}

- (NSString *)lastStringInterval
{
	return [[self latestEntry] stringFromLogEntryIntervalWithFormat:self.lastTimeDisplayFormat];
}


- (LogEntry *)latestEntry
{
	if ([self.logEntryCollection count] == 0) {
		return nil;
	}
	[self sortEntries];
	return [self.logEntryCollection objectAtIndex:0];
}

- (NSDate *)nextTime
{
	if (![self showAverage]) {
		return nil;
	}
	NSTimeInterval interval = [[self averageInterval] doubleValue];
	NSDate *lastDate = [[self latestEntry] logEntryDateOccured];
	
	NSDate *nextDate = [[NSDate alloc] initWithTimeInterval:interval 
																								sinceDate:lastDate];
	return nextDate;
}

- (NSString *)subtitle
{
	return [[self latestEntry] subtitle];
}

-(NSString *)description
{
	NSMutableString *output = [[NSMutableString alloc] init];
	
	[output appendFormat:@"Event Name: %@\n", self.eventName];
	[output appendFormat:@"Subtitle: %@\n", [self subtitle]];
	[output appendFormat:@"Latest Entry: %@\n", [self latestEntry]];
	[output appendFormat:@"Average Interval: %f - %@\n", [self averageInterval], [self averageStringInterval]];
	[output appendFormat:@"Next Time: %@\n", [[self nextTime] descriptionWithLocale:[NSLocale currentLocale]]];
	
		//	[output appendFormat:@"%@", [self logEntryCollection]];
	
	return output;
}

#pragma mark - Reminders

- (void)updateReminderNotification
{
//	[[UIApplication sharedApplication] cancelAllLocalNotifications];

#ifdef DEBUG
		//Print all notifications
	NSArray *notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
	for (UILocalNotification *l in notificationsArray) {
    NSLog(@"%@ -- %@", l.fireDate, [[l userInfo] objectForKey:@"UUID"]);
	}
	NSLog(@"Latest Date: %@", self.latestDate);
#endif
	
	if (self.reminderDuration == 0 || self.latestDate == nil) {
		
		if (self.notificationUUID != nil) {
		// if the duration is 0 and UUID is not null 
		// search for notifications and remove them
			[self removeNotification];
		} else {
			// nothing to do
			return;
		}
		
	} else {

		if (self.notificationUUID != nil) {
			[self removeNotification];
			
		}

		if ([self newReminderDate] != nil && ![self newReminderExpired]) {
				// Schedule the notification
			UILocalNotification *localNotification = [UILocalNotification new];
			
			localNotification.fireDate = [self newReminderDate];
			localNotification.alertBody = self.eventName;
			localNotification.alertAction = NSLocalizedString(@"View", @"view this notification");
			localNotification.soundName = UILocalNotificationDefaultSoundName;
//			localNotification.applicationIconBadgeNumber = -1;
			localNotification.timeZone = [NSTimeZone defaultTimeZone];
			
			NSString *uuid = [NSString stringWithUUID];
			self.notificationUUID = uuid;
			NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:uuid, @"UUID",nil];
			localNotification.userInfo = infoDict;
			[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

#ifdef DEBUG
			NSLog(@"Notification scheduled for %@ -- %@", [self newReminderDate], uuid);
#endif
			
		} else {
#ifdef DEBUG
			NSLog(@"Not scheduling reminder for date %@", [self newReminderDate]);
#endif
		}
		self.reminderDate = [self newReminderDate];
		[[EventStore defaultStore] saveChanges];
	}
	
}

- (void)removeNotification
{
	if (self.notificationUUID == nil) {
#ifdef DEBUG
		NSLog(@"no notifications removed");
#endif
		return;
	}
	
	NSArray *notificationsArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
	
	for (UILocalNotification *l in notificationsArray) {
		
		NSString *uuid = [[l userInfo] objectForKey:@"UUID"];

		if ([self.notificationUUID isEqualToString:uuid]) {
#ifdef DEBUG
			NSLog(@"Canceling notification %@", uuid);
#endif
			[[UIApplication sharedApplication] cancelLocalNotification:l];
		}
	}
	self.notificationUUID = nil;
	self.reminderDate = nil;
}

- (BOOL)reminderExpired
{
	if (self.reminderDate == nil) {
		return NO;
	}
	NSInteger interval = [self.reminderDate timeIntervalSinceNow];
	
	if (interval > 0) {
		return NO;
	} else {
		return YES;
	}
}

- (BOOL)newReminderExpired
{
	if ([self newReminderDate] == nil) {
		return NO;
	}
	NSInteger interval = [[self newReminderDate] timeIntervalSinceNow];
	
	if (interval > 0) {
		return NO;
	} else {
		return YES;
	}
}

- (NSDate *)newReminderDate
{
	if (self.reminderDuration == 0 || self.latestDate == nil) {
		return nil;
	}

#ifdef DEBUG
//	NSDate *fakeDate = [[NSDate alloc] initWithTimeIntervalSinceNow:10];
//
//	return fakeDate;
#endif
	
	NSDate *reminderDate = [[NSDate alloc] initWithTimeInterval:self.reminderDuration 
																										sinceDate:self.latestDate];
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	unsigned int unitFlags = NSDayCalendarUnit | NSMonthCalendarUnit | NSWeekdayCalendarUnit | NSWeekCalendarUnit | NSYearCalendarUnit | NSTimeZoneCalendarUnit;
	NSDateComponents *nowComps = [sysCalendar components:unitFlags fromDate:reminderDate];

	nowComps.hour = 9;
	nowComps.minute = 0;
	nowComps.second = 0;
	
	NSDate *normalizedReminderDate = [sysCalendar dateFromComponents:nowComps];
	
	return normalizedReminderDate;
}

- (NSString *)reminderDateString
{
	if (self.reminderDuration == 0) {
		return nil;
	}
	
	NSDate *reminderDate = [self newReminderDate];

	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	
	[df setDateStyle:NSDateFormatterMediumStyle];
	[df setTimeStyle:NSDateFormatterNoStyle];
	
	NSString *reminderDateString = [df stringFromDate:reminderDate];
	
	return reminderDateString;

}

@end
