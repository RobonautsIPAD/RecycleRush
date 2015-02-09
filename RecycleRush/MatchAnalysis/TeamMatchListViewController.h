//
//  TeamMatchListViewController.h
//  RecycleRush
//
//  Created by FRC on 2/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface TeamMatchListViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) DataManager *dataManager;
@end
