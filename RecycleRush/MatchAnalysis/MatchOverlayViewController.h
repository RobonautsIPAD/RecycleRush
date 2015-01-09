//
//  MatchOverlayViewController.h
//  RecycleRush
//
//  Created by FRC on 3/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//
@class DataManager;
@class TeamData;

#import <UIKit/UIKit.h>

@interface MatchOverlayViewController :UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *matchList;
@property (nonatomic, strong) TeamData *numberTeam;
@property (nonatomic, strong) DataManager *dataManager;

@end
