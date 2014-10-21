//
//  MatchListViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMatchViewController.h"
#import "MatchDetailViewController.h"

@class DataManager;
@class MatchData;

@interface MatchListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate, AddMatchDelegate, MatchDetailDelegate>

@property (nonatomic, strong) DataManager *dataManager;

@end
