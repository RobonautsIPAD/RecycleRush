//
//  RidleyPageViewController.h
//  AerialAssist
//
//  Created by FRC on 1/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpPickerViewController.h"

@class DataManager;
@class TeamData;

@interface RidleyPageViewController : UIViewController <PopUpPickerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) DataManager *dataManager;

@property (nonatomic, weak) IBOutlet UIButton *first;
@property (nonatomic, weak) IBOutlet UIButton *second;
@property (nonatomic, weak) IBOutlet UIButton *third;

@property (nonatomic, weak) IBOutlet UITableView *firstListTable;
@property (nonatomic, weak) IBOutlet UITableView *secondListTable;
@property (nonatomic, weak) IBOutlet UITableView *thirdListTable;

@property (nonatomic, strong) PopUpPickerViewController *firstPicker;
@property (nonatomic, strong) UIPopoverController *firstPickerPopover;

@property (nonatomic, strong) PopUpPickerViewController *secondPicker;
@property (nonatomic, strong) UIPopoverController *secondPickerPopover;

@property (nonatomic, strong) PopUpPickerViewController *thirdPicker;
@property (nonatomic, strong) UIPopoverController *thirdPickerPopover;

@property (nonatomic, strong) NSMutableArray *teamList;
@property (nonatomic, strong) NSMutableArray *firstTeamList;
@property (nonatomic, strong) NSMutableArray *secondTeamList;
@property (nonatomic, strong) NSMutableArray *thirdTeamList;

@property (nonatomic, strong) TeamData *team;
@property (nonatomic, strong) NSArray *teamData;

-(IBAction)showTeamPopUp:(id)sender;


@end
