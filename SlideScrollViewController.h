//
//  SlideScrollViewController.h
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-06-22.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class SlideViewController;
@class SharedObjects;

@interface SlideScrollViewController : UIViewController {
	IBOutlet UIView *landscapeView;
	IBOutlet UIView *portraitView;
	
	IBOutlet UIScrollView *scrollView;
	IBOutlet UILabel *objectName;
	IBOutlet UIScrollView *tilesScrollView;
	
	AVAudioPlayer *player;
	
	SlideViewController *currentSlide;
	SlideViewController *nextSlide;
	
	NSMutableArray *slides;
	NSMutableArray *tileControllers;
	NSMutableArray *images;
	
	NSInteger currentSlideIndex;
	NSInteger slidesCount;
	
	BOOL initCompleted;
	NSInteger languageID;
	NSInteger maxWidth;
	NSInteger maxHeight;
	CGFloat fPageWidth;
	CGFloat fPageHeight;
	NSInteger iPageWidth;
	NSInteger iPageHeight;
	CGRect pageFrameRef;
	
	SharedObjects * sharedObjects;
	BOOL useMainPlayer;
}

@property (nonatomic, retain) NSMutableArray *slides;
@property (nonatomic, retain) NSMutableArray *tileControllers;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) SlideViewController *currentSlide;
@property (nonatomic, retain) SlideViewController *nextSlide;
@property (nonatomic, retain) IBOutlet UILabel *objectName;
@property (nonatomic, retain) IBOutlet UIView *landscapeView;
@property (nonatomic, retain) IBOutlet UIView *portraitView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *tilesScrollView;
@property (nonatomic, assign) AVAudioPlayer *player;
@property NSInteger languageID;
@property (nonatomic, retain) SharedObjects * sharedObjects;

- (void)changePage;

- (IBAction) nextButtonPressed: (id) sender;
- (IBAction) previousButtonPressed: (id) sender;
- (IBAction) playObjectName: (id) sender;

- (void) initSlidesList;
- (void) initImages;
- (void) initTilesView;
- (void) scrollToSlide: (NSInteger) slideIndex updateText:(BOOL) updateText;

@end
