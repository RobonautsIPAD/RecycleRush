//
//  AddMatchViewController.h
// Robonauts Scouting
//
//  Created by FRC on 2/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class MatchData;

@interface AddMatchViewController : UIViewController <UIPopoverControllerDelegate, UITableViewDelegate, UITextFieldDelegate, PopUpPickerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSString *tournamentName;
@property (nonatomic, strong) MatchData *match;

@end
