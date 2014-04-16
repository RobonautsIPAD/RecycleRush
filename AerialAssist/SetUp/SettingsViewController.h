//
//  TournamentViewController.h
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"
#import "AlertPromptViewController.h"

@class DataManager;

@interface SettingsViewController : UIViewController <PopUpPickerDelegate, AlertPromptDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, weak) IBOutlet UIImageView *mainLogo;
@property (nonatomic, weak) IBOutlet UIImageView *splashPicture;
@property (nonatomic, weak) IBOutlet UILabel *pictureCaption;
@property (nonatomic, weak) IBOutlet UITextField *adminText;
@property (nonatomic, weak) IBOutlet UITextField *overrideText;
@property (nonatomic, weak) IBOutlet UILabel *tournamentLabel;
@property (nonatomic, weak) IBOutlet UILabel *allianceLabel;
@property (nonatomic, weak) IBOutlet UILabel *adminLabel;
@property (nonatomic, weak) IBOutlet UILabel *overideLabel;
@property (nonatomic, weak) IBOutlet UILabel *modeLabel;
@property (nonatomic, weak) IBOutlet UILabel *bluetoothLabel;

// Tournament Picker
@property (nonatomic, weak) IBOutlet UIButton *tournamentButton;
@property (nonatomic, strong) NSMutableArray *tournamentList;
@property (nonatomic, strong) NSArray *tournamentData;
@property (nonatomic, strong) PopUpPickerViewController *tournamentPicker;
@property (nonatomic, strong) UIPopoverController *tournamentPickerPopover;
-(IBAction)TournamentSelectionChanged:(id)sender;
- (void)tournamentSelected:(NSString *)newTournament;

// Alliance Picker
@property (nonatomic, weak) IBOutlet UIButton *allianceButton;
@property (nonatomic, strong) NSMutableArray *allianceList;
@property (nonatomic, strong) PopUpPickerViewController *alliancePicker;
@property (nonatomic, strong) UIPopoverController *alliancePickerPopover;
-(void)allianceSelectionPopUp;
-(IBAction)allianceSelectionChanged:(id)sender;
- (void)allianceSelected:(NSString *)newAlliance;

// Mode Selection
@property (nonatomic, weak) IBOutlet UISegmentedControl *modeSegment;
- (IBAction)modeSelectionChanged:(id)sender;

// User Access Control
typedef enum {
    NoOverride,
    OverrideAllianceSelection,
} OverrideMode;
@property (nonatomic, strong) AlertPromptViewController *alertPrompt;
@property (nonatomic, strong) UIPopoverController *alertPromptPopover;

-(void)checkAdminCode:(UIButton *)button;
- (NSString *)applicationDocumentsDirectory;


@end
