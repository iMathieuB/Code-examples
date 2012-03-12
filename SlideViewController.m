//
//  SlideViewController.m
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-06-21.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import "SlideViewController.h"
#import "SharedObjects.h"

@implementation SlideViewController

@synthesize objectImage, objectButton, slideIndex;
@synthesize player, sharedObjects, useMainPlayer, usePlayerPool;
@synthesize objectSoundFileName;


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction) playObjectSound: (id) sender {
	BOOL didPlay = NO;
	
	self.sharedObjects.lastTouchedIndex = self.slideIndex;
	
	if (!usePlayerPool)
	{
		// We verify if already playing a sound
		//if ((useMainPlayer && self.sharedObjects.player.playing) || (player.playing))
		if (useMainPlayer && self.sharedObjects.player.playing)
		{
			return;
		}
	
		// Stops and release player prior to playing another sound
		if (useMainPlayer && self.sharedObjects.player)
		{
			[self.sharedObjects.player stop];
			[self.sharedObjects.player release];
		}
		else if (self.player)
		{
			[self.player stop];
			[self.player release];
		}
	}
	
	// Loads the sound file
	NSString *pathForSoundFile = [[NSBundle mainBundle] pathForResource:self.objectSoundFileName ofType:@"m4a"];
	
	if (pathForSoundFile != nil)
	{
        NSURL *fileURL = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL* customRecording = [[NSURL alloc] initFileURLWithPath:[sharedObjects.docFolder stringByAppendingPathComponent:
                                                                     [NSString stringWithFormat:AUDIO_RECORDING_FILE_EXTENSION, 
                                                                      self.objectSoundFileName]]];
        if ([fm fileExistsAtPath:[customRecording path]])
        {
            fileURL = customRecording;
        }
        else
        {
            [customRecording release];
            fileURL = [[NSURL alloc] initFileURLWithPath:pathForSoundFile];
        }
		
		if (usePlayerPool)
		{
			didPlay = [self.sharedObjects playSoundWithAvailablePlayer:fileURL];
		}
		else
		{
			if (useMainPlayer)
			{
				self.sharedObjects.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];	
				if (self.sharedObjects.player)
				{
					[self.sharedObjects.player play];
				}
			}
			else 
			{
				self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];	
				if (self.player)
				{
					[player play];
				}
			}
		}
		
		[fileURL release];
		
		if ((!usePlayerPool) || (usePlayerPool && didPlay))
		{
			self.objectImage.alpha = 0.85;
			
			// start the timer
			if (myTimer != nil)
			{
				[myTimer release];
				myTimer = nil;
			}
			
			myTimer = [[NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO] retain];
			[[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSDefaultRunLoopMode];		
		}
	}	
}

- (void)timerFired:(NSTimer *)timer
{
	objectImage.alpha = 1;
}

- (void)dealloc {
	[objectImage release];
	[objectButton release];
	[player release];
	[objectSoundFileName release];
	[myTimer release];
	[sharedObjects release];
	[super dealloc];
}


@end
