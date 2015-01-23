//
//  ScoreAccessors.m
//  RecycleRush
//
//  Created by FRC on 11/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ScoreAccessors.h"
#import "DataManager.h"
#import "TeamScore.h"
#import "MatchAccessors.h"

@implementation ScoreAccessors
+(TeamScore *)getScoreRecord:(NSNumber *)matchNumber forType:(NSNumber *)matchType forAlliance:(NSNumber *)alliance forTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getScoreRecord" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    // Only one record should meet all these criteria. If more than one
    // is found, then a database corruption has occurred.
    TeamScore *scoreRecord;
    // A match needs 3 unique items to define it. A match number, the match type and the tournament name.
    // NSLog(@"Searching for match = %@ %@", matchType, matchNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND matchNumber = %@ AND matchType = %@ AND allianceStation = %@", tournament, matchNumber, matchType, alliance];
    [fetchRequest setPredicate:pred];
    NSArray *matchScores = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchScores) {
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSString *msg;
    switch ([matchScores count]) {
        case 0:
            msg = [NSString stringWithFormat:@"Unable to get %@ Match %@ for Alliance %@", [MatchAccessors getMatchTypeString:matchType fromDictionary:dataManager.matchTypeDictionary], matchNumber, [MatchAccessors getAllianceString:alliance fromDictionary:dataManager.allianceDictionary]];
            error = [NSError errorWithDomain:@"getScoreRecord" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [dataManager writeErrorMessage:error forType:[error code]];
            return nil;
            break;
        case 1:
            scoreRecord = [matchScores objectAtIndex:0];
            // NSLog(@"Match %@ %@ exists", matchType, matchNumber);
            return scoreRecord;
            break;
        default:
           msg = [NSString stringWithFormat:@"%@ Match %@ Alliance %@ found multiple times", [MatchAccessors getMatchTypeString:matchType fromDictionary:dataManager.matchTypeDictionary], matchNumber, [MatchAccessors getAllianceString:alliance fromDictionary:dataManager.allianceDictionary]];
            scoreRecord = [matchScores objectAtIndex:0];
            error = [NSError errorWithDomain:@"getScoreRecord" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [dataManager writeErrorMessage:error forType:[error code]];
            return scoreRecord;
            break;
    }
}

+(TeamScore *)getTeamScore:(NSArray *)scoreList forAllianceString:(NSString *)allianceString forAllianceDictionary:allianceDictionary {
    NSNumber *allianceStation = [MatchAccessors getAllianceStation:allianceString fromDictionary:allianceDictionary];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation == %@", allianceStation];
    NSArray *score = [scoreList filteredArrayUsingPredicate:pred];
    if (score && [score count]) {
        TeamScore *team = [score objectAtIndex:0];
        return team;
    }
    else return nil;
}

@end
