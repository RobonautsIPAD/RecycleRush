//
//  MatchDetailViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchTypePickerController.h"
#import "AlertPromptViewController.h"

@class DataManager;
@class MatchData;
@class TeamScore;
@class TeamData;

@protocol MatchDetailDelegate
- (void)matchDetailReturned:(BOOL)dataChange;
@end

@interface MatchDetailViewController : UIViewController <UITextFieldDelegate, AlertPromptDelegate, MatchTypePickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, strong) MatchData *match;

@property (nonatomic, weak) IBOutlet UITextField *numberTextField;
@property (nonatomic, weak) IBOutlet UITextField *red1TextField;
@property (nonatomic, weak) IBOutlet UITextField *red2TextField;
@property (nonatomic, weak) IBOutlet UITextField *red3TextField;
@property (nonatomic, weak) IBOutlet UITextField *blue1TextField;
@property (nonatomic, weak) IBOutlet UITextField *blue2TextField;
@property (nonatomic, weak) IBOutlet UITextField *blue3TextField;
@property (nonatomic, assign) id<MatchDetailDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIButton *matchTypeButton;
@property (nonatomic, strong) MatchTypePickerController *matchTypePicker;
@property (nonatomic, strong) UIPopoverController *matchTypePickerPopover;

// User Access Control
typedef enum {
    NoOverride,
    OverrideMatchTypeSelection,
    OverrideMatchNumberSelection,
} OverrideMode;

@property (nonatomic, strong) AlertPromptViewController *alertPrompt;
@property (nonatomic, strong) UIPopoverController *alertPromptPopover;

-(IBAction)MatchTypeSelectionChanged:(id)sender;
-(void)MatchTypeSelectionPopUp;
-(void)matchNumberChanged:(NSNumber *)number forMatchType:(NSString *)matchType;

-(void)checkOverrideCode;

-(TeamData *)getTeam:(int)teamNumber forTournament:(NSString *)tournament;
-(BOOL)editTeam:(int)teamNumber forScore:(TeamScore *)score;
-(BOOL)editMatch:(NSNumber *)number forMatchType:(NSString *)matchType;
-(void)setTeamField:(UITextField *)textBox forTeam:(TeamScore *)score;
-(void)setScoreData:(TeamScore *)score;

@end
