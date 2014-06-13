//
//  MatchDataInterfaces.m
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchDataInterfaces.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "TournamentDataInterfaces.h"
#import "TeamDataInterfaces.h"
#import "TeamScoreInterfaces.h"
#include "MatchTypeDictionary.h"

@implementation MatchDataInterfaces

@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)exportMatchForXFer:(MatchData *)match toFile:(NSString *)exportFilePath {
    NSString *baseName;
    if ([match.number intValue] < 10) {
        baseName = [NSString stringWithFormat:@"M%c%@", [match.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [match.number intValue]]];
    } else if ( [match.number intValue] < 100) {
        baseName = [NSString stringWithFormat:@"M%c%@", [match.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [match.number intValue]]];
    } else {
        baseName = [NSString stringWithFormat:@"M%c%@", [match.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [match.number intValue]]];
    }
    NSString *exportFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pck", baseName]];
    NSData *myData = [self packageMatchForXFer:match];
    [myData writeToFile:exportFile atomically:YES];
}

-(NSData *)packageMatchForXFer:(MatchData *)match {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!_matchDataAttributes) _matchDataAttributes = [[match entity] attributesByName];
    for (NSString *item in _matchDataAttributes) {
        if ([match valueForKey:item]) {
            [keyList addObject:item];
            [valueList addObject:[match valueForKey:item]];
        }
    }

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

    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    // NSLog(@"sending %@", dictionary);
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    return myData;

}

-(NSDictionary *)unpackageMatchForXFer:(NSData *)xferData {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
    NSNumber *matchNumber = [myDictionary objectForKey:@"number"];
    NSString *matchType = [myDictionary objectForKey:@"matchType"];
    NSString *tournamentName = [myDictionary objectForKey:@"tournamentName"];
    if (!matchNumber || !matchType || !tournamentName) return nil;
    //NSLog(@"receiving %@", myDictionary);
    
    MatchData *matchRecord = [self getMatch:matchNumber forMatchType:matchType forTournament:tournamentName];
    if (!matchRecord) {
        matchRecord = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData"
                                                    inManagedObjectContext:_dataManager.managedObjectContext];
    }
    // check retrieved match, if the saved and saveby match the imcoming data then just do nothing
    NSNumber *saved = [myDictionary objectForKey:@"saved"];
    NSString *savedBy = [myDictionary objectForKey:@"savedBy"];
    
    if ([saved floatValue] == [matchRecord.saved floatValue] && [savedBy isEqualToString:matchRecord.savedBy]) {
        // NSLog(@"Match has already transferred, match = %@", score.match.number);
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:matchRecord.number, matchRecord.matchType, @"N", nil];
        NSDictionary *matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        return matchTransfer;
    }

    for (NSString *key in myDictionary) {
        if ([key isEqualToString:@"teams"]) continue; // Skip the team list for the moment
        [matchRecord setValue:[myDictionary objectForKey:key] forKey:key];
    }
    NSDictionary *teams = [myDictionary objectForKey:@"teams"];
    for (NSString *key in teams) {
        [[[TeamScoreInterfaces alloc] initWithDataManager:_dataManager] addScoreToMatch:matchRecord forTeam:[teams objectForKey:key] forAlliance:key];
    }
    [self addBlankScores:matchRecord];
    // NSLog(@"Teams = %@", teams);
    matchRecord.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"teams", @"transfer", nil];
    NSArray *objectList = [NSArray arrayWithObjects:matchRecord.number, matchRecord.matchType, teams, @"Y", nil];
    NSDictionary *matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    return matchTransfer;
}

-(MatchData *)updateMatch:(NSDictionary *)matchInfo {
    // NSLog(@"Match data = %@", matchInfo);
    NSNumber *matchNumber = [matchInfo objectForKey:@"number"];
    NSString *matchType = [matchInfo objectForKey:@"matchType"];
    NSString *tournamentName = [matchInfo objectForKey:@"tournamentName"];
    if (!matchNumber || !matchType || !tournamentName) return nil;
    MatchData *matchRecord = [self getMatch:matchNumber forMatchType:matchType forTournament:tournamentName];
    if (!matchRecord) {
        matchRecord = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData"
                                                    inManagedObjectContext:_dataManager.managedObjectContext];
    }
    for (NSString *key in matchInfo) {
        if ([key isEqualToString:@"teams"]) continue; // Skip the team list for the moment
        [matchRecord setValue:[matchInfo objectForKey:key] forKey:key];
    }
    MatchTypeDictionary *matchDictionary = [[MatchTypeDictionary alloc] init];
    matchRecord.matchTypeSection = [matchDictionary getMatchTypeEnum:matchType];
    NSDictionary *teams = [matchInfo objectForKey:@"teams"];
    for (NSString *key in teams) {
        [[[TeamScoreInterfaces alloc] initWithDataManager:_dataManager] addScoreToMatch:matchRecord forTeam:[teams objectForKey:key] forAlliance:key];
    }
    [self addBlankScores:matchRecord];
    // NSLog(@"Teams = %@", teams);
    matchRecord.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    matchRecord.savedBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceName"];
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        return nil;
    }
    return matchRecord;
    // NSLog(@"Match record = %@", matchRecord);
}

-(void)addBlankScores:(MatchData *)match {
    NSArray *allScores = [match.score allObjects];
    int teamsInMatch = [allScores count];
    if (teamsInMatch < 6) {
        TeamScore *blankScore;
        TeamScoreInterfaces *teamScoreInterface = [[TeamScoreInterfaces alloc] initWithDataManager:_dataManager];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Red 1"];
        NSArray *matches = [allScores filteredArrayUsingPredicate:pred];
        if (![matches count]) {
            blankScore = [teamScoreInterface addScore:nil forAlliance:@"Red 1" forTournament:match.tournamentName];
            [match addScoreObject:blankScore];
        }
        pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Red 2"];
        matches = [allScores filteredArrayUsingPredicate:pred];
        if (![matches count]) {
            blankScore = [teamScoreInterface addScore:nil forAlliance:@"Red 2" forTournament:match.tournamentName];
            [match addScoreObject:blankScore];
        }
        pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Red 3"];
        matches = [allScores filteredArrayUsingPredicate:pred];
        if (![matches count]) {
            blankScore = [teamScoreInterface addScore:nil forAlliance:@"Red 3" forTournament:match.tournamentName];
            [match addScoreObject:blankScore];
        }
        pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Blue 1"];
        matches = [allScores filteredArrayUsingPredicate:pred];
        if (![matches count]) {
            blankScore = [teamScoreInterface addScore:nil forAlliance:@"Blue 1" forTournament:match.tournamentName];
            [match addScoreObject:blankScore];
        }
        pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Blue 2"];
        matches = [allScores filteredArrayUsingPredicate:pred];
        if (![matches count]) {
            blankScore = [teamScoreInterface addScore:nil forAlliance:@"Blue 2" forTournament:match.tournamentName];
            [match addScoreObject:blankScore];
        }
        pred = [NSPredicate predicateWithFormat:@"alliance = %@", @"Blue 3"];
        matches = [allScores filteredArrayUsingPredicate:pred];
        if (![matches count]) {
            blankScore = [teamScoreInterface addScore:nil forAlliance:@"Blue 3" forTournament:match.tournamentName];
            [match addScoreObject:blankScore];
        }
    }
}

-(MatchData *)getMatch:(NSNumber *)matchNumber forMatchType:(NSString *) type forTournament:(NSString *) tournament {
    MatchData *match;
    
    //    NSLog(@"Searching for match = %@", matchNumber);
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"number == %@ AND matchType == %@ and tournamentName = %@", matchNumber, type, tournament];
    [fetchRequest setPredicate:predicate];
    
    NSArray *matchData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([matchData count] > 0) {  // Match Exists
            match = [matchData objectAtIndex:0];
            //    NSLog(@"Match %@ exists", match.number);
            return match;
        }
        else {
            return Nil;
        }
    }
}


@end
