//
//  FlagViewController.h
//  RecycleRush
//
//  Created by Austin on 4/15/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;
@class TeamScore;

@interface FlagViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamScore *currentScore;

@end
