//
//  SharedObjects.h
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-10-11.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SlidesConstants.h"


@interface SharedObjects : NSObject {
	BOOL soundPlaying;
	AVAudioPlayer *player;
	AVAudioPlayer *players[MAX_PLAYERS_NUMBER];
	NSInteger playersCount;
	NSInteger lastTouchedIndex;
	NSInteger lastUsedLanguage;
	BOOL isPad;
	BOOL isRetinaDisplay;
    BOOL scrollingActive;
    BOOL autostartActive;
	float systemVersion;
    NSString* docFolder;
}

- (BOOL) playSoundWithAvailablePlayer: (NSURL*) soundURL;
- (void) initVariables;
- (void) saveVariables;
- (void) updateCustomLists;
- (void) addNewItemsForLanguage: (NSString*) languageString inLanguageDirectory:(NSString*) languageDir;

@property BOOL soundPlaying;
@property BOOL isPad;
@property BOOL isRetinaDisplay;
@property BOOL scrollingActive;
@property BOOL autostartActive;
@property (nonatomic, retain) NSString* docFolder;
@property float systemVersion;
@property NSInteger lastTouchedIndex;
@property NSInteger lastUsedLanguage;
@property (nonatomic, assign) AVAudioPlayer *player;

@end
