//
//  SyncTableCells.m
//  AerialAssist
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "SyncTableCells.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "EnumerationDictionary.h"

@interface SyncTableCells()
+(NSString *)getTeamNumber:(NSArray *)scoreList forAlliance:(NSString *)allianceStation forAllianceDictionary:allianceDictionary;
+(NSString *)getAlliance:(NSArray *)scoreList forAlliance:(NSString *)allianceStation forAllianceDictionary:allianceDictionary;
@end

@implementation SyncTableCells
+(UITableViewCell *)configureTournamentCell:(UITableViewCell *)cell forXfer:(XFerOption)xFerOption forTournament:(TournamentData *)tournament {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = tournament.name;
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    if (tournament.code) {
        label2.text = tournament.code;
    }
    else label2.text = @"";
    return cell;
}

+(UITableViewCell *)configureTeamCell:(UITableViewCell *)cell forTeam:(TeamData *)team {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = [NSString stringWithFormat:@"%@", team.number];
        
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = team.name;

    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = @"";

    return cell;
}

+(UITableViewCell *)configureReceivedTeamCell:(UITableViewCell *)cell forTeam:(NSDictionary *)team {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = [NSString stringWithFormat:@"%@", [team objectForKey:@"team"]];
    
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [team objectForKey:@"name"];
    
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [team objectForKey:@"transfer"];

    return cell;
}

+(NSString *)getTeamNumber:(NSArray *)scoreList forAlliance:(NSString *)allianceStation forAllianceDictionary:allianceDictionary {
    if (!scoreList || ![scoreList count]) return @"";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:allianceStation forDictionary:allianceDictionary]];
    NSArray *team = [scoreList filteredArrayUsingPredicate:pred];
    if (!team || ![team count]) return @"";
    NSNumber *teamNumber = [[team objectAtIndex:0] valueForKey:@"teamNumber"];
    if (teamNumber) return [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    else return @"";
}

+(NSString *)getAlliance:(NSArray *)scoreList forAlliance:(NSString *)allianceStation forAllianceDictionary:allianceDictionary {
    if (!scoreList || ![scoreList count]) return @"";
    NSLog(@"%@", scoreList);
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", allianceStation];
    NSArray *team = [scoreList filteredArrayUsingPredicate:pred];
    NSLog(@"%@", team);
/*    if (!team || ![team count]) return @"";
    NSNumber *teamNumber = [[team objectAtIndex:0] valueForKey:@"teamNumber"];
    if (teamNumber) return [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    else return @"";*/
    return @"";
}


+(UITableViewCell *)configureMatchListCell:(UITableViewCell *)cell forXfer:(XFerOption)xFerOption forMatch:match forMatchDictionary:matchDictionary forAlliances:(NSDictionary *)allianceDictionary {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    UILabel *label6 = (UILabel *)[cell viewWithTag:60];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    UILabel *label7 = (UILabel *)[cell viewWithTag:70];
    UILabel *label8 = (UILabel *)[cell viewWithTag:80];
    UILabel *label9 = (UILabel *)[cell viewWithTag:90];
    if (xFerOption == Sending) {
        MatchData *data = match;
        NSArray *scores = [data.score allObjects];
        label1.text = [NSString stringWithFormat:@"%@", data.number];
        label2.text = [EnumerationDictionary getKeyFromValue:data.matchType forDictionary:matchDictionary];
        label3.text = [SyncTableCells getTeamNumber:scores forAlliance:@"Red 1" forAllianceDictionary:allianceDictionary];
        label4.text = [SyncTableCells getTeamNumber:scores forAlliance:@"Red 2" forAllianceDictionary:allianceDictionary];
        label5.text = [SyncTableCells getTeamNumber:scores forAlliance:@"Red 3" forAllianceDictionary:allianceDictionary];
        label6.text = [SyncTableCells getTeamNumber:scores forAlliance:@"Blue 1" forAllianceDictionary:allianceDictionary];
        label7.text = [SyncTableCells getTeamNumber:scores forAlliance:@"Blue 2" forAllianceDictionary:allianceDictionary];
        label8.text = [SyncTableCells getTeamNumber:scores forAlliance:@"Blue 3" forAllianceDictionary:allianceDictionary];
    }
    else {
        NSDictionary *data = match;
        label1.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"match"]];
        label2.text = [data objectForKey:@"type"];
//        NSArray *teams = [data objectForKey:@"teams"];
        label3.text = @""; //[SyncTableCells getAlliance:teams forAlliance:@"Red 1" forAllianceDictionary:allianceDictionary];
        label4.text = @"";
        label5.text = @"";
        label6.text = @"";
        label7.text = @"";
        label8.text = @"";
        label9.text = [data objectForKey:@"transfer"];
    }
    return cell;
}


+(UITableViewCell *)configureReceivedMatchCell:(UITableViewCell *)cell forMatch:(NSDictionary *)match forMatchDictionary:(id)matchDictionary forAlliances:(NSDictionary *)allianceDictionary {
//    NSArray *scoreList = [match.score allObjects];
    
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = [NSString stringWithFormat:@"%@", [match objectForKey:@"match"]];

    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    label2.text = [EnumerationDictionary getKeyFromValue:[match objectForKey:@"type"] forDictionary:matchDictionary];
    NSDictionary *teamsList = [match objectForKey:@"teams"];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    label3.text = [NSString stringWithFormat:@"%@", [teamsList objectForKey:@"Red 1"]];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    label4.text = [NSString stringWithFormat:@"%@", [teamsList objectForKey:@"Red 2"]];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    label5.text = [NSString stringWithFormat:@"%@", [teamsList objectForKey:@"Red 3"]];

    UILabel *label6 = (UILabel *)[cell viewWithTag:60];
    label6.text = [NSString stringWithFormat:@"%@", [teamsList objectForKey:@"Blue 1"]];
    UILabel *label7 = (UILabel *)[cell viewWithTag:70];
    label7.text = [NSString stringWithFormat:@"%@", [teamsList objectForKey:@"Blue 2"]];
    UILabel *label8 = (UILabel *)[cell viewWithTag:80];
    label8.text = [NSString stringWithFormat:@"%@", [teamsList objectForKey:@"Blue 3"]];
    return cell;
}

+(UITableViewCell *)configureReceivedMatchListCell:(UITableViewCell *)cell forMatch:(MatchData *)match forMatchDictionary:matchDictionary {
    return cell;
}

+(UITableViewCell *)configureResultsCell:(UITableViewCell *)cell forXfer:(XFerOption)xFerOption forScore:score forMatchDictionary:(NSDictionary *)matchTypeDictionary forAlliances:(NSDictionary *)allianceDictionary {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    UILabel *label2 = (UILabel *)[cell viewWithTag:20];
    UILabel *label3 = (UILabel *)[cell viewWithTag:30];
    UILabel *label4 = (UILabel *)[cell viewWithTag:40];
    UILabel *label5 = (UILabel *)[cell viewWithTag:50];
    UIColor *color;
    if (xFerOption == Sending) {
        TeamScore *data = score;
        label1.text = [NSString stringWithFormat:@"%@", data.matchNumber];
        label2.text = [EnumerationDictionary getKeyFromValue:data.matchType forDictionary:matchTypeDictionary];
        label3.text = [EnumerationDictionary getKeyFromValue:data.allianceStation forDictionary:allianceDictionary];
        label4.text = [NSString stringWithFormat:@"%@", data.teamNumber];
        label5.text = [NSString stringWithFormat:@"%@", [data.results boolValue] ? @"Y":@"N"];
    }
    else {
        NSDictionary *data = score;
        label1.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"match"]];
        label2.text = [data objectForKey:@"type"];
        label3.text = [data objectForKey:@"alliance"];
        label4.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"team"]];
        label5.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"transfer"]];
    }
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

+(UITableViewCell *)configurePhotoCell:(UITableViewCell *)cell forPhotoList:(NSString *)receivedList {
    UILabel *label1 = (UILabel *)[cell viewWithTag:10];
    label1.text = receivedList;
    return cell;
}



@end
