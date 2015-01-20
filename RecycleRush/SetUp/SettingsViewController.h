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

@end
