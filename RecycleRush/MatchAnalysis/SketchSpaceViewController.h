//
//  SketchSpaceViewController.h
//  RecycleRush
//
//  Created by FRC on 2/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface SketchSpaceViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSString *allianceString;
@property (nonatomic, strong) NSString *alliance1;
@property (nonatomic, strong) NSString *alliance2;
@property (nonatomic, strong) NSString *alliance3;

@end
