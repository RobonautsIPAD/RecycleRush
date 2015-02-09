//
//  TeamSummaryViewController.h
//  RecycleRush
//
//  Created by FRC on 2/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class TeamData;

@interface TeamSummaryViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamData *team;
@end
