//
//  MatchScoutingViewController.h
//  RecycleRush
//
//  Created by FRC on 2/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;

@interface MatchScoutingViewController : UIViewController <NSFetchedResultsControllerDelegate, UITextFieldDelegate, UIActionSheetDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@end
