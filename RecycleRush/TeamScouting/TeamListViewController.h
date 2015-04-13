//
//  TeamListViewController.h
// Robonauts Scouting
//
//  Created by Kris Pettinger on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddTeamViewController.h"

@class DataManager;
@class ConnectionUtility;
@class TeamData;

@interface TeamListViewController : UITableViewController <NSFetchedResultsControllerDelegate, AddTeamDelegate>
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) ConnectionUtility *connectionUtility;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

@end
