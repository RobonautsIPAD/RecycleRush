//
//  StackViewController.h
//  RecycleRush
//
//  Created by FRC on 2/19/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataManager;

@interface StackViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSString *allianceString;

@end
