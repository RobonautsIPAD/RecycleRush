//
//  CalculateTeamStats.m
// Robonauts Scouting
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "CalculateTeamStats.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamUtilities.h"
#import "TeamScore.h"
#import "MatchData.h"
#import "TournamentData.h"
#import "ScoreAccessors.h"
#import "EnumerationDictionary.h"

@implementation CalculateTeamStats {
    NSDictionary *matchTypeDictionary;
    TeamUtilities *teamUtilities;
    NSString *plistPath;
    NSArray *parameterList;
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        teamUtilities = [[TeamUtilities alloc] init:_dataManager];
        matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
        // Load dictionary with list of parameters for the scouting spreadsheet
        plistPath = [[NSBundle mainBundle] pathForResource:@"StatCalculate" ofType:@"plist"];
        parameterList = [[NSArray alloc] initWithContentsOfFile:plistPath];
	}
	return self;
}

-(NSMutableDictionary *)calculateMasonStats:(TeamData *)team forTournament:(NSString *)tournament {
    NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
   if (!team) {
        return nil;
    }
    // fetch all score records for this tournament
    NSArray *allMatches = [ScoreAccessors getMatchListForTeam:team.number forTournament:tournament fromDataManager:_dataManager];
    if (![allMatches count]) return stats;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ AND (matchType = %@ || matchType = %@)", tournament, [NSNumber numberWithBool:YES], [EnumerationDictionary getValueFromKey:@"Qualification" forDictionary:matchTypeDictionary], [EnumerationDictionary getValueFromKey:@"Elimination" forDictionary:matchTypeDictionary]];
    NSArray *matches = [allMatches filteredArrayUsingPredicate:pred];
    NSUInteger numberOfMatches = [matches count];
    for (int j=1; j<[parameterList count]; j++) {
        NSDictionary *parameter = [parameterList objectAtIndex:j];
        float total = 0.0;
        float percentDenominator = 0.0;
        NSString *percentItems = [parameter objectForKey:@"percent"];
        NSArray *percentKeys;
        if (percentItems) {
            percentKeys = [percentItems componentsSeparatedByString:@", "];
        }
        NSString *skipZeros = [parameter objectForKey:@"skipZeros"];
        int count=0;
        for (int i=0; i<numberOfMatches; i++) {
            TeamScore *match = [matches objectAtIndex:i];
            float item = [[match valueForKey:[parameter objectForKey:@"key"]] floatValue];
            // Add skipZeros stuff
            if (skipZeros && [skipZeros boolValue]) {
                if (fabs(item) > 0.000001) {
                    total += item;
                    count++;
                }
            }
            else {
                total += item;
                count++;
            }
            for (NSString *key in percentKeys) {
                percentDenominator += [[match valueForKey:key] floatValue];
            }
        }
        if (count) {
            float average = total/count;
            NSMutableDictionary *calculation = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithFloat:average], [NSNumber numberWithFloat:total], nil] forKeys:[NSArray arrayWithObjects:@"average", @"total", nil]];
            if (percentItems && percentDenominator) {
                float percent  = total/percentDenominator;
                [calculation setObject:[NSNumber numberWithFloat:percent] forKey:@"percent"];
            }
            [stats setObject:calculation forKey:[parameter objectForKey:@"name"]];
        }
    }
    [stats setObject:[NSNumber numberWithInteger:numberOfMatches] forKey:@"matches"];
    return stats;
}
//        NSArray *allKeys = [list componentsSeparatedByString:@", "];


@end
