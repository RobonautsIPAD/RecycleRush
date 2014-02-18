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
#import "TeamScore.h"
#import "TeamData.h"
#import "TeamDataInterfaces.h"
#import "TournamentData.h"
#import "TournamentDataInterfaces.h"

@implementation TeamScoreInterfaces {
    NSDictionary *teamScoreProperties;

}
@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(NSData *)packageMatchForXFer:(TeamScore *)score {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamScoreProperties) teamScoreProperties = [[score entity] propertiesByName];
    for (NSString *item in teamScoreProperties) {
        if ([score valueForKey:item]) {
            [keyList addObject:item];
            [valueList addObject:[score valueForKey:item]];
        }
    }
/*
    NSMutableArray *allianceList = [NSMutableArray array];
    NSMutableArray *teamList = [NSMutableArray array];
    NSArray *allTeams = [match.score allObjects];
    for (TeamScore *score in allTeams) {
        if (score.team) {
            //  NSLog(@"score team = %@", score.team);
            [allianceList addObject:score.alliance];
            [teamList addObject:score.team.number];
        }
    }
    NSDictionary *teams = [NSDictionary dictionaryWithObjects:teamList forKeys:allianceList];
    [keyList addObject:@"teams"];
    [valueList addObject:teams];
  */  
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    NSLog(@"sending %@", dictionary);
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    return myData;
}

-(TeamScore *)unpackageMatchForXFer:(NSData *)xferData {
    
}

-(void)addTeamToMatch:(MatchData *)match forTeam:(NSNumber *)teamNumber forAlliance:(NSString *)alliance {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    TeamData *team = [[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeam:teamNumber];
    if (!team) return; // Team does not exist. Bail out!!!

    // Check to see if there is a team in this alliance spot already
    NSArray *allScores = [match.score allObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"alliance = %@", alliance];
    NSArray *score = [allScores filteredArrayUsingPredicate:pred];
    
    if ([score count] > 0) {
        // A score record already exists in this alliance
        TeamScore *oldScore = [score objectAtIndex:0];
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
