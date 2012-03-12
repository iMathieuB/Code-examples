//
//  AboutViewController.m
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-10-23.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import "AboutViewController.h"
#import "SlidesConstants.h"
#import "SharedObjects.h"
#import "LanguageListViewController.h"
#import "CardListViewController.h"
#import "SlideViewController.h"
#import "SplitViewWrapper.h"
#import "CardDetailViewController.h"
#import "DropboxSDK.h" 
#import "ConfigureDropBoxViewController.h"
#import "RestoreFilesListViewController.h"
#import "ZipArchive.h"

#define SCROLLVIEW_HEIGHT 950

@interface AboutViewController () <DBRestClientDelegate>

@property (nonatomic, readonly) DBRestClient* restClient;

@end

@implementation AboutViewController

@synthesize portraitView, languageID, maxWidth, maxHeight;
@synthesize portraitCreditsLabel, portraitCreditsTextView, portraitGetMoreAppsButton, portraitDoneButton;
@synthesize sharedObjects;
@synthesize portraitCustomizeButton;
@synthesize portraitScrollView, dbProgress, dropboxLabel, dbBackupButton, dbRestoreButton, dbBackupingLabel, dbSetupButton;
@synthesize portraitCardScrollingLabel, portraitCardScrollingDetailsLabel, portraitCardScrollingSwitch;
@synthesize dbSetupPopover, dbRestorePopover, restoreFilesListViewController;
@synthesize autoStartLabel, autoStartDetailsLabel, autoStartSetDelay, autoStartSetLanguage, autoStartSwitch, facebookLikeButton;
@synthesize setLanguageMenuArea, setLanguagePickerArea;
@synthesize setDelayMenuArea, setDelayPickerArea;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	portraitCreditsLabel.text = NSLocalizedString(@"Credits",@"Credits Label");
	portraitCreditsTextView.text = NSLocalizedString(@"CreditsList",@"Credits TextView");
	
	[portraitGetMoreAppsButton setTitle:NSLocalizedString(@"More Apps from Mathieu Brassard",@"More Apps Button")
														 forState:UIControlStateNormal];
	[portraitDoneButton setTitle:NSLocalizedString(@"Done",@"Done Button") forState:UIControlStateNormal];
    
    [portraitCustomizeButton setTitle:NSLocalizedString(@"Customize cards", @"Customize cards button") forState:UIControlStateNormal];
    
    portraitCardScrollingLabel.text = NSLocalizedString(@"Cards scrolling", @"Cards scrolling switch");
    portraitCardScrollingDetailsLabel.text = NSLocalizedString(@"If turned off, only arrows will change cards in portrait orientation.", @"Cards scrolling switch details");
    portraitCardScrollingSwitch.on = sharedObjects.scrollingActive;
    
    autoStartLabel.text = NSLocalizedString(@"Automatic start", @"Automatic start");
    autoStartDetailsLabel.text = NSLocalizedString(@"Will start automatically with specified language and delay.", @"Automatic starting details");
    [autoStartSetDelay setTitle:NSLocalizedString(@"Set time delay", @"Set automatic start time delay") forState:UIControlStateNormal];
    [autoStartSetLanguage setTitle:NSLocalizedString(@"Set language", @"Set automatic start language") forState:UIControlStateNormal];
    [facebookLikeButton setTitle:NSLocalizedString(@"Like this on Facebook", @"Facebook like button") forState:UIControlStateNormal];
    autoStartSwitch.on = sharedObjects.autostartActive;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self willAnimateRotationToInterfaceOrientation:currentOrientation duration:0];
    
    // Adds a "Done" button at the top right
    UIBarButtonItem *doneBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done",@"Done Button") style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
    
    [self.navigationItem setRightBarButtonItem:doneBarButtonItem animated:YES];
    [doneBarButtonItem release];
    
    // Adjust view frame sizes for iPhone only
    if (!sharedObjects.isPad)
    {
        CGRect viewFrame = self.portraitView.frame; 
        viewFrame.size.height = SCROLLVIEW_HEIGHT;
        self.portraitScrollView.contentSize = viewFrame.size;
        viewFrame.size.height = 436;
        self.portraitView.frame = viewFrame;
        self.portraitScrollView.frame = viewFrame;
        
        //viewFrame = self.landscapeView.frame;
        //viewFrame.size.height = 500;
        //self.landscapeScrollView.contentSize = viewFrame.size;
        //viewFrame.size.height = 288;
        //self.landscapeView.frame = viewFrame;
        //self.landscapeScrollView.frame = viewFrame;
    }
    
    dbProgress.hidden = YES;
    dropboxLabel.text = NSLocalizedString(@"Dropbox Backup", @"Dropbox Backup");
    dbBackupingLabel.text = NSLocalizedString(@"Backuping...", @"Backuping... label");
    dbBackupingLabel.hidden = YES;
    [dbBackupButton setTitle:NSLocalizedString(@"Backup",@"Backup Button") forState:UIControlStateNormal];
    [dbRestoreButton setTitle:NSLocalizedString(@"Restore",@"Restore Button") forState:UIControlStateNormal];    
    
    if (sharedObjects.isPad)
    {
        ConfigureDropBoxViewController* configureDBViewController = [[ConfigureDropBoxViewController alloc] initWithNibName:
                                                                     @"ConfigureDropBoxViewController" bundle:nil];
        UINavigationController *navCon = [[UINavigationController alloc]	initWithRootViewController:configureDBViewController]; 
        configureDBViewController.needDoneButton = NO;
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navCon];
        [popover setPopoverContentSize:CGSizeMake(320, 320) animated:NO];
        self.dbSetupPopover = popover;

        [configureDBViewController release];
        [navCon release];
        [popover release];
        
        
        restoreFilesListViewController = [[RestoreFilesListViewController alloc] initWithNibName:
                                                                          @"RestoreFilesListViewController" bundle:nil];
        navCon = [[UINavigationController alloc]	initWithRootViewController:restoreFilesListViewController]; 
        restoreFilesListViewController.needDoneButton = NO;
        restoreFilesListViewController.sharedObjects = self.sharedObjects;
        
        popover = [[UIPopoverController alloc] initWithContentViewController:navCon];
        [popover setPopoverContentSize:CGSizeMake(320, 650) animated:NO];
        self.dbRestorePopover = popover;
        restoreFilesListViewController.parentPopover = popover;
        
        [navCon release];
        [popover release];
    }
    
    setLanguageMenuArea = [[UIActionSheet alloc] initWithTitle:nil  delegate:self
                                  cancelButtonTitle:@"Done"  
                             destructiveButtonTitle:nil
                                  otherButtonTitles:nil];  
    
    // Add the picker  
    setLanguagePickerArea = [[UIPickerView alloc] initWithFrame:CGRectMake(0,84,320,216)];  
    
    setLanguagePickerArea.delegate = self;  
    setLanguagePickerArea.showsSelectionIndicator = YES;    // note this is default to NO  
    [setLanguageMenuArea addSubview:setLanguagePickerArea];  
    
    setDelayMenuArea = [[UIActionSheet alloc] initWithTitle:nil  delegate:self
                                             cancelButtonTitle:@"Done"  
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:nil];  
    
    // Add the picker  
    setDelayPickerArea = [[UIPickerView alloc] initWithFrame:CGRectMake(0,84,320,216)];  
    
    setDelayPickerArea.delegate = self;  
    setDelayPickerArea.showsSelectionIndicator = YES;    // note this is default to NO
    [setDelayMenuArea addSubview:setDelayPickerArea];  
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (sharedObjects.systemVersion < 3.2)
	{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	else {
		return YES;
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

...

@end
