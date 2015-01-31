//
//  Iphoneteamlist.h
//  RecycleRush
//
//  Created by FRC on 1/26/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DataManager;
@interface Iphoneteamlist : UITableViewController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
