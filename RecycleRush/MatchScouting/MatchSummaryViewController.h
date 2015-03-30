//
//  MatchSummaryViewController.h
//  RecycleRush
//
//  Created by FRC on 1/24/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class TeamScore;

@interface MatchSummaryViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamScore *score;

@end
