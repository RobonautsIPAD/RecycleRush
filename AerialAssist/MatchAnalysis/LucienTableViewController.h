//
//  LucienTableViewController.h
// Robonauts Scouting
//
//  Created by FRC on 7/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LucienNumberObject;

@interface LucienTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *lucienNumbers;
@property (nonatomic, strong) NSDictionary *lucienSelections;
@end
