//
//  SyncTableCells.h
//  RecycleRush
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TournamentData;
@class TeamData;
@class MatchData;

@interface SyncTableCells : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(UITableViewCell *)configureCell:(UITableView *)tableView forTableData:tableData atIndexPath:(NSIndexPath *)indexPath;

+(UITableViewCell *)configurePhotoCell:(UITableViewCell *)cell forPhotoList:(NSString *)receivedList;

@end
