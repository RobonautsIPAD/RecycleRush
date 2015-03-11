//
//  SyncTableCells.m
//  RecycleRush
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "SyncTableCells.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "MatchAccessors.h"

@implementation SyncTableCells {
    NSDictionary *matchDictionary;
    NSDictionary *allianceDictionary;
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        matchDictionary = _dataManager.matchTypeDictionary;
        allianceDictionary = _dataManager.allianceDictionary;
	}
	return self;
}

-(UITableViewCell *)configureCell:(UITableView *)tableView forTableData:tableData atIndexPath:(NSIndexPath *)indexPath {
   // cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
    NSString *dataType = NSStringFromClass([tableData class]);
    UITableViewCell *cell;
    if ([dataType isEqualToString:@"TeamScore"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchResult" forIndexPath:indexPath];
        cell = [self configureScoreCell:cell forScoreRecord:tableData];
    }
    else if ([dataType isEqualToString:@"TournamentData"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Tournament" forIndexPath:indexPath];
        cell = [self configureTournamentCell:cell forTournament:tableData];
    }
    else if ([dataType isEqualToString:@"TeamData"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Team" forIndexPath:indexPath];
        cell = [self configureTeamCell:cell forTeam:tableData];
    }
    else if ([dataType isEqualToString:@"MatchData"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MatchList" forIndexPath:indexPath];
        cell = [self configureMatchListCell:cell forMatch:tableData];
    }
    else { // This had better be a dictionary type.
     //   NSDictionary *dataDictionary = (NSDictionary *)
        NSString *resultType = [(NSDictionary *)tableData objectForKey:@"record"];
        NSLog(@"record = %@", resultType);
        if ([resultType isEqualToString:@"TeamData"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Team" forIndexPath:indexPath];
            cell = [self configureReceivedTeamCell:cell forTeam:tableData];
        }
        else if ([resultType isEqualToString:@"MatchData"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MatchList" forIndexPath:indexPath];
            cell = [self configureReceivedMatchCell:cell forMatch:tableData];
        }
        else if ([resultType isEqualToString:@"TeamScore"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MatchResult" forIndexPath:indexPath];
            cell = [self configureReceivedScoreCell:cell forScoreRecord:tableData];
        }
        else if ([dataType isEqualToString:@"TournamentData"]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"Tournament" forIndexPath:indexPath];
            cell = [self configureReceivedTournamentCell:cell forTournament:tableData];
        }
    }
    return cell;
}

-(UITableViewCell *)configureScoreCell:(UITableViewCell *)cell forScoreRecord:(TeamScore *)score {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    UIColor *color;
    label1.text = [NSString stringWithFormat:@"%@", score.matchNumber];
    label2.text = [MatchAccessors getMatchTypeString:score.matchType fromDictionary:matchDictionary];
    label3.text = [MatchAccessors getAllianceString:score.allianceStation fromDictionary:allianceDictionary];
    label4.text = [NSString stringWithFormat:@"%@", score.teamNumber];
    label5.text = [NSString stringWithFormat:@"%@", [score.results boolValue] ? @"Y":@"N"];
    if ([[label3.text substringToIndex:1] isEqualToString:@"R"]) {
        color = [UIColor colorWithRed:1 green: 0 blue: 0 alpha:1];
    }
    else {
        color = [UIColor colorWithRed:0 green: 0 blue: 1 alpha:1];
    }
    label3.textColor = color;
    label4.textColor = color;
    label5.textColor = color;
    
    return cell;
}

-(UITableViewCell *)configureReceivedScoreCell:(UITableViewCell *)cell forScoreRecord:(NSDictionary *)score {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    UIColor *color;
    NSDictionary *data = score;
    label1.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"match"]];
    label2.text = [data objectForKey:@"type"];
    label3.text = [data objectForKey:@"alliance"];
    label4.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"team"]];
    label5.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"transfer"]];
    if ([[label3.text substringToIndex:1] isEqualToString:@"R"]) {
        color = [UIColor colorWithRed:1 green: 0 blue: 0 alpha:1];
    }
    else {
        color = [UIColor colorWithRed:0 green: 0 blue: 1 alpha:1];
    }
    label3.textColor = color;
    label4.textColor = color;
    label5.textColor = color;
    
    return cell;
}


-(UITableViewCell *)configureTournamentCell:(UITableViewCell *)cell forTournament:(TournamentData *)tournament {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = tournament.name;
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    if (tournament.code) {
        label2.text = tournament.code;
    }
    else label2.text = @"";
    return cell;
}

-(UITableViewCell *)configureReceivedTournamentCell:(UITableViewCell *)cell forTournament:(NSDictionary *)tournament {
/*    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = tournament.name;
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    if (tournament.code) {
        label2.text = tournament.code;
    }
    else label2.text = @"";*/
    return cell;
}

-(UITableViewCell *)configureTeamCell:(UITableViewCell *)cell forTeam:(TeamData *)team {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = [NSString stringWithFormat:@"%@", team.number];
        
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = team.name;

    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";

    return cell;
}

-(UITableViewCell *)configureReceivedTeamCell:(UITableViewCell *)cell forTeam:(NSDictionary *)team {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = [NSString stringWithFormat:@"%@", [team objectForKey:@"team"]];
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [team objectForKey:@"name"];
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [team objectForKey:@"transfer"];
    
    return cell;
}

-(UITableViewCell *)configureMatchListCell:(UITableViewCell *)cell forMatch:(MatchData *)match {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    UILabel *label6 = (UILabel *)[cell viewWithTag:60];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    UILabel *label7 = (UILabel *)[cell viewWithTag:70];
    UILabel *label8 = (UILabel *)[cell viewWithTag:80];
    UILabel *label9 = (UILabel *)[cell viewWithTag:90];
    UILabel *label10 = (UILabel *)[cell viewWithTag:100];
    UILabel *label11 = (UILabel *)[cell viewWithTag:110];
    NSArray *scores = [match.score allObjects];
    label1.text = [NSString stringWithFormat:@"%@", match.number];
    label2.text = [MatchAccessors getMatchTypeString:match.matchType fromDictionary:matchDictionary];
    label3.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Red 1" forAllianceDictionary:allianceDictionary];
    label4.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Red 2" forAllianceDictionary:allianceDictionary];
    label5.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Red 3" forAllianceDictionary:allianceDictionary];
    label6.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Blue 1" forAllianceDictionary:allianceDictionary];
    label7.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Blue 2" forAllianceDictionary:allianceDictionary];
    label8.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Blue 3" forAllianceDictionary:allianceDictionary];
    label9.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Red 4" forAllianceDictionary:allianceDictionary];
    label10.text = [MatchAccessors getTeamNumber:scores forAllianceString:@"Blue 4" forAllianceDictionary:allianceDictionary];
    label11.text = @"";
    return cell;
}

-(UITableViewCell *)configureReceivedMatchCell:(UITableViewCell *)cell forMatch:(NSDictionary *)match  {
    //    NSArray *scoreList = [match.score allObjects];
    
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    UILabel *label6 = (UILabel *)[cell viewWithTag:60];
    UILabel *label7 = (UILabel *)[cell viewWithTag:70];
    UILabel *label8 = (UILabel *)[cell viewWithTag:80];
    UILabel *label9 = (UILabel *)[cell viewWithTag:90];
    UILabel *label10 = (UILabel *)[cell viewWithTag:100];
    UILabel *label11 = (UILabel *)[cell viewWithTag:110];

    label1.text = [NSString stringWithFormat:@"%@", [match objectForKey:@"match"]];
    label2.text = [match objectForKey:@"type"];

    NSDictionary *teamList = [match objectForKey:@"Teams"];
    label3.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Red 1"]];
    label4.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Red 2"]];
    label5.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Red 3"]];
    label6.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Blue 1"]];
    label7.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Blue 2"]];
    label8.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Blue 3"]];
    label9.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Red 4"]];
    label10.text = [NSString stringWithFormat:@"%@", [teamList objectForKey:@"Blue 4"]];
    label11.text = [match objectForKey:@"transfer"];
    return cell;
}







+(UITableViewCell *)configurePhotoCell:(UITableViewCell *)cell forPhotoList:(NSString *)receivedList {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = receivedList;
    return cell;
}



@end
