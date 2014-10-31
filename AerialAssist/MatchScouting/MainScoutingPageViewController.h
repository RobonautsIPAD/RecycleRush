//
//  MainScoutingPageViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DefensePickerController.h"
#import "AlertPromptViewController.h"
#import "ValuePromptViewController.h"
#import "PopUpPickerViewController.h"

@class DataManager;

@interface MainScoutingPageViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, DefensePickerDelegate, PopUpPickerDelegate, AlertPromptDelegate, ValuePromptDelegate, UIActionSheetDelegate, PopUpPickerDelegate> {
    
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


@property (nonatomic, strong) PopUpPickerViewController *scoreButtonReset;
@property (nonatomic, strong) UIPopoverController *scoreButtonPickerPopover;
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


@property (nonatomic, strong) NSMutableArray *defenseList;
@property (nonatomic, strong) DefensePickerController *defensePicker;
@property (nonatomic, strong) UIPopoverController *defensePickerPopover;
@property (nonatomic, assign) int popCounter;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic, assign) DrawingMode drawMode;


@end
