//
//  MatchDrawingViewController.h
//  RecycleRush
//
//  Created by FRC on 2/22/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class TeamScore;

@interface MatchDrawingViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamScore *score;
@end
