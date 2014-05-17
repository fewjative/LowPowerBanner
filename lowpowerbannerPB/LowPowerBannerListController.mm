#import "LowPowerBannerListController.h"
#import "TriggerViewController.h"
#import "PercentageViewController.h"
#import <sqlite3.h>
#import <notify.h>

#define DOCUMENT @"/var/mobile/Library/LowPowerBanner"
#define DATABASE [DOCUMENT stringByAppendingPathComponent:@"/lpb.db"]
#define BUNDLE [NSBundle bundleWithPath:@"/Library/PreferenceBundles/LowPowerBanner.bundle"]

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

static NSMutableDictionary *plistDict;

@implementation LowPowerBannerListController
- (id)init
{
	NSLog(@"init");
	if ((self = [super init]))
	{
		self.title = @"LowPowerBanner";

		tbView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) style:UITableViewStyleGrouped];
		
		if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
		{ 	
			tbView.contentInset = UIEdgeInsetsMake(44.0f, 0.0f, 0.0f, 0.0f);
		}

		self.navigationItem.rightBarButtonItem = self.editButtonItem;

		[tbView setDelegate:self];
		[tbView setDataSource:self];
	}

	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/LowPowerBanner/com.joshdoctors.lowpowerbanner.plist"])
	{
		plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/LowPowerBanner/com.joshdoctors.lowpowerbanner.plist"];
	}
	else
	{
		plistDict = [[NSMutableDictionary alloc] init];
	}

	return self;
}

/*
- (id)specifiers{
	if(_specifiers==nil){
		_specifiers = [[self loadSpecifiersFromPlistName:@"LowPowerBanner" target:self]retain];
	}
	return _specifiers;
}*/

- (id)view
{
	NSLog(@"view");
	return tbView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSLog(@"numbersOfSectionsInTableView");
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{ 	
		return 4;
	}
	else
		return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSLog(@"numbersOfRowsInSection");
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{ 			
		if (section == 0)
			return 2;
		else if (section==1)
			return 1;
		else if (section == 3)
			return 3;
		return [self numberOfRows];
	}
	else
	{
		if (section == 0)
			return 1;
		else if (section == 2)
			return 3;
		return [self numberOfRows];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"cellForRowAtIndexPath");
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-fucking-cell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			switch (indexPath.section)
			{
				case 0:
					{
						switch (indexPath.row)
						{		
							case 0:
								{
									BOOL firstSwitchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"switchChanged"];
									NSLog( @"The first switch is LOADED to %@", firstSwitchState ? @"ON" : @"OFF" );
									cell.textLabel.text = @"Enable Tweak";
					                cell.selectionStyle = UITableViewCellSelectionStyleNone;
					                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
					                cell.accessoryView = switchView;
					                [switchView setOn:firstSwitchState animated:NO];
					                [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
					                [switchView release];				
									break;
								}
							case 1:
								{
									BOOL secondSwitchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"nextSwitchChanged"];
									NSLog( @"The second switch is LOADED to %@", secondSwitchState ? @"ON" : @"OFF" );
									cell.textLabel.text = @"Enable Flagpaint Fix";
					                cell.selectionStyle = UITableViewCellSelectionStyleNone;
					                UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
					                cell.accessoryView = switchView;
					                [switchView setOn:secondSwitchState animated:NO];
					                [switchView addTarget:self action:@selector(nextSwitchChanged:) forControlEvents:UIControlEventValueChanged];
					                [switchView release];
									break;
								}
						}
						break;
					}
				case 1:
					{
						cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions' trigger", nil, BUNDLE, @"Actions' trigger");
						break;
					}
				case 2:
					{
						if ([[[self levels] objectAtIndex:indexPath.row] isEqualToString:@"-1"])
							cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when unplugged", nil, BUNDLE, @"Actions when unplugged");
						else if ([[[self levels] objectAtIndex:indexPath.row] isEqualToString:@"0"])
							cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when plugged in", nil, BUNDLE, @"Actions when plugged in");
						else cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Actions at %@%%", nil, BUNDLE, @"Actions at %@%%"), [[self levels] objectAtIndex:indexPath.row]];
						break;
					}
				case 3:
					{
						switch (indexPath.row)
						{
							case 0:
								{
									cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Readme", nil, BUNDLE, @"Readme");
									cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Take a look at me before customizing!", nil, BUNDLE, @"Take a look at me before customizing!");								
									break;
								}
							case 1:
								{
									cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Share ideas and credits", nil, BUNDLE, @"Share ideas and credits");
									cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Email me if you have tweak ideas!", nil, BUNDLE, @"Email me if you have tweak ideas!");
									break;
								}
							case 2:
								{
									cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Follow me on Twitter", nil, BUNDLE, @"Follow me on Twitter");
									break;
								}
						}
					}
			}
		}
		return cell;
	}
	else
	{
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-fucking-cell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			switch (indexPath.section)
			{
				case 0:
					{
						cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions' trigger", nil, BUNDLE, @"Actions' trigger");
						break;
					}
				case 1:
					{
						if ([[[self levels] objectAtIndex:indexPath.row] isEqualToString:@"-1"])
							cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when unplugged", nil, BUNDLE, @"Actions when unplugged");
						else if ([[[self levels] objectAtIndex:indexPath.row] isEqualToString:@"0"])
							cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Actions when plugged in", nil, BUNDLE, @"Actions when plugged in");
						else cell.textLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Actions at %@%%", nil, BUNDLE, @"Actions at %@%%"), [[self levels] objectAtIndex:indexPath.row]];
						break;
					}
				case 2:
					{
						switch (indexPath.row)
						{
							case 0:
								{
									cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Readme", nil, BUNDLE, @"Readme");
									cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Take a look at me before customizing!", nil, BUNDLE, @"Take a look at me before customizing!");								
									break;
								}
							case 1:
								{
									cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Share ideas and credits", nil, BUNDLE, @"Share ideas and credits");
									cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Email me if you have tweak ideas!", nil, BUNDLE, @"Email me if you have tweak ideas!");
									break;
								}
							case 2:
								{
									cell.textLabel.text = NSLocalizedStringFromTableInBundle(@"Donate via PayPal", nil, BUNDLE, @"Donate via PayPal");
									cell.detailTextLabel.text = NSLocalizedStringFromTableInBundle(@"Help improve LowPowerBanner!", nil, BUNDLE, @"Help improve LowPowerBanner!");
									break;
								}
						}
					}
			}
		}
		return cell;
	}
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The first switch is %@", switchControl.on ? @"ON" : @"OFF" );

    if(switchControl.on)
    {
    	notify_post("com.joshdoctors.lowpowerbanner.enabletweak");
    }else
    	notify_post("com.joshdoctors.lowpowerbanner.disabletweak");

	[[NSUserDefaults standardUserDefaults] setBool:switchControl.on forKey:@"switchChanged"];
	[[NSUserDefaults standardUserDefaults] synchronize];


	[plistDict setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"enableTweak"];

	[plistDict writeToFile:@"/var/mobile/Library/LowPowerBanner/com.joshdoctors.lowpowerbanner.plist" atomically:YES];
}

- (void) nextSwitchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The second switch is %@", switchControl.on ? @"ON" : @"OFF" );

    if(switchControl.on)
    {
    	notify_post("com.joshdoctors.lowpowerbanner.enablefix");
    }else
    	notify_post("com.joshdoctors.lowpowerbanner.disablefix");

    [[NSUserDefaults standardUserDefaults] setBool:switchControl.on forKey:@"nextSwitchChanged"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[plistDict setObject:[NSNumber numberWithBool:switchControl.on] forKey:@"enableFix"];

	[plistDict writeToFile:@"/var/mobile/Library/LowPowerBanner/com.joshdoctors.lowpowerbanner.plist" atomically:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	NSLog(@"titleForFooterInSection");
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{
		if (section == 3)
			return NSLocalizedStringFromTableInBundle(@"By fewjative & snakeninny & PrimeCode", nil, BUNDLE, @"By fewjative & snakeninny & PrimeCode");
		return nil;
	}
	else
	{
		if (section == 2)
			return NSLocalizedStringFromTableInBundle(@"By fewjative & snakeninny & PrimeCode", nil, BUNDLE, @"By fewjative & snakeninny & PrimeCode");
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"didSelectRowAtIndexPath");
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{
		if (indexPath.section == 1)
		{
			TriggerViewController *triggerController = [[TriggerViewController alloc] init];
			[self.navigationController pushViewController:triggerController animated:YES];
			[triggerController release];
		}
		else if (indexPath.section == 2)
		{
			PercentageViewController *percentController = [[PercentageViewController alloc] init];
			percentController.levelString = [[self levels] objectAtIndex:indexPath.row];
			[self.navigationController pushViewController:percentController animated:YES];
			[percentController release];
		}
		else if (indexPath.section == 3)
		{
			switch (indexPath.row)
			{
				case 0:
					{
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTableInBundle(@"1. Customization is in \"Actions' trigger\".\n2. Put your own png format icons under \"/var/mobile/Library/LowPowerBanner/Icons/\".\n3. Put your own caf format ringtones under \"/var/mobile/Library/LowPowerBanner/Ringtones/\".\n4. Google if you don't know how to customize png or caf files, don't email me for this!\n5. Notice that you should lowercase all ringtone/icon files' extensions, i.e. use LowPowerBanner.caf rather than LowPowerBanner.CAF, Caf, etc.\n6. Leave \"Title\" and \"Message\" empty to disable the banner.", nil, BUNDLE, @"1. Customization is in \"Actions' trigger\".\n2. Put your own png format icons under \"/var/mobile/Library/LowPowerBanner/Icons/\".\n3. Put your own caf format ringtones under \"/var/mobile/Library/LowPowerBanner/Ringtones/\".\n4. Google if you don't know how to customize png or caf files, don't email me for this!\n5. Notice that you should lowercase all ringtone/icon files' extensions, i.e. use LowPowerBanner.caf rather than LowPowerBanner.CAF, Caf, etc.\n6. Leave \"Title\" and \"Message\" empty to disable the banner.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
						break;
					}
				case 1:
					{
						NSString *url = @"mailto:fewjative@gmail.com?subject=LowPowerBanner";
						url = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, (CFStringRef)@" ", kCFStringEncodingUTF8);
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
						[url release];
						break;
					}
				case 2:
					{
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/Fewjative"]];
						break;
					}
			}
		}
	}
	else
	{
		if (indexPath.section == 0)
		{
			TriggerViewController *triggerController = [[TriggerViewController alloc] init];
			[self.navigationController pushViewController:triggerController animated:YES];
			[triggerController release];
		}
		else if (indexPath.section == 1)
		{
			PercentageViewController *percentController = [[PercentageViewController alloc] init];
			percentController.levelString = [[self levels] objectAtIndex:indexPath.row];
			[self.navigationController pushViewController:percentController animated:YES];
			[percentController release];
		}
		else if (indexPath.section == 2)
		{
			switch (indexPath.row)
			{
				case 0:
					{
						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTableInBundle(@"1. Customization is in \"Actions' trigger\".\n2. Put your own png format icons under \"/var/mobile/Library/LowPowerBanner/Icons/\".\n3. Put your own caf format ringtones under \"/var/mobile/Library/LowPowerBanner/Ringtones/\".\n4. Google if you don't know how to customize png or caf files, don't email me for this!\n5. Notice that you should lowercase all ringtone/icon files' extensions, i.e. use LowPowerBanner.caf rather than LowPowerBanner.CAF, Caf, etc.\n6. Leave \"Title\" and \"Message\" empty to disable the banner.", nil, BUNDLE, @"1. Customization is in \"Actions' trigger\".\n2. Put your own png format icons under \"/var/mobile/Library/LowPowerBanner/Icons/\".\n3. Put your own caf format ringtones under \"/var/mobile/Library/LowPowerBanner/Ringtones/\".\n4. Google if you don't know how to customize png or caf files, don't email me for this!\n5. Notice that you should lowercase all ringtone/icon files' extensions, i.e. use LowPowerBanner.caf rather than LowPowerBanner.CAF, Caf, etc.\n6. Leave \"Title\" and \"Message\" empty to disable the banner.") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
						[alertView show];
						[alertView release];
						break;
					}
				case 1:
					{
						NSString *url = @"mailto:fewjative@gmail.com?subject=LowPowerBanner";
						url = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, (CFStringRef)@" ", kCFStringEncodingUTF8);
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
						[url release];
						break;
					}
				case 2:
					{
						[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/Fewjative"]];
						break;
					}
			}
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"canEditRowAtIndexPath");
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) 
	{
		if (indexPath.section == 2)
			return YES;
		return NO;
	}
	else
	{
		if (indexPath.section == 1)
			return YES;
		return NO;
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	NSLog(@"setEditing");
    [super setEditing:editing animated:animated];
    [tbView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"commitEditingStyle");
	sqlite3 *database;
	char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"delete from lpb where level = '%@'", [[self levels] objectAtIndex:indexPath.row]];
		if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK)
			NSLog(@"LPBERROR: %@, %s", sql, error);

		sqlite3_close(database);
	}

	[tableView beginUpdates];
	[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[tableView endUpdates];

	[(UITableView *)self.view reloadData];

	notify_post("com.joshdoctors.lowpowerbanner.loadsettings");
}

- (int)numberOfRows
{
	NSLog(@"numberofRows");
	int number = 0;

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select count (*) from lpb"];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				number = atoi((char *)sqlite3_column_text(statement, 0));
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(database);
	}

	return number;
}

- (NSMutableArray *)levels
{
	NSLog(@"levels");
	NSMutableArray *levelArray = [NSMutableArray arrayWithCapacity:[self numberOfRows]];

	sqlite3 *database;
	sqlite3_stmt *statement;
	const char *error;
	if (sqlite3_open([DATABASE UTF8String], &database) == SQLITE_OK)
	{
		NSString *sql = [NSString stringWithFormat:@"select level from lpb order by (cast(level as integer)) asc"];
		if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, &error) == SQLITE_OK)
		{
			while (sqlite3_step(statement) == SQLITE_ROW)
			{
				char *levelChar = (char *)sqlite3_column_text(statement, 0);
				NSString *levelString = levelChar ? [NSString stringWithUTF8String:levelChar] : @"";
				if ([levelString length] != 0)
					[levelArray addObject:levelString];
			}
			sqlite3_finalize(statement);
		}
		sqlite3_close(database);
	}

	return levelArray;
}

- (void)dealloc
{	NSLog(@"Deallocating...");
	tbView.delegate = nil;
	[tbView release];
	[super dealloc];
	[plistDict release];
}
@end
