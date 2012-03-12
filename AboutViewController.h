//
//  AboutViewController.h
//  SlidesScroll
//
//  Created by Mathieu Brassard on 10-10-23.
//  Copyright 2012 Mathieu Brassard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SharedObjects;
@class SplitViewController;
@class RestoreFilesListViewController;

@class DBRestClient;

@interface AboutViewController : UIViewController <UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
	IBOutlet UIView *portraitView;
    IBOutlet UIScrollView *portraitScrollView;
    
	IBOutlet UILabel *portraitCreditsLabel;
	IBOutlet UITextView *portraitCreditsTextView;
	IBOutlet UIButton *portraitGetMoreAppsButton;
	IBOutlet UIButton *portraitDoneButton;
    IBOutlet UIButton *portraitCustomizeButton;
    
    IBOutlet UILabel *portraitCardScrollingLabel;
    IBOutlet UILabel *portraitCardScrollingDetailsLabel;
    IBOutlet UISwitch *portraitCardScrollingSwitch;
    
    IBOutlet UIProgressView *dbProgress;
    IBOutlet UILabel *dropboxLabel;
    IBOutlet UIButton *dbBackupButton;
    IBOutlet UIButton *dbRestoreButton;
    IBOutlet UILabel *dbBackupingLabel;
    DBRestClient* restClient;
    IBOutlet UIButton *dbSetupButton;
    RestoreFilesListViewController* restoreFilesListViewController;
    
    IBOutlet UILabel *autoStartLabel;
    IBOutlet UILabel *autoStartDetailsLabel;
    IBOutlet UISwitch *autoStartSwitch;
    IBOutlet UIButton *autoStartSetDelay;
    IBOutlet UIButton *autoStartSetLanguage;
    IBOutlet UIButton *facebookLikeButton;
	
	NSInteger languageID;
	NSInteger maxWidth;
	NSInteger maxHeight;
	
	SharedObjects * sharedObjects;
    
    NSString* tmpZipFile;
    NSString* selectedFileForRestore;
    
    UIPopoverController *dbSetupPopover;
    UIPopoverController *dbRestorePopover;
    
    UIActionSheet *setLanguageMenuArea;  
    UIPickerView *setLanguagePickerArea;
    
    UIActionSheet *setDelayMenuArea;  
    UIPickerView *setDelayPickerArea;
}

@property(nonatomic,retain) UIActionSheet *setLanguageMenuArea;  
@property (nonatomic, retain) UIPickerView *setLanguagePickerArea;

@property(nonatomic,retain) UIActionSheet *setDelayMenuArea;  
@property (nonatomic, retain) UIPickerView *setDelayPickerArea;

@property (nonatomic, retain) IBOutlet UIView *portraitView;
@property (nonatomic, retain) IBOutlet UIScrollView *portraitScrollView;

@property (nonatomic, retain) IBOutlet UILabel *portraitCreditsLabel;
@property (nonatomic, retain) IBOutlet UITextView *portraitCreditsTextView;
@property (nonatomic, retain) IBOutlet UIButton *portraitGetMoreAppsButton;
@property (nonatomic, retain) IBOutlet UIButton *portraitDoneButton;
@property (nonatomic, retain) IBOutlet UIButton *portraitCustomizeButton;

@property (nonatomic, retain) IBOutlet UILabel *portraitCardScrollingLabel;
@property (nonatomic, retain) IBOutlet UILabel *portraitCardScrollingDetailsLabel;
@property (nonatomic, retain) IBOutlet UISwitch *portraitCardScrollingSwitch;

@property (nonatomic, retain) IBOutlet UIProgressView *dbProgress;
@property (nonatomic, retain) IBOutlet UILabel *dropboxLabel;
@property (nonatomic, retain) IBOutlet UIButton *dbBackupButton;
@property (nonatomic, retain) IBOutlet UIButton *dbRestoreButton;
@property (nonatomic, retain) IBOutlet UILabel *dbBackupingLabel;
@property (nonatomic, retain) IBOutlet UIButton *dbSetupButton;
@property (nonatomic, retain) RestoreFilesListViewController* restoreFilesListViewController;

@property (nonatomic, retain) SharedObjects * sharedObjects;

@property (nonatomic, retain) UIPopoverController *dbSetupPopover;
@property (nonatomic, retain) UIPopoverController *dbRestorePopover;

@property (nonatomic, retain) IBOutlet UILabel *autoStartLabel;
@property (nonatomic, retain) IBOutlet UILabel *autoStartDetailsLabel;
@property (nonatomic, retain) IBOutlet UISwitch *autoStartSwitch;
@property (nonatomic, retain) IBOutlet UIButton *autoStartSetDelay;
@property (nonatomic, retain) IBOutlet UIButton *autoStartSetLanguage;
@property (nonatomic, retain) IBOutlet UIButton *facebookLikeButton;

@property NSInteger languageID;
@property NSInteger maxWidth;
@property NSInteger maxHeight;

- (IBAction) GetMoreAppsButton: (id) sender;
- (IBAction) done: (id) sender;

- (IBAction) customizeCards: (id) sender;
- (IBAction) setCardScrolling: (id) sender;
- (IBAction) DropboxSetup: (id) sender;
- (IBAction) DropboxBackup: (id) sender;
- (IBAction) DropboxRestore: (id) sender;

- (IBAction) setAutostartActive: (id)sender;
- (IBAction) setAutostartTimeDelay: (id)sender;
- (IBAction) setAutostartLanguage: (id)sender;
- (IBAction) openFacebookLikeLink:(id)sender;

@end
