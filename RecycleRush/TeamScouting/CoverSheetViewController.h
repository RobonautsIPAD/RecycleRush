//
//  CoverSheetViewController.h
//  RecycleRush
//
//  Created by FRC on 4/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface CoverSheetViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSArray *teamList;

@end
