//
//  MatchAccessors.m
//  RecycleRush
//
//  Created by FRC on 11/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchAccessors.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"

@implementation MatchAccessors
+(MatchData *)getMatch:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    MatchData *match;
    // A match needs 3 unique items to define it. A match number, the match type and the tournament name.
    //NSLog(@"Searching for match = %@ %@", matchType, matchNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND number = %@ AND matchType = %@", tournament, matchNumber, matchType];
    [fetchRequest setPredicate:pred];
    NSArray *matchData = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSString *msg;
    switch ([matchData count]) {
        case 0:
            msg = [NSString stringWithFormat:@"%@ Match %@ does not exist", matchType, matchNumber];
            error = [NSError errorWithDomain:@"getMatch" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            return nil;
            break;
        case 1:
            match = [matchData objectAtIndex:0];
            // NSLog(@"Match %@ %@ exists", matchType, matchNumber);
            return match;
            break;
        default:
            msg = [NSString stringWithFormat:@"Match %@ %@ found multiple times", matchType, matchNumber];
            error = [NSError errorWithDomain:@"getMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [dataManager writeErrorMessage:error forType:[error code]];
            return match;
            break;
    }
}

+(NSArray *)getMatchList:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getMatchList" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournament];
    [fetchRequest setPredicate:pred];
    NSArray *matchList = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) [dataManager writeErrorMessage:error forType:[error code]];

    return matchList;
}

+(NSString *)getMatchTypeString:(NSNumber *)matchType fromDictionary:(NSDictionary *)matchTypeDictionary {
    NSArray *temp = [matchTypeDictionary allKeysForObject:matchType];
    if ([temp count]) return [temp objectAtIndex:0];
    else return nil;
}
+(NSNumber *)getMatchTypeFromString:(NSString *)matchTypeString fromDictionary:(NSDictionary *)matchTypeDictionary {
    //    valueObject = [EnumerationDictionary getValueFromKey:key forDictionary:allianceDictionary];
    NSNumber *matchType = [matchTypeDictionary objectForKey:matchTypeString];
    if (!matchType) {
        NSArray *allKeys = [matchTypeDictionary allKeys];
        for (NSString *item in allKeys) {
            if ([matchTypeString caseInsensitiveCompare:item] == NSOrderedSame ) {
                matchType = [matchTypeDictionary objectForKey:item];
                break;
            }
        }
    }
    return matchType;
}

+(NSDictionary *)getAllianceString:(NSNumber *)allianceStation fromDictionary:(NSDictionary *)allianceDictionary {
    NSArray *temp = [allianceDictionary allKeysForObject:allianceStation];
    if ([temp count]) return [temp objectAtIndex:0];
    else return nil;
}

+(NSNumber *)getAllianceStation:(NSString *)allianceString fromDictionary:(NSDictionary *)allianceDictionary {
    //    valueObject = [EnumerationDictionary getValueFromKey:key forDictionary:allianceDictionary];
    NSNumber *allianceStation = [allianceDictionary objectForKey:allianceString];
    if (!allianceStation) {
        NSArray *allKeys = [allianceDictionary allKeys];
        for (NSString *item in allKeys) {
            if ([allianceString caseInsensitiveCompare:item] == NSOrderedSame ) {
                allianceStation = [allianceDictionary objectForKey:item];
                break;
            }
        }
    }
    return allianceStation;
}

+(NSMutableDictionary *)buildTeamList:(MatchData *)match forAllianceDictionary:allianceDistionary {
    NSMutableDictionary *teamList = [[NSMutableDictionary alloc] init];
    NSArray *allScores = [match.score allObjects];
    for (TeamScore *score in allScores) {
        //  NSLog(@"score team = %@", score.team);
        NSString *allianceString = [MatchAccessors getAllianceString:score.allianceStation fromDictionary:allianceDistionary];
        [teamList setObject:score.teamNumber forKey:allianceString];
     }
    return teamList;
}

+(NSString *)getTeamNumber:(NSArray *)scoreList forAllianceString:(NSString *)allianceString forAllianceDictionary:allianceDictionary {
    NSNumber *allianceStation = [MatchAccessors getAllianceStation:allianceString fromDictionary:allianceDictionary];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation == %@", allianceStation];
    NSArray *score = [scoreList filteredArrayUsingPredicate:pred];
    if (score && [score count]) {
        TeamScore *team = [score objectAtIndex:0];
        NSNumber *teamNumber = team.teamNumber;
        return [NSString stringWithFormat:@"%d", [teamNumber intValue]];
    }
    else return @"";
}

@end
