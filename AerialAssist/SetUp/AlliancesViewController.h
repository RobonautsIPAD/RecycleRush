//
//  AlliancesViewController.h
//  AerialAssist
//
//  Created by FRC on 11/4/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface AlliancesViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@end
