//
//  PhoneSplashViewController.h
//  RecycleRush
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@class ConnectionUtility;

@interface PhoneSplashViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;

@end
