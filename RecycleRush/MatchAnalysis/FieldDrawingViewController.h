//
//  FieldDrawingViewController.h
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface FieldDrawingViewController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSArray *teamScores;
@property (nonatomic, assign) int *startingIndex;

@end
