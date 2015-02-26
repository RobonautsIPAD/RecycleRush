//
//  PhoneMatchListViewController.h
//  RecycleRush
//
//  Created by FRC on 2/25/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@interface PhoneMatchListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) DataManager *dataManager;

@end
