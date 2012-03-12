//
//  SharedObjects.m
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-10-11.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import "SharedObjects.h"

NSString *const kSharedObjectsCurrentVersion			= @"kSharedObjectsCurrentVersion";
NSString *const kSharedObjectsLastTouchedIndex		= @"kSharedObjectsLastTouchedIndex";
NSString *const kSharedObjectsLastUsedLanguage		= @"kSharedObjectsLastUsedLanguage";
NSString *const kSharedObjectsScrollingActive       = @"kSharedObjectsScrollingActive";
NSString *const kSharedObjectsAutostartActive       = @"kSharedObjectsAutostartActive";

@implementation SharedObjects

@synthesize soundPlaying, player, lastTouchedIndex, lastUsedLanguage, isPad, isRetinaDisplay, systemVersion, docFolder, scrollingActive;
@synthesize autostartActive;

- (BOOL) playSoundWithAvailablePlayer: (NSURL*) soundURL;
{
	BOOL didPlay = NO;
	
	//First we want to check if already playing that sound and reuse the same slot if that is so
	for (int i = 0; i < MAX_PLAYERS_NUMBER; i++)
	{
		if (players[i])
		{
			if ([players[i].url.path isEqualToString:soundURL.path])
			{
				[players[i] stop];
				players[i].currentTime = 0;
				[players[i] play];
				
				didPlay = YES;
				break;
			}
		}
	}
	
	if (!didPlay)
	{
		for (int i = 0; i < MAX_PLAYERS_NUMBER; i++)
		{
			if ((players[i] == nil) || !players[i].playing)
			{
				if (players[i])
				{
					[players[i] stop];
					[players[i] release];
				}
				
				players[i] = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];	
				if (players[i])
				{
					[players[i] play];
				}
				
				didPlay = YES;
				
				//NSLog([NSString stringWithFormat:@"Playing sound %@ on players pool index %i", [soundURL path], i]);
				
				break;
			}
		}
	}
	
	return didPlay;
}

- (void)initVariables
{
	[[AVAudioSession sharedInstance]
	 setCategory: AVAudioSessionCategoryPlayback
	 error: nil];
    
    // Prepares custom recordings paths
    docFolder = [[NSString alloc] initWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
	
	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// get the current version number of SharedObjects config keys
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *objectsVersion = [userDefaults stringForKey:kSharedObjectsCurrentVersion];
	if (objectsVersion == nil)
	{
		objectsVersion = version;
		[userDefaults setObject:version forKey:kSharedObjectsCurrentVersion];
        [userDefaults setBool:TRUE forKey:kSharedObjectsScrollingActive]; // Defaults to TRUE
        [userDefaults setBool:FALSE forKey:kSharedObjectsAutostartActive]; // Defaults to FALSE
	}
    else if (![version isEqualToString:objectsVersion])
    {
        // Version has changed
        double versionNo = [version doubleValue];
        
        // if updated from 1.3 or less
        if (versionNo < 1.4)
        {
            [userDefaults setBool:TRUE forKey:kSharedObjectsScrollingActive]; // Defaults to TRUE
        }
        
        // if updated from 1.4 or less
        if (versionNo < 1.5)
        {
            [userDefaults setBool:FALSE forKey:kSharedObjectsAutostartActive]; // Defaults to FALSE
        }
        
        // Sets new version right away
        [userDefaults setObject:version forKey:kSharedObjectsCurrentVersion];
    }
    
    // add new items to custom lists if needed
    [self updateCustomLists];
	
	self.soundPlaying = NO;
	self.lastTouchedIndex = [userDefaults integerForKey:kSharedObjectsLastTouchedIndex];
	self.isPad = [[[UIApplication sharedApplication] delegate] isPad];
	self.isRetinaDisplay = [[[UIApplication sharedApplication] delegate] isRetinaDisplay];
	self.systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
	self.lastUsedLanguage = [userDefaults integerForKey:kSharedObjectsLastUsedLanguage];
    self.scrollingActive = [userDefaults boolForKey:kSharedObjectsScrollingActive];
    self.autostartActive = [userDefaults boolForKey:kSharedObjectsAutostartActive];
	
	[userDefaults synchronize];
}

- (void)saveVariables
{
	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// get the current version number of SharedObjects config keys
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:version forKey:kSharedObjectsCurrentVersion];
	[userDefaults setInteger:self.lastTouchedIndex forKey:kSharedObjectsLastTouchedIndex];
	[userDefaults setInteger:self.lastUsedLanguage forKey:kSharedObjectsLastUsedLanguage];
    [userDefaults setBool:self.scrollingActive forKey:kSharedObjectsScrollingActive];
    [userDefaults setBool:self.autostartActive forKey:kSharedObjectsAutostartActive];

	[userDefaults synchronize];		
}

- (void) updateCustomLists
{
    // We need to add new items to existing custom lists
    
    // English
    [self addNewItemsForLanguage:@"EN" inLanguageDirectory:@"English.lproj"];
    
    // French
    [self addNewItemsForLanguage:@"FR" inLanguageDirectory:@"fr.lproj"];
    
    // Espanol
    [self addNewItemsForLanguage:@"ES" inLanguageDirectory:@"es.lproj"];
}

- (void) addNewItemsForLanguage: (NSString*) languageString inLanguageDirectory:(NSString*) languageDir
{
    NSString *path = nil;
    NSString *customPath = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
	
    // Prepares paths
    path = [[NSBundle mainBundle] pathForResource:@"Slides" ofType:@"plist" inDirectory:languageDir];
    customPath = [self.docFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"Slides_%@.plist", languageString]];
    
    // Does the custom list exists?
    if ([fm fileExistsAtPath:customPath])
    {

        // If so, open both lists
        NSMutableArray* srcArray = nil;
        srcArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        
        NSMutableArray* customArray = nil;
        customArray = [[NSMutableArray alloc] initWithContentsOfFile:customPath];
        
        // Copy over the new items to the custom list if needed
        if ([customArray count] < [srcArray count])
        {
            for (NSInteger i = [customArray count]; i < [srcArray count]; i++) 
            {
                [customArray addObject:[srcArray objectAtIndex:i]];
            }
            
            // Saves updated custom list
            [customArray writeToFile:customPath atomically:YES];
        }
        
        // release ressources
        [srcArray release];
        [customArray release];
    }
}

- (void)dealloc 
{
	for (int i = 0; i < MAX_PLAYERS_NUMBER; i++)
	{
		[players[i] release];
	}
	
	[player release];
    [docFolder release];
	[super dealloc];
}


@end
