 //
//  TeamScoreInterfaces.m
//  RecycleRush
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
#import "DataConvenienceMethods.h"
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

-(void)exportScoreForXFer:(TeamScore *)score toFile:(NSString *)exportFilePath {
/*    // File name format M(Type)#T#
    NSString *match;
    if ([score.match.number intValue] < 10) {
        match = [NSString stringWithFormat:@"M%c%@", [score.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [score.match.number intValue]]];
    } else if ( [score.match.number intValue] < 100) {
        match = [NSString stringWithFormat:@"M%c%@", [score.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [score.match.number intValue]]];
    } else {
        match = [NSString stringWithFormat:@"M%c%@", [score.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [score.match.number intValue]]];
    }
    NSString *team;
    if ([score.team.number intValue] < 100) {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [score.team.number intValue]]];
    } else if ( [score.team.number intValue] < 1000) {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [score.team.number intValue]]];
    } else {
        team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [score.team.number intValue]]];
    }
    NSString *exportFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_%@.pck", match, team]];
    NSData *myData = [self packageScoreForXFer:score];
    [myData writeToFile:exportFile atomically:YES];*/

}

-(NSData *)packageScoreForXFer:(TeamScore *)score {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    for (NSString *item in teamScoreAttributes) {
        if ([score valueForKey:item] && [score valueForKey:item] != [[teamScoreAttributes valueForKey:item] valueForKey:@"defaultValue"]) {
            [keyList addObject:item];
            [valueList addObject:[score valueForKey:item]];
        }
    }
    if (score.autonDrawing && score.autonDrawing.trace) {
        [keyList addObject:@"autonDrawing"];
        [valueList addObject:score.autonDrawing.trace];
    }
    if (score.teleOpDrawing && score.teleOpDrawing.trace) {
        [keyList addObject:@"teleOpDrawing"];
        [valueList addObject:score.teleOpDrawing.trace];
    }
 /*   if (score.team) {
        [keyList addObject:@"teamNumber"];
        [valueList addObject:score.team.number];
    }
    if (score.match) {
        [keyList addObject:@"matchNumber"];
        [valueList addObject:score.match.number];
        [keyList addObject:@"matchType"];
        [valueList addObject:score.match.matchType];
    }*/
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    if ([score.match.number intValue] == 1) {
        NSLog(@"Match = %@, Type = %@, Team = %@, Results = %@", score.matchNumber, score.matchType, score.teamNumber, score.saved);
        NSLog(@"Data = %@", dictionary);
    }
    return myData;
}

-(TeamScore *)addScore:(TeamData *)team
           forAlliance:(NSString *)alliance
         forTournament:(NSString *)tournament
{
    // Error checking
    TournamentData *tournamentRecord = [DataConvenienceMethods getTournament:tournament fromContext:_dataManager.managedObjectContext];
    if (!tournamentRecord) return nil; // Tournament does not exist. Bail out!!
    
    NSUInteger allianceSection = [self getAllianceSection:alliance];
    if (allianceSection == -1) return nil; // Invalid alliance selection. Bail out!!
    
    
    TeamScore *teamScore = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore"
                                                         inManagedObjectContext:_dataManager.managedObjectContext];
 //   [teamScore setTeam:team];
//    [teamScore setAlliance:alliance];
//    [teamScore setAllianceSection:[NSNumber numberWithInt:allianceSection]];
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
