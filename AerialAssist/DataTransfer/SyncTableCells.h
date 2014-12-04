//
//  SyncTableCells.h
//  AerialAssist
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TournamentData;
@class TeamData;
@class MatchData;

@interface SyncTableCells : NSObject
+(UITableViewCell *)configureTournamentCell:(UITableViewCell *)cell forXfer:(XFerOption)xFerOption forTournament:(TournamentData *)tournament;
+(UITableViewCell *)configureTeamCell:(UITableViewCell *)cell forTeam:(TeamData *)team;
+(UITableViewCell *)configureReceivedTeamCell:(UITableViewCell *)cell forTeam:(NSDictionary *)team;
+(UITableViewCell *)configureMatchListCell:(UITableViewCell *)cell  forXfer:(XFerOption)xFerOption forMatch:match forMatchDictionary:matchDictionary forAlliances:(NSDictionary *)allianceDictionary;
+(UITableViewCell *)configureResultsCell:(UITableViewCell *)cell forXfer:(XFerOption)xFerOption forScore:score forMatchDictionary:(NSDictionary *)matchTypeDictionary forAlliances:(NSDictionary *)allianceDictionary;
+(UITableViewCell *)configurePhotoCell:(UITableViewCell *)cell forPhotoList:(NSString *)receivedList;

@end
