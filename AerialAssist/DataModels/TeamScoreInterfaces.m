//
//  TeamScoreInterfaces.m
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TeamScoreInterfaces.h"
#import "DataManager.h"
#import "MatchData.h"
#import "MatchDataInterfaces.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "TournamentData.h"
#import "TournamentDataInterfaces.h"
#import "FieldDrawing.h"

@implementation TeamScoreInterfaces {
    NSDictionary *teamScoreAttributes;

}
@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(NSData *)packageScoreForXFer:(TeamScore *)score {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    for (NSString *item in teamScoreAttributes) {
        NSLog(@"Item = %@", item);
        if ([score valueForKey:item] && [score valueForKey:item] != [[teamScoreAttributes valueForKey:item] valueForKey:@"defaultValue"]) {
            [keyList addObject:item];
            [valueList addObject:[score valueForKey:item]];
        }
    }
    if (score.fieldDrawing) {
        [keyList addObject:@"fieldDrawing"];
        [valueList addObject:score.fieldDrawing.trace];
    }
    if (score.team) {
        [keyList addObject:@"teamNumber"];
        [valueList addObject:score.team.number];
    }
    if (score.match) {
        [keyList addObject:@"matchNumber"];
        [valueList addObject:score.match.number];
        [keyList addObject:@"matchType"];
        [valueList addObject:score.match.matchType];
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    NSLog(@"sending %@", dictionary);
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    return myData;
}

-(TeamScore *)unpackageScoreForXFer:(NSData *)xferData {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];

    NSNumber *matchNumber = [myDictionary objectForKey:@"matchNumber"];
    NSString *matchType = [myDictionary objectForKey:@"matchType"];
    NSString *tournamentName = [myDictionary objectForKey:@"tournamentName"];
    NSNumber *teamNumber = [myDictionary objectForKey:@"teamNumber"];
    NSString *alliance = [myDictionary objectForKey:@"alliance"];
    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
            @"match.number == %@ AND match.matchType == %@ and tournamentName == %@ and team.number == %@", matchNumber, matchType, tournamentName, teamNumber];
    [fetchRequest setPredicate:predicate];
    
    NSArray *scoreData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!scoreData) {
        NSLog(@"Karma disruption error");
        return nil;
    }
    TeamScore *score;
    if([scoreData count] > 0) {  // Score Exists
        score = [scoreData objectAtIndex:0];
    }
    else {
        MatchData *matchRecord = [[[MatchDataInterfaces alloc] initWithDataManager:_dataManager] getMatch:matchNumber forMatchType:matchType forTournament:tournamentName];
        if (!matchRecord) return nil;   // The match doesn't even exist. The matches should be transferred first.
        TeamScore *oldScore = [self getScoreForAlliance:matchRecord forAlliance:alliance];
        if (oldScore) {
            // A score record already exists in this alliance
            // If the team that is already there has not been saved (as in the record has been
            //   created, but no one has saved any actual score data, then delete the old team and add the new.
            if ([oldScore.saved intValue] == 0 || !oldScore.savedBy) {
                // Create the new score object, if successful, remove the old score and add the new
                TeamScore *newScore = [self AddScore:[[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeam:teamNumber] forAlliance:alliance forTournament:tournamentName];
                if (newScore) {
                    [matchRecord removeScoreObject:oldScore];
                    [matchRecord addScoreObject:newScore];
                }
            }
        }
    }
    for (NSString *key in myDictionary) {
        if ([key isEqualToString:@"matchNumber"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"matchType"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"tournamentName"]) continue; // Already resolved
        if ([key isEqualToString:@"teamNumber"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"fieldDrawing"]) continue; // Needs 
        [score setValue:[myDictionary objectForKey:key] forKey:key];
    }
    if (score.fieldDrawing) score.fieldDrawing.trace = [myDictionary objectForKey:@"fieldDrawing"];
    score.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    NSLog(@"received %@", score);
    return score;
}

-(void)addScoreToMatch:(MatchData *)match forTeam:(NSNumber *)teamNumber forAlliance:(NSString *)alliance {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    TeamData *team = [[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeam:teamNumber];
    if (!team) return; // Team does not exist. Bail out!!!
    
    // Check to see if there is a team in this alliance spot already
    TeamScore *oldScore = [self getScoreForAlliance:match forAlliance:alliance];

    if (oldScore) {
        // A score record already exists in this alliance
        if ([oldScore.team.number intValue] != [teamNumber intValue]) {
            // A different team already exists at this spot.
            // If the team that is already there has not been saved (as in the record has been
            //   created, but no one has saved any actual score data, then delete the old team and add the new.
            if ([oldScore.saved intValue] == 0 || !oldScore.savedBy) {
                // Create the new score object, if successful, remove the old score and add the new
                TeamScore *newScore = [self AddScore:team forAlliance:alliance forTournament:match.tournamentName];
                if (newScore) {
                    [match removeScoreObject:oldScore];
                    [match addScoreObject:newScore];
                }
            }
        }
    }
    else {
        // A score record does not exist in this alliance
        // Add the score record for this team
        TeamScore *newScore = [self AddScore:team forAlliance:alliance forTournament:match.tournamentName];
        if (newScore) [match addScoreObject:newScore];
    }
}

-(TeamScore *)AddScore:(TeamData *)team
           forAlliance:(NSString *)alliance
         forTournament:(NSString *)tournament
{
    // Error checking
    TournamentData *tournamentRecord = [[[TournamentDataInterfaces alloc] initWithDataManager:_dataManager] getTournament:tournament];
    if (!tournamentRecord) return nil; // Tournament does not exist. Bail out!!
    
    NSUInteger allianceSection = [self getAllianceSection:alliance];
    if (allianceSection == -1) return nil; // Invalid alliance selection. Bail out!!
    
    
    TeamScore *teamScore = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore"
                                                         inManagedObjectContext:_dataManager.managedObjectContext];
    [teamScore setTeam:team];
    [teamScore setAlliance:alliance];
    [teamScore setAllianceSection:[NSNumber numberWithInt:allianceSection]];
    [teamScore setTournamentName:tournament];
    
    return teamScore;
}

-(TeamScore *)getScoreForAlliance:(MatchData *)match forAlliance:(NSString *)alliance{
    // Check to see if there is a team in this alliance spot
    NSArray *allScores = [match.score allObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"alliance = %@", alliance];
    NSArray *score = [allScores filteredArrayUsingPredicate:pred];
    if ([score count] > 0) {
        return [score objectAtIndex:0];
    }
    else return nil;
}

-(NSUInteger)getAllianceSection:(NSString *)alliance {
    if ([alliance isEqualToString:@"Red 1"])  return 0;
    else if ([alliance isEqualToString:@"Red 2"]) return 1;
    else if ([alliance isEqualToString:@"Red 3"]) return 2;
    else if ([alliance isEqualToString:@"Blue 1"]) return 3;
    else if ([alliance isEqualToString:@"Blue 2"]) return 4;
    else if ([alliance isEqualToString:@"Blue 3"]) return 5;
    else return -1;
}

@end
