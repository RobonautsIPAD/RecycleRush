//
//  MatchDetailViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"
#import "AlertPromptViewController.h"

@class DataManager;
@class MatchData;
@class TeamScore;
@class TeamData;

@protocol MatchDetailDelegate
- (void)matchDetailReturned:(BOOL)dataChange;
@end

@interface MatchDetailViewController : UIViewController <UITextFieldDelegate, AlertPromptDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) MatchData *match;

@property (nonatomic, assign) id<MatchDetailDelegate> delegate;

// User Access Control
typedef enum {
    NoOverride,
    OverrideMatchTypeSelection,
    OverrideMatchNumberSelection,
} OverrideMode;

@property (nonatomic, strong) AlertPromptViewController *alertPrompt;
@property (nonatomic, strong) UIPopoverController *alertPromptPopover;

-(void)checkOverrideCode;

//-(void)setScoreData:(TeamScore *)score;

@end
