//
//  DetailScrollViewController.h
//  RecycleRush
//
//  Created by FRC on 4/1/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class TeamData;

@interface DetailScrollViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) TeamData *team;
@end
