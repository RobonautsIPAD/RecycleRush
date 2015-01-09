//
//  MatchIntegrityViewController.h
//  RecycleRush
//
//  Created by FRC on 3/26/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;

@interface MatchIntegrityViewController : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
