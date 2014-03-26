//
//  LucienTableViewController.h
// Robonauts Scouting
//
//  Created by FRC on 7/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LucienNumberObject;
@class DataManager;

@interface LucienTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *lucienNumbers;
@property (nonatomic, strong) NSDictionary *lucienSelections;
@property (nonatomic, strong) DataManager *dataManager;
@end
