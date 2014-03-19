//
//  FirstViewController.h
//  AerialAssist
//
//  Created by FRC on 3/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface FirstViewController : UIViewController
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;

@end
