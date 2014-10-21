//
//  ScoreUtilities.m
//  AerialAssist
//
//  Created by FRC on 10/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ScoreUtilities.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "DataConvenienceMethods.h"
#import "EnumerationDictionary.h"

@implementation ScoreUtilities {
    NSDictionary *allianceDictionary;
    NSDictionary *matchTypeDictionary;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
        matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
/*        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        matchDataProperties = [entity attributesByName];
        attributeNames = matchDataProperties.allKeys;
        [self initializePreferences];*/
 	}
	return self;
}

-(NSString *)addTeamScoreToMatch:(MatchData *)match forAlliance:(NSString *)alliance forTeam:(NSNumber *)teamNumber {
    NSString *errMsg;
    // Check team to make sure it exists
    NSString *matchTypeString = [EnumerationDictionary getKeyFromValue:match.matchType forDictionary:matchTypeDictionary];
    if (![DataConvenienceMethods getTeamInTournament:teamNumber forTournament:match.tournamentName fromContext:_dataManager.managedObjectContext]) return [NSString stringWithFormat:@"%@ Match %@ Team %@ does not exist", matchTypeString, match.number, teamNumber];
    NSLog(@"Team %@ exists", teamNumber);
    // Check match to make sure this match doesn't already have a score record in this slot
    // If there is already a score record, check to see if it is the same team we are addiing. If so, do
    // nothing, we're just trying to add something that is already there.
    // If the team number doesn't match, then check to see if the score record has results. If it does, then
    // there is a problem and an error message will be issues.
    // If there are no results, then, most likely, the match schedule has been updated. Delete the unused record
    // and create a new one.
    NSArray *allScores = [match.score allObjects];
    if (!allScores) return FALSE;
    NSNumber *allianceStation = [EnumerationDictionary getValueFromKey:alliance forDictionary:allianceDictionary];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", allianceStation];
    NSArray *allianceList = [allScores filteredArrayUsingPredicate:pred];
    if ([allianceList count]) {
        for (TeamScore *score in allianceList) {
            if ([teamNumber intValue] == [score.teamNumber intValue]) continue; // This team is in this slot
            if ([score.results boolValue]) {
                errMsg = [NSString stringWithFormat:@"Results already exist for %@ Match %@, Alliance %@", matchTypeString, match.number, alliance];
                NSLog(@"%@", errMsg);
                return errMsg;
            }
            else {
                [match removeScoreObject:score];
                [_dataManager.managedObjectContext deleteObject:score];
                NSLog(@"Removing unused %@ Match %@, Alliance %@ Record", matchTypeString, match.number, alliance);
            }
        }
    }

/*    NSLog(@"Quickie QA of score deleting");
    allScores = [match.score allObjects];
    for (TeamScore *records in allScores) {
        NSLog(@"%@ Match %@, Alliance %@ Record", matchTypeString, records.matchNumber, [EnumerationDictionary getKeyFromValue:records.allianceStation forDictionary:allianceDictionary]);
    }
*/    
    // For Qualification and Elimination matches, a team may not be in the match in 2 different alliance slots.
    // This is allowed for Practice matches where there may only be 1 team on the field and 6 scouters practicing.
    // It is also allowed for Testing and Other type matches because.
    pred = [NSPredicate predicateWithFormat:@"teamNumber = %@", teamNumber];
    NSArray *teamList = [allScores filteredArrayUsingPredicate:pred];
    if ([teamList count]) {
        if ([matchTypeString isEqualToString:@"Qualification"] || [matchTypeString isEqualToString:@"Elimination"]) {
            for (TeamScore *score in teamList) {
                // If this team is in this alliance slot then everything is A Ok.
                if ([score.allianceStation intValue] != [allianceStation intValue]) {
                    // Oh dear, someone has the match schedule messed up.
                    errMsg = [NSString stringWithFormat:@"%@ Match %@ Team %@ is already at alliance station %@", matchTypeString, score.matchNumber, score.teamNumber, [EnumerationDictionary getKeyFromValue:score.allianceStation forDictionary:allianceDictionary]];
                    NSLog(@"%@", errMsg);
                    return errMsg;
                }
            }
        }
    }

    TeamScore *newScore = [self createNewScore:match forTeam:teamNumber forAllianceStation:allianceStation];
    
    
    if (newScore) {
        [match addScoreObject:newScore];
        NSLog(@"score count = %d", [[match.score allObjects] count]);
        return Nil;
    }
    errMsg = [NSString stringWithFormat:@"Unable to add %@ Match %@ Team %@ in alliance station %@", matchTypeString, match.number, teamNumber, alliance];
    return errMsg;
    
    /*       // for now, add only one team
        if (![allAlliances count]) {
            Alliance *newAlliance = [NSEntityDescription insertNewObjectForEntityForName:@"Alliance"
                                                                  inManagedObjectContext:_dataManager.managedObjectContext];
            newAlliance.team = team;
            newAlliance.station = [EnumerationDictionary getValueFromKey:[alliance valueForKey:@"output"] forDictionary:allianceDictionary];
            [match addTeamsObject:newAlliance];
            return true;
        }
 */       
        
        /*
         NSPredicate *pred = [NSPredicate predicateWithFormat:@"team = %@", team];
         NSArray *allianceList = [allAlliances filteredArrayUsingPredicate:pred];
         if ([allianceList count]) {
         NSLog(@"Team %@ is already in this match", team);
         // Check if it is in this alliance station. If so, everything is ok, return
         // If not in this alliance station, then only allow if match type is test other or practice
         }
         else {
         NSLog(@"Team %@ is not in match", team);
         // Make sure another team is not at this station
         // If yes, check for result, if yes, bail with error, if no, replace
         // If no results, replace
         }
         // need to be sure to clean up both match and score records
         // Check if there is a score record and if so and has a different team, see if it had saved results
         // Score record uniquely defined by match number, type, tournament and alliance
         // Then if record exists, it has results when the results flag is true
         // For tournament matches, make sure a team does not appear more than once in the match*/
        return FALSE;
}

-(TeamScore *)createNewScore:(MatchData *)match forTeam:(NSNumber *)teamNumber forAllianceStation:(NSNumber *)allianceStation {
    if (!teamNumber || ([teamNumber intValue] < 1)) return nil;
    if (![DataConvenienceMethods getTeamInTournament:teamNumber forTournament:match.tournamentName fromContext:_dataManager.managedObjectContext]) return Nil;
    
    if ([DataConvenienceMethods getScoreRecord:match.number forType:match.matchType forAlliance:allianceStation forTournament:match.tournamentName fromContext:_dataManager.managedObjectContext]) return Nil;
    
    TeamScore *score = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore"
                                             inManagedObjectContext:_dataManager.managedObjectContext];
    if (!score) return Nil;
    
    // Set the 4 items that need to be set to define a unique record
    score.matchNumber = match.number;
    score.matchType = match.matchType;
    score.allianceStation = allianceStation;
    score.tournamentName = match.tournamentName;
    
    // Set the team number
    score.teamNumber = teamNumber;
    
    return score;
}



@end
