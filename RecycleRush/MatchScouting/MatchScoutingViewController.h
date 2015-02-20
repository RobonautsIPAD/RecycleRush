//
//  MatchScoutingViewController.h
//  RecycleRush
//
//  Created by FRC on 2/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"
#import "AlertPromptViewController.h"

@class DataManager;

@interface MatchScoutingViewController : UIViewController <NSFetchedResultsControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, PopUpPickerDelegate, AlertPromptDelegate>
@property (nonatomic, strong) DataManager *dataManager;

// Match Drawing
typedef enum {
	DrawOff,
	DrawInput,
    DrawLock,
} DrawingMode;

@end
