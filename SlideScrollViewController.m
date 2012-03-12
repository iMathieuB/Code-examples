//
//  SlideScrollViewController.m
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-06-22.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import "SlideScrollViewController.h"
#import "SlidesConstants.h"
#import "SlideViewController.h"
#import "SharedObjects.h"

@implementation SlideScrollViewController

@synthesize slides, objectName, languageID, scrollView, landscapeView, portraitView, tilesScrollView, tileControllers;
@synthesize player, images, currentSlide, nextSlide, sharedObjects;


- (void)applyNewIndex:(NSInteger)newIndex slideController:(SlideViewController *)slideController
{
	BOOL outOfBounds = newIndex >= slidesCount || newIndex < 0;
	
	if (!outOfBounds)
	{
		CGRect pageFrame = pageFrameRef;
		pageFrame.origin.y = 0;
		pageFrame.origin.x = maxWidth * (newIndex + 1);
		slideController.view.frame = pageFrame;
	}
	else
	{
		if (newIndex < 0) {
			newIndex = slidesCount - 1;
			CGRect pageFrame = pageFrameRef;
			pageFrame.origin.y = 0;
			pageFrame.origin.x = 0;
			slideController.view.frame = pageFrame;			
		}
		else {
			newIndex = 0;
			CGRect pageFrame = pageFrameRef;
			pageFrame.origin.y = 0;
			pageFrame.origin.x = maxWidth * (slidesCount + 1);
			slideController.view.frame = pageFrame;
		}		
	}
	
	if (slideController.slideIndex != newIndex)
	{
		NSString *imageFileName = nil;
		slideController.slideIndex = newIndex;
		
		if (self.sharedObjects.isPad)
		{
			imageFileName = [NSString stringWithFormat:@"%@_1.177.jpg", 
							 [[self.slides objectAtIndex:newIndex] objectForKey:IMAGE_KEY]];
		}
		else
		{
			if (self.sharedObjects.isRetinaDisplay)
			{
				// iPod or iPhone with retina display
				imageFileName = [NSString stringWithFormat:@"%@_1.297.jpg", 
												 [[self.slides objectAtIndex:newIndex] objectForKey:IMAGE_KEY]];
			}
			else
			{
			  if (TILES_RATIO == 1.17708333)
			  {
				imageFileName = [NSString stringWithFormat:@"%@_320x415.jpg", 
												 [[self.slides objectAtIndex:newIndex] objectForKey:IMAGE_KEY]];
			  }
			  else
			  {
			     imageFileName = [NSString stringWithFormat:@"%@_small.jpg", 
												 [[self.slides objectAtIndex:newIndex] objectForKey:IMAGE_KEY]];
			  }
			}
		}
	
		slideController.objectImage.image = [UIImage imageNamed:imageFileName];
		slideController.objectSoundFileName = [[self.slides objectAtIndex:newIndex] objectForKey:SOUND_KEY];
	}
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	initCompleted = NO;
	
	useMainPlayer = NO;
	
	[self initSlidesList];
	
	[self initImages];
	
	// Initialize device related variables
	maxWidth = self.view.frame.size.width;
	maxHeight = self.view.frame.size.height;
	
	// Initialize tiles view
	[self initTilesView];
	
	// Initialize portrait view slides
	
	currentSlideIndex = 0;
	objectName.text = [[[self.slides objectAtIndex:currentSlideIndex] objectForKey:TEXT_KEY] uppercaseString];
	
	if (self.sharedObjects.isPad)
	{
		currentSlide = [[SlideViewController alloc] initWithNibName:@"SlideViewController_iPad" bundle:nil];
		nextSlide = [[SlideViewController alloc] initWithNibName:@"SlideViewController_iPad" bundle:nil];

	}
	else
	{
		currentSlide = [[SlideViewController alloc] initWithNibName:@"SlideViewController" bundle:nil];
		nextSlide = [[SlideViewController alloc] initWithNibName:@"SlideViewController" bundle:nil];
	}
	
	[scrollView addSubview:currentSlide.view];
	[scrollView addSubview:nextSlide.view];
	currentSlide.slideIndex = -1;
	nextSlide.slideIndex = -1;
	currentSlide.sharedObjects = self.sharedObjects;
	nextSlide.sharedObjects = self.sharedObjects;
	currentSlide.useMainPlayer = NO;
	nextSlide.useMainPlayer = NO;
	currentSlide.usePlayerPool = NO;
	nextSlide.usePlayerPool = NO;
	
	NSInteger widthCount = slidesCount + 2;
	if (widthCount == 0)
	{
		widthCount = 1;
	}
	
	NSInteger viewWidth = scrollView.frame.size.width;
	fPageWidth = scrollView.frame.size.width;
	fPageHeight = scrollView.frame.size.height;
	iPageWidth = scrollView.frame.size.width;
	iPageHeight = scrollView.frame.size.height;
	
	pageFrameRef = currentSlide.view.frame;
	
	scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * widthCount,
																			scrollView.frame.size.height);
	scrollView.contentOffset = CGPointMake(viewWidth, 0);
	scrollView.showsHorizontalScrollIndicator = NO;
	
	[self applyNewIndex:sharedObjects.lastTouchedIndex slideController:currentSlide];
	[self applyNewIndex:(sharedObjects.lastTouchedIndex + 1) slideController:nextSlide];
	[self scrollToSlide:sharedObjects.lastTouchedIndex updateText:YES];
	
	UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
	
	if (self.sharedObjects.systemVersion < 3.2) 
	{
		if ((currentOrientation == UIInterfaceOrientationLandscapeLeft)
			|| (currentOrientation == UIInterfaceOrientationLandscapeRight))
    {
			self.view = self.landscapeView;
		}			
	}
    
    scrollView.scrollEnabled = sharedObjects.scrollingActive;
	 
	initCompleted = YES;
}

#pragma mark -
#pragma mark AutoRotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)
interfaceOrientation duration:(NSTimeInterval)duration {	
    if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
				self.view = self.portraitView;
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
        self.view.bounds = CGRectMake(0.0, 0.0, maxWidth, maxHeight);	
			  [self scrollToSlide:sharedObjects.lastTouchedIndex updateText:YES];
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        self.view = self.landscapeView;
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(-90));
        self.view.bounds = CGRectMake(0.0, 0.0, maxHeight, maxWidth);
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
			  self.view = self.portraitView;
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(180));
        self.view.bounds = CGRectMake(0.0, 0.0, maxWidth, maxHeight);
			  [self scrollToSlide:sharedObjects.lastTouchedIndex updateText:YES];
    }
    else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.view = self.landscapeView;
        self.view.transform = CGAffineTransformIdentity;
        self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
        self.view.bounds = CGRectMake(0.0, 0.0, maxHeight, maxWidth);
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.objectName = nil;
	self.landscapeView = nil;
	self.portraitView = nil;
	self.scrollView = nil;
	self.tilesScrollView = nil;
}

#pragma mark -
#pragma mark Slides and Tiles initialization

- (void) initSlidesList
{
	NSString *path = nil;
    NSString *customPath = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
	
	switch (languageID) {
		case ENGLISH_LANGUAGE:
			path = [[NSBundle mainBundle] pathForResource:@"Slides" ofType:@"plist" inDirectory:@"English.lproj"];
            customPath = [sharedObjects.docFolder stringByAppendingPathComponent:@"Slides_EN.plist"];
			break;
			
		case FRENCH_LANGUAGE:
			path = [[NSBundle mainBundle] pathForResource:@"Slides" ofType:@"plist" inDirectory:@"fr.lproj"];
			customPath = [sharedObjects.docFolder stringByAppendingPathComponent:@"Slides_FR.plist"];
			break;
            
        case SPANISH_LANGUAGE:
			path = [[NSBundle mainBundle] pathForResource:@"Slides" ofType:@"plist" inDirectory:@"es.lproj"];
			customPath = [sharedObjects.docFolder stringByAppendingPathComponent:@"Slides_ES.plist"];
			break;
			
		case DEFAULT_LANGUAGE:
		default:
            customPath = [sharedObjects.docFolder stringByAppendingPathComponent:@"Slides.plist"];
			path = [[NSBundle mainBundle] pathForResource:@"Slides" ofType:@"plist"];		
			break;
	}
	
	NSMutableArray* tmpArray = nil;
    if ([fm fileExistsAtPath:customPath])
    {
        tmpArray = [[NSMutableArray alloc] initWithContentsOfFile:customPath];
    }
    else
    {
        //Stick to the original slide.plist from bundle
        tmpArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
	
	NSSortDescriptor *sort=[[NSSortDescriptor alloc] initWithKey:TEXT_KEY ascending:YES];
	[tmpArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    // Removes all slides that must be hidden
    for (int i = [tmpArray count] - 1; i >= 0; i--) 
	{
        if ([[[tmpArray objectAtIndex:i] objectForKey:HIDE_KEY] boolValue] == YES)
        {
            [tmpArray removeObjectAtIndex:i];
        }
    }
	
	self.slides = tmpArray;
	slidesCount = [self.slides count];
	
	[tmpArray release];
	[sort release];
}

- (void) initImages
{
	images = [[NSMutableArray alloc] init];
	
	NSString *imageFileName;
	for (int i = 0; i < [self.slides count]; i++) 
	{
		if (self.sharedObjects.isPad)
		{
			imageFileName = [NSString stringWithFormat:@"%@_small.jpg", 
							 [[self.slides objectAtIndex:i] objectForKey:IMAGE_KEY]];	
		}
		else
		{
			if (self.sharedObjects.isRetinaDisplay)
			{
					imageFileName = [NSString stringWithFormat:@"%@_small.jpg", 
							 [[self.slides objectAtIndex:i] objectForKey:IMAGE_KEY]];	
			}
			else 
			{
				imageFileName = [NSString stringWithFormat:@"%@_verysmall.jpg", 
												 [[self.slides objectAtIndex:i] objectForKey:IMAGE_KEY]];	
			}

		}
		
		UIImage* image = [UIImage imageNamed:imageFileName];
		
		if (image == nil)
		{
			NSLog(@"Unable to load image:");
			NSLog(imageFileName);
		}
		
		[images addObject:image];
	}
}

- (void) initTilesView
{
	NSInteger viewWidth = tilesScrollView.frame.size.width;
	NSInteger heightMultiple = slidesCount / TILES_PER_ROW;
	NSInteger imageWidth = viewWidth / TILES_PER_ROW;
	NSInteger imageHeight = imageWidth * TILES_RATIO;
	
	// Temporary adjustment
	if ((slidesCount % TILES_PER_ROW) != 0)
	{
		heightMultiple++;
	}
	
	tilesScrollView.contentSize = CGSizeMake(viewWidth, heightMultiple * imageHeight);
	tilesScrollView.showsVerticalScrollIndicator = NO;
	
	tileControllers = [[NSMutableArray alloc] init];
	
	NSInteger originX = 0;
	NSInteger originY = 0;
	for (int i = 0; i < slidesCount; i++) 
	{
		SlideViewController *imageTileController = [[SlideViewController alloc] initWithNibName:@"SlideViewController" bundle:nil];
		[tilesScrollView addSubview:imageTileController.view];
		[tileControllers addObject:imageTileController];
		imageTileController.slideIndex = i;
		imageTileController.useMainPlayer = NO;
		imageTileController.usePlayerPool = YES;
		imageTileController.sharedObjects = self.sharedObjects;
		imageTileController.objectImage.image = [images objectAtIndex:i];
		imageTileController.objectSoundFileName = [[self.slides objectAtIndex:i] objectForKey:SOUND_KEY];		
		originX = imageWidth * (i % TILES_PER_ROW);
		originY = imageHeight * (i / TILES_PER_ROW);
		imageTileController.objectImage.frame = CGRectMake(0, 0, imageWidth, imageHeight);
		imageTileController.objectButton.frame = CGRectMake(0, 0, imageWidth, imageHeight); 
		imageTileController.view.frame = CGRectMake(originX, originY, imageWidth, imageHeight);
		[imageTileController release];
	}	
}

#pragma mark -
#pragma mark Scrolling management

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
	if ((!initCompleted) || (sender != scrollView))
	{
		// We don't want scrolling during initialization phase
		return;
	}
	
    float fractionalPage = (scrollView.contentOffset.x / fPageWidth) - 1;
	
	NSInteger lowerNumber = floor(fractionalPage);
	NSInteger upperNumber = lowerNumber + 1;
	
	if (lowerNumber == currentSlide.slideIndex)
	{
		if (upperNumber != nextSlide.slideIndex)
		{
			[self applyNewIndex:upperNumber slideController:nextSlide];
		}
	}
	else if (upperNumber == currentSlide.slideIndex)
	{
		if (lowerNumber != nextSlide.slideIndex)
		{
			[self applyNewIndex:lowerNumber slideController:nextSlide];
		}
	}
	else
	{
		if (lowerNumber == nextSlide.slideIndex)
		{
			[self applyNewIndex:upperNumber slideController:currentSlide];
		}
		else if (upperNumber == nextSlide.slideIndex)
		{
			[self applyNewIndex:lowerNumber slideController:currentSlide];
		}
		else
		{
			[self applyNewIndex:lowerNumber slideController:currentSlide];
			[self applyNewIndex:upperNumber slideController:nextSlide];
		}
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)theScrollView
{
	if (theScrollView == scrollView)
	{
		float fractionalPage = (scrollView.contentOffset.x / fPageWidth) - 1;
		NSInteger nearestNumber = lround(fractionalPage);
		BOOL bNeedsScrollUpdate = NO;
		
		if (nearestNumber == -1) 
		{
			nearestNumber = (slidesCount - 1);
			bNeedsScrollUpdate = YES;
		}
		if (nearestNumber == slidesCount) 
		{
			nearestNumber = 0;
			bNeedsScrollUpdate = YES;
		}
		
		if (bNeedsScrollUpdate) {
			// update the scroll view to the real page
			[self scrollToSlide:nearestNumber updateText:NO];
		}
		
		if (currentSlide.slideIndex != nearestNumber)
		{
			SlideViewController *swapController = currentSlide;
			currentSlide = nextSlide;
			nextSlide = swapController;
		}
		
		objectName.text = [[[self.slides objectAtIndex:nearestNumber] objectForKey:TEXT_KEY] uppercaseString];
		currentSlideIndex = nearestNumber;
		sharedObjects.lastTouchedIndex = nearestNumber;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)newScrollView
{
	[self scrollViewDidEndScrollingAnimation:newScrollView];
}

- (void) scrollToSlide: (NSInteger) slideIndex updateText:(BOOL) updateText
{
	if (currentSlideIndex == slideIndex)
	{
		return;
	}
	
	// update the scroll view to the real page
	[self applyNewIndex:slideIndex slideController:currentSlide];
	
	[scrollView scrollRectToVisible:CGRectMake(iPageWidth * (slideIndex + 1), 0, iPageWidth, iPageHeight) animated:NO];
	
	if (updateText)
	{
		objectName.text = [[[self.slides objectAtIndex:slideIndex] objectForKey:TEXT_KEY] uppercaseString];
		currentSlideIndex = slideIndex;
	}
}

- (void)changePage {
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * (currentSlideIndex + 1);
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction) nextButtonPressed: (id) sender{
	currentSlideIndex = (currentSlideIndex + 1) % (slidesCount + 2);
	sharedObjects.lastTouchedIndex = currentSlideIndex;
	[self changePage];
}

- (IBAction) previousButtonPressed: (id) sender{
	currentSlideIndex = (currentSlideIndex - 1);
	sharedObjects.lastTouchedIndex = currentSlideIndex;
	[self changePage];
}

- (IBAction) playObjectName: (id) sender {
	
	
	// We verify if already playing a sound
	if ((useMainPlayer && self.sharedObjects.player.playing) || (self.player.playing))
	{
		return;
	}
	
	
	NSLog(@"Will play object name diction.");
	int indexSlide = currentSlideIndex;
	
	// Protection for borders of array
	if (indexSlide < 0)
	{
		indexSlide = slidesCount - 1;
	}
	if (indexSlide > (slidesCount - 1))
	{
		indexSlide = 0;
	}
	
	// Stops and release player prior to playing another sound
	if (useMainPlayer && self.sharedObjects.player)
	{
		[self.sharedObjects.player stop];
		[self.sharedObjects.player release];
	}
	else if (self.player)
	{
		[player stop];
		[player release];
	}
	
    NSURL *fileURL = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL* customRecording = [[NSURL alloc] initFileURLWithPath:[sharedObjects.docFolder stringByAppendingPathComponent:
                                 [NSString stringWithFormat:AUDIO_RECORDING_FILE_EXTENSION, 
                                  [[self.slides objectAtIndex:indexSlide] objectForKey:DICTION_KEY]]]];
    if ([fm fileExistsAtPath:[customRecording path]])
    {
        fileURL = customRecording;
    }
    else
    {
        [customRecording release];
        
        // Loads the sound file
        NSString *objectDictionFileName = [[self.slides objectAtIndex:indexSlide] objectForKey:DICTION_KEY];
        fileURL = [[NSURL alloc] initFileURLWithPath: 
                   [[NSBundle mainBundle] pathForResource:objectDictionFileName ofType:@"m4a"]];
    }

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
	
	[fileURL release];
}



- (void)dealloc {
	[scrollView release];
	[currentSlide release];
	[nextSlide release];
	[slides release];
	[objectName release];
	[player release];
	[landscapeView release];
	[portraitView release];
	[tilesScrollView release];
	[tileControllers release];
	[images release];
	[sharedObjects release];
	[super dealloc];
}


@end
