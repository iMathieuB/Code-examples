//
//  SlideViewController.h
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-06-21.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class SharedObjects;

@interface SlideViewController : UIViewController {
	NSInteger slideIndex;
	IBOutlet UIImageView *objectImage;
	IBOutlet UIButton *objectButton;
	AVAudioPlayer *player;
	NSString *objectSoundFileName;
	NSTimer* myTimer;
	SharedObjects * sharedObjects;
	BOOL useMainPlayer;
	BOOL usePlayerPool;
}

@property NSInteger slideIndex;
@property (nonatomic, retain) IBOutlet UIImageView *objectImage;
@property (nonatomic, retain) IBOutlet UIButton *objectButton;
@property (nonatomic, assign) AVAudioPlayer *player;
@property (nonatomic, retain) NSString *objectSoundFileName;
@property (nonatomic, retain) SharedObjects * sharedObjects;
@property BOOL useMainPlayer;
@property BOOL usePlayerPool;

- (IBAction) playObjectSound: (id) sender;

@end
