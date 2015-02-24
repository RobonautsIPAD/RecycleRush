//
//  TeamSummaryViewController.h
//  RecycleRush
//
//  Created by FRC on 2/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"
@class DataManager;
@class TeamData;

@interface TeamSummaryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPopoverControllerDelegate, PopUpPickerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSArray *teamList;
@property (nonatomic, strong) TeamData *initialTeam;
@property (nonatomic, strong) NSNumber *matchNumber;
@end
