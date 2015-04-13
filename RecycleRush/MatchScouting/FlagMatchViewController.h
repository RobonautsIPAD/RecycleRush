//
//  FlagMatchViewController.h
//  RecycleRush
//
//  Created by FRC on 3/28/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class TeamScore;

@interface FlagMatchViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamScore *currentScore;

@end
