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

+(UITableViewCell *)configureReceivedTeamCell:(UITableViewCell *)cell forTeam:(NSDictionary *)team;
+(UITableViewCell *)configureResultsCell:(UITableViewCell *)cell forXfer:(XFerOption)xFerOption forScore:score forMatchDictionary:(NSDictionary *)matchTypeDictionary forAlliances:(NSDictionary *)allianceDictionary;
+(UITableViewCell *)configurePhotoCell:(UITableViewCell *)cell forPhotoList:(NSString *)receivedList;

@end
