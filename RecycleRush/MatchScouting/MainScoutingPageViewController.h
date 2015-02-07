//
//  MainScoutingPageViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertPromptViewController.h"
#import "ValuePromptViewController.h"
#import "PopUpPickerViewController.h"

@class DataManager;

@interface MainScoutingPageViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, AlertPromptDelegate, ValuePromptDelegate, UIActionSheetDelegate, PopUpPickerDelegate> {
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
}

@property (nonatomic, strong) DataManager *dataManager;

// User Access Control
typedef enum {
    NoOverride,
	OverrideDrawLock,
    OverrideMatchReset,
    OverrideAllianceSelection,
    OverrideTeamSelection,
} OverrideMode;

@property (nonatomic, strong) AlertPromptViewController *alertPrompt;
@property (nonatomic, strong) UIPopoverController *alertPromptPopover;
@property (nonatomic, assign) OverrideMode overrideMode;

// Match Scores

@property (nonatomic, strong) ValuePromptViewController *valuePrompt;
@property (nonatomic, strong) UIPopoverController *valuePromptPopover;

// Match Drawing
typedef enum {
	DrawOff,
	DrawAuton,
	DrawTeleop,
    DrawDefense,
    DrawLock,
} DrawingMode;

@end
