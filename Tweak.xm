#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sqlite3.h>
#import "substrate.h"
#import "LPBAction.h"
#import "LowPowerBanner.h"

#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]
#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define RINGTONE [DOCUMENT stringByAppendingPathComponent:@"/Ringtones"]
#define ICON [DOCUMENT stringByAppendingPathComponent:@"/Icons"]

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

extern NSString *iconString;
extern BOOL shouldReplaceBannerIcon;

static NSInteger lastLevel = -60;
static NSMutableArray *levelArray = nil;
static void LoadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
static void EnableTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
static void DisableTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
static void EnableFix(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
static void DisableFix(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

static void (*original_AudioServicesPlaySystemSound)(int inSystemSoundID);
static void CopySettingsToLibrary();

static void LoadSettings(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	[levelArray release];
	levelArray = nil;
	levelArray = [[NSMutableArray alloc] initWithCapacity:106];

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = @"select level from lpb";
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{             
				char *chLevel = (char *)sqlite3_column_text(statement, 0);
				if (chLevel != nil)
				{
					NSNumber *levelNumber = [NSNumber numberWithInt:atoi(chLevel)];
					[levelArray addObject:levelNumber];
				}
			}
			sqlite3_finalize(statement);
		}
		else NSLog(@"LPBERROR: %@ , %s", sql, error);

		sqlite3_close(database);
	}
}

static void EnableTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	enableTweak = YES;
}

static void DisableTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	enableTweak = NO;
	NSLog(@"Tweak disabled");
}

static void EnableFix(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	enableFix = YES;
}

static void DisableFix(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	enableFix = NO;
	NSLog(@"Fix disabled");
}



static void CopySettingsToLibrary()
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:RINGTONE] && ![fileManager fileExistsAtPath:ICON])
	{
		[fileManager removeItemAtPath:DOCUMENT error:nil];
		[fileManager createDirectoryAtPath:DOCUMENT withIntermediateDirectories:YES attributes:nil error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/lpb.db"] toPath:DATABASE error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Ringtones"] toPath:RINGTONE error:nil];
		[fileManager copyItemAtPath:[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] toPath:ICON error:nil];
	}

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{
		NSMutableDictionary * prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/LowPowerBanner/com.joshdoctors.lowpowerbanner.plist"];

		if(prefs)
		{
			enableTweak = ([prefs objectForKey:@"enableTweak"] ? [[prefs objectForKey:@"enableTweak"] boolValue] : enableTweak);
			enableFix = ([prefs objectForKey:@"enableFix"] ? [[prefs objectForKey:@"enableFix"] boolValue] : enableFix);
		}

		NSLog(@"enableTweak has value: %d",enableTweak);
		NSLog(@"enableFix has value: %d",enableFix);
	}

	LoadSettings(nil, nil, nil, nil, nil);
}

static void replaced_AudioServicesPlaySystemSound(int inSystemSoundID)
{
	if (inSystemSoundID == 1006) // low_power.caf
	{
		// do nothing
	}
	else if (inSystemSoundID == 1106 && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound) // beep_beep.caf
	{
		// do nothing
	}
	else original_AudioServicesPlaySystemSound(inSystemSoundID);
}

%group iOS5Hook

%hook SBBulletinBannerItem
- (id)iconImage
{
	id result = %orig;

	if (shouldReplaceBannerIcon)
	{
		shouldReplaceBannerIcon = NO;
		UIImage *bannerIconImage = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		if (bannerIconImage == nil)
			bannerIconImage = [UIImage imageWithContentsOfFile:[[[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		CGSize size = {20.0f, 20.0f};
		UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
		[bannerIconImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		bannerIconImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return bannerIconImage;
	}

	return result;
}
%end

%hook SBStatusBarDataManager
- (void)_updateBatteryPercentItem
{
	%orig;

	int level = MSHookIvar<_data>(self, "_data").batteryCapacity;

	if ([levelArray indexOfObject:[NSNumber numberWithInt:level]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		if (lastLevel + 1 == level) // Charging
			[action actionOfKind:@"up" atBatteryLevel:level];
		else if (lastLevel - 1 == level) // Draining
			[action actionOfKind:@"down" atBatteryLevel:level];
		[action release];			
	}

	lastLevel = level;
}
%end

%hook SBAlertItemsController
- (void)activateAlertItem:(id)item
{
	if ([item isKindOfClass:[objc_getClass("SBLowPowerAlertItem") class]])
		return;
	%orig;
}
%end

%hook SBUIController
- (void)ACPowerChanged
{
	%orig;

	if ([self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:0];
		[action release];	
	}
	else if (![self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:-1]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:-1];
		[action release];	
	}
}
%end

%end // end of iOS5Hook

%group iOS6Hook

%hook SBBulletinBannerItem
- (id)iconImage
{
	id result = %orig;

	if (shouldReplaceBannerIcon)
	{
		shouldReplaceBannerIcon = NO;
		UIImage *bannerIconImage = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		if (bannerIconImage == nil)
			bannerIconImage = [UIImage imageWithContentsOfFile:[[[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		CGSize size = {20.0f, 20.0f};
		UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
		[bannerIconImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		bannerIconImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return bannerIconImage;
	}

	return result;
}
%end

%hook SBStatusBarDataManager
- (void)_updateBatteryItems
{
	%orig;

	int level = [[objc_getClass("SBUIController") sharedInstance] curvedBatteryCapacityAsPercentage];

	if ([levelArray indexOfObject:[NSNumber numberWithInt:level]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		if (lastLevel + 1 == level) // Charging
			[action actionOfKind:@"up" atBatteryLevel:level];
		else if (lastLevel - 1 == level) // Draining
			[action actionOfKind:@"down" atBatteryLevel:level];
		[action release];			
	}

	lastLevel = level;
}
%end

%hook SBAlertItemsController
- (void)activateAlertItem:(id)item
{
	if ([item isKindOfClass:[objc_getClass("SBLowPowerAlertItem") class]])
		return;
	%orig;
}
%end

%hook SBUIController
- (void)ACPowerChanged
{
	%orig;

	if ([self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:0];
		[action release];	
	}
	else if (![self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:-1]] != NSNotFound)
	{
		LPBAction *action = [[LPBAction alloc] init];
		[action actionOfKind:@"up" atBatteryLevel:-1];
		[action release];	
	}
}
%end

%end // end of iOS6Hook

%group iOS7Hook //start of iOS7 hook

%hook SBAwayBulletinListItem

// Force our custom image
- (UIImage *)iconImage
{
	%log;
	UIImage * result = %orig;


	if (shouldReplaceBannerIcon)
	{
		shouldReplaceBannerIcon = NO;
		UIImage *bannerIconImage = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		if (bannerIconImage == nil)
			bannerIconImage = [UIImage imageWithContentsOfFile:[[[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		CGSize size = {20.0f, 20.0f};
		UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
		[bannerIconImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		bannerIconImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		NSLog(@"Exiting iconImage for lockscreen");
		return bannerIconImage;
	}
	
	NSLog(@"Exiting -no  change- iconImage for lockscreen");
	return result;
}

%end

%hook SBBulletinBannerItem
- (id)iconImage
{
	id result = %orig;

	if (shouldReplaceBannerIcon)
	{
		shouldReplaceBannerIcon = NO;
		UIImage *bannerIconImage = [UIImage imageWithContentsOfFile:[[ICON stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		if (bannerIconImage == nil)
			bannerIconImage = [UIImage imageWithContentsOfFile:[[[[BUNDLE bundlePath] stringByAppendingPathComponent:@"/Icons"] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", iconString]] stringByAppendingPathExtension:@"png"]];
		CGSize size = {20.0f, 20.0f};
		UIGraphicsBeginImageContextWithOptions(size, NO, 2.0f);
		[bannerIconImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
		bannerIconImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		NSLog(@"Exiting iconImage for springboard");
		return bannerIconImage;
	}

	NSLog(@"Exiting -no change - iconImage for springboard");
	return result;
}
%end

%hook SBStatusBarStateAggregator

- (void)_updateBatteryItems
{
	%orig;
	NSInteger level = (int)[(SBUIController *)[objc_getClass("SBUIController") sharedInstance] curvedBatteryCapacityAsPercentage];

	if(enableTweak)
	{
		if ([levelArray indexOfObject:[NSNumber numberWithInt:level]] != NSNotFound)
		{
			LPBAction *action = [[LPBAction alloc] init];
			if (lastLevel + 1 == level) // Charging
				[action actionOfKind:@"up" atBatteryLevel:level fix:enableFix];
			else if (lastLevel - 1 == level) // Draining
				[action actionOfKind:@"down" atBatteryLevel:level fix:enableFix];
			[action release];			
		}
	}

	NSLog(@"enableFix = %d",enableFix);

	lastLevel = level;
}

%end

%hook SBAlertItemsController
- (void)activateAlertItem:(id)item
{
	if(enableTweak)
	{
		if ([item isKindOfClass:[objc_getClass("SBLowPowerAlertItem") class]])
			return;
		%orig;
	}else
	%orig;
}
%end

%hook SBUIController
- (void)ACPowerChanged
{
	%orig;
	if(enableTweak)
	{
		if ([self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:0]] != NSNotFound)
		{
			LPBAction *action = [[LPBAction alloc] init];
			[action actionOfKind:@"up" atBatteryLevel:0 fix:enableFix];
			[action release];	
		}
		else if (![self isOnAC] && [levelArray indexOfObject:[NSNumber numberWithInt:-1]] != NSNotFound)
		{
			LPBAction *action = [[LPBAction alloc] init];
			[action actionOfKind:@"up" atBatteryLevel:-1 fix:enableFix];
			[action release];	
		}
	}
}
%end

%end // end of iOS7Hook

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	CopySettingsToLibrary();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, LoadSettings, CFSTR("com.joshdoctors.lowpowerbanner.loadsettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, EnableTweak, CFSTR("com.joshdoctors.lowpowerbanner.enabletweak"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, DisableTweak, CFSTR("com.joshdoctors.lowpowerbanner.disabletweak"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, EnableFix, CFSTR("com.joshdoctors.lowpowerbanner.enablefix"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, DisableFix, CFSTR("com.joshdoctors.lowpowerbanner.disablefix"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	}
	MSHookFunction((void **)AudioServicesPlaySystemSound, (void **)replaced_AudioServicesPlaySystemSound, (void **)&original_AudioServicesPlaySystemSound);

	//NSString *version = [[UIDevice currentDevice] systemVersion]; - [version floatValue] >= 7.0	

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{	 	
		NSLog(@"Initializing iOS7");
		%init(iOS7Hook);
	} else if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_5_1) 
	{
		NSLog(@"Initializing iOS6");
		%init(iOS6Hook)
	}else if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_5_1) 
	{
		NSLog(@"Initializing iOS5");
		%init(iOS5Hook)
	}

	[pool drain];
}
