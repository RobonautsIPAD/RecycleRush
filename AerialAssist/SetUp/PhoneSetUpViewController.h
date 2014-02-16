//
//  PhoneSetUpViewController.h
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface PhoneSetUpViewController : UIViewController <UIActionSheetDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@end
