//
//  MatchPhotoCollectionViewController.h
//  RecycleRush
//
//  Created by FRC on 2/21/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface MatchPhotoCollectionViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSNumber *teamNumber;
@property (nonatomic, strong) NSArray *matchList;

@end
