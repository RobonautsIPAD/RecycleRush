//
//  ScoreUtilities.m
//  RecycleRush
//
//  Created by FRC on 10/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ScoreUtilities.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "MatchUtilities.h"
#import "TeamAccessors.h"
#import "MatchAccessors.h"
#import "ScoreAccessors.h"
#import "FieldDrawing.h"
#import "FieldPhoto.h"
#import "DataConvenienceMethods.h"
//#import "EnumerationDictionary.h"

@implementation ScoreUtilities {
    NSDictionary *allianceDictionary;
    NSDictionary *matchTypeDictionary;
    MatchUtilities *matchUtilities;
    NSDictionary *teamScoreAttributes;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        allianceDictionary = _dataManager.allianceDictionary;
        matchTypeDictionary = _dataManager.matchTypeDictionary;
 	}
	return self;
}

-(TeamScore *)addTeamScoreToMatch:(MatchData *)match forAlliance:(NSString *)allianceString forTeam:(NSNumber *)teamNumber error:(NSError **)error {
    NSString *msg;
    // Check team to make sure it exists
    NSString *matchTypeString = [MatchAccessors getMatchTypeString:match.matchType fromDictionary:matchTypeDictionary];
    if (![TeamAccessors getTeam:teamNumber inTournament:match.tournamentName fromDataManager:_dataManager]) {
        msg = [NSString stringWithFormat:@"%@ Match %@ Team %@ does not exist", matchTypeString, match.number, teamNumber];
        *error = [NSError errorWithDomain:@"addTeamScoreToMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    // NSLog(@"Team %@ exists", teamNumber);
    // Check match to make sure this match doesn't already have a score record in this slot
    // If there is already a score record, check to see if it is the same team we are addiing. If so, do
    // nothing, we're just trying to add something that is already there.
    // If the team number doesn't match, then check to see if the score record has results. If it does, then
    // there is a problem and an error message will be issues.
    // If there are no results, then, most likely, the match schedule has been updated. Delete the unused record
    // and create a new one.
    NSArray *allScores = [match.score allObjects];
    if (!allScores) return FALSE;
    NSNumber *allianceStation = [MatchAccessors getAllianceStation:allianceString fromDictionary:allianceDictionary];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", allianceStation];
    NSArray *allianceList = [allScores filteredArrayUsingPredicate:pred];
    if ([allianceList count]) {
        for (TeamScore *score in allianceList) {
            if ([teamNumber intValue] == [score.teamNumber intValue]) continue; // This team is in this slot
            if ([score.results boolValue]) {
                msg = [NSString stringWithFormat:@"Results already exist for %@ Match %@, Alliance %@", matchTypeString, match.number, allianceString];
                *error = [NSError errorWithDomain:@"addTeamScoreToMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                return nil;
            }
            else {
                [match removeScoreObject:score];
                [_dataManager.managedObjectContext deleteObject:score];
                if ([score.results boolValue]) {
                    msg = [NSString stringWithFormat:@"Removing unused %@ Match %@, Alliance %@ Record", matchTypeString, match.number, allianceString];
                    *error = [NSError errorWithDomain:@"addTeamScoreToMatch" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                }
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
                    msg = [NSString stringWithFormat:@"%@ Match %@ Team %@ is already at alliance station %@", matchTypeString, score.matchNumber, score.teamNumber, [MatchAccessors getAllianceString:score.allianceStation fromDictionary:allianceDictionary]];
                    *error = [NSError errorWithDomain:@"createNewScore" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    return nil;
                }
            }
        }
    }

    TeamScore *newScore = [self createNewScore:match forTeam:teamNumber forAllianceStation:allianceStation error:error];
    
    if (newScore) {
        [match addScoreObject:newScore];
        //NSLog(@"%@ Match %@ for Alliance %@ and Team %@ added", matchTypeString, match.number, allianceString, teamNumber);
        return newScore;
    }
/*    msg = [NSString stringWithFormat:@"Unable to add %@ Match %@ Team %@ in alliance station %@", matchTypeString, match.number, teamNumber, allianceString];
    *error = [NSError errorWithDomain:@"createNewScore" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];*/
    return nil;
 }

-(TeamScore *)createNewScore:(MatchData *)match forTeam:(NSNumber *)teamNumber forAllianceStation:(NSNumber *)allianceStation error:(NSError **)error {
    if (!teamNumber || ([teamNumber intValue] < 1)) {
        NSString *msg = [NSString stringWithFormat:@"Invalid team %@", teamNumber];
        *error = [NSError errorWithDomain:@"createNewScore" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    if (![TeamAccessors getTeam:teamNumber inTournament:match.tournamentName fromDataManager:_dataManager]) {
        NSString *msg = [NSString stringWithFormat:@"Team %@ does exist in Tournament %@", teamNumber, match.tournamentName];
        *error = [NSError errorWithDomain:@"createNewTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    
    NSString *matchTypeString = [MatchAccessors getMatchTypeString:match.matchType fromDictionary:matchTypeDictionary];
    NSString *allianceString = [MatchAccessors getAllianceString:allianceStation fromDictionary:allianceDictionary];
    if ([ScoreAccessors getScoreRecord:match.number forType:match.matchType forAlliance:allianceStation forTournament:match.tournamentName fromDataManager:_dataManager]) {
        NSString *msg = [NSString stringWithFormat:@"%@ Match %@ for Alliance %@ already exists", matchTypeString, match.number, allianceString];
        *error = [NSError errorWithDomain:@"createNewScore" code:kInfoMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    
    TeamScore *score = [NSEntityDescription insertNewObjectForEntityForName:@"TeamScore"
                                             inManagedObjectContext:_dataManager.managedObjectContext];

    if (score) {
        // Set the 4 items that need to be set to define a unique record
        score.matchNumber = match.number;
        score.matchType = match.matchType;
        score.allianceStation = allianceStation;
        score.tournamentName = match.tournamentName;
    
        // Set the team number
        score.teamNumber = teamNumber;
        NSString *msg = [NSString stringWithFormat:@"%@ Match %@ for Alliance %@ and Team %@ added", matchTypeString, match.number, allianceString, teamNumber];
        *error = [NSError errorWithDomain:@"createNewScore" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return score;
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"Unable to add %@ Match %@ for Alliance %@ and Team %@", matchTypeString, match.number, allianceString, teamNumber];
        *error = [NSError errorWithDomain:@"createNewScore" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
}

-(TeamScore *)scoreReset:(TeamScore *)score {
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    for (NSString *key in teamScoreAttributes) {
        if ([key isEqualToString:@"matchNumber"]) continue;
        if ([key isEqualToString:@"matchType"]) continue;
        if ([key isEqualToString:@"tournamentName"]) continue;
        if ([key isEqualToString:@"teamNumber"]) continue;
        if ([key isEqualToString:@"allianceStation"]) continue;
        id defaultValue = [[teamScoreAttributes valueForKey:key] valueForKey:@"defaultValue"];
        [score setValue:defaultValue forKeyPath:key];
    }
    score.fieldPhotoName = nil;
    score.notes = nil;
    score.robotType = nil;
    score.autonDrawing = nil;
    score.teleOpDrawing = nil;
    [_dataManager saveContext];
    return score;
}

-(NSDictionary *)packageScoreForXFer:(TeamScore *)score {
    if (!_dataManager) {
        NSError *error = [NSError errorWithDomain:@"packageScoreForBluetooth" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing data manager" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    for (NSString *item in teamScoreAttributes) {
        if ([score valueForKey:item]) {
            // if (![DataConvenienceMethods compareAttributeToDefault:[score valueForKey:item] forAttribute:[teamScoreAttributes valueForKey:item]]) {
            [keyList addObject:item];
            [valueList addObject:[score valueForKey:item]];
            // }
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
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
/*    if ([score.match.number intValue] == 1) {
        NSLog(@"Match = %@, Type = %@, Team = %@, Results = %@", score.matchNumber, score.matchType, score.teamNumber, score.saved);
        NSLog(@"Data = %@", dictionary);
    }*/
    return dictionary;
}

-(NSDictionary *)unpackageScoreForXFer:(NSDictionary *)xferDictionary {
    NSError *error = nil;
    if (!_dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"unpackageScoreForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSNumber *matchNumber = [xferDictionary objectForKey:@"matchNumber"];
    NSNumber *matchType = [xferDictionary objectForKey:@"matchType"];
    NSString *matchTypeString = [MatchAccessors getMatchTypeString:matchType fromDictionary:matchTypeDictionary];
    NSString *tournamentName = [xferDictionary objectForKey:@"tournamentName"];
    NSNumber *teamNumber = [xferDictionary objectForKey:@"teamNumber"];
    NSNumber *allianceStation = [xferDictionary objectForKey:@"allianceStation"];
    NSString *allianceString = [MatchAccessors getAllianceString:allianceStation fromDictionary:allianceDictionary];
    NSLog(@"Unpackage Scores %@ %@", matchTypeString, matchNumber);
    MatchData *match = [MatchAccessors getMatch:matchNumber forType:matchType forTournament:tournamentName fromDataManager:_dataManager];
    if (!match) {
        // Match does not already exist (someone probably forgot to transfer the match schedule)
        if(!matchUtilities) matchUtilities = [[MatchUtilities alloc] init:_dataManager];
        NSArray *teamList = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObject:teamNumber forKey:allianceString], nil];
        match = [matchUtilities addMatch:matchNumber forMatchType:matchTypeString forTeams:teamList forTournament:tournamentName  error:&error];
        if (!match) return Nil;
    }
    NSLog(@"move addmatch outside of !match condition");

    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    TeamScore *score = [ScoreAccessors getScoreRecord:matchNumber forType:matchType forAlliance:allianceStation forTournament:tournamentName fromDataManager:_dataManager];
    if (!score) return Nil;
    
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    // check retrieved match, if the saved and saveby match the imcoming data then just do nothing
    NSNumber *saved = [xferDictionary objectForKey:@"saved"];

    if ([score.saved floatValue] > [saved floatValue]) {
        NSLog(@"Match has already transferred, match = %@", score.matchNumber);
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"alliance", @"team", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:score.matchNumber, matchTypeString, allianceString, score.teamNumber, @"N", nil];
        NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        return teamTransfer;
    }

    for (NSString *key in xferDictionary) {
        if ([key isEqualToString:@"matchNumber"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"matchType"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"tournamentName"]) continue; // Already resolved
        if ([key isEqualToString:@"teamNumber"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"autonDrawing"]) continue; // Needs
        if ([key isEqualToString:@"teleOpDrawing"]) continue; // Needs
        if ([teamScoreAttributes valueForKey:key]) {
            [score setValue:[xferDictionary objectForKey:key] forKey:key];
        }
    }
    // NSLog(@"%@", xferDictionary);
    if (!score.autonDrawing) {
        FieldDrawing *drawing = [NSEntityDescription insertNewObjectForEntityForName:@"FieldDrawing"
                                                          inManagedObjectContext:_dataManager.managedObjectContext];
        score.autonDrawing = drawing;
    }
    score.autonDrawing.trace = [xferDictionary objectForKey:@"autonDrawing"];

    if (!score.teleOpDrawing) {
        FieldDrawing *drawing = [NSEntityDescription insertNewObjectForEntityForName:@"FieldDrawing"
                                                              inManagedObjectContext:_dataManager.managedObjectContext];
        score.teleOpDrawing = drawing;
    }
    score.teleOpDrawing.trace = [xferDictionary objectForKey:@"teleOpDrawing"];

    score.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    if (![_dataManager saveContext]) {
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:score.matchNumber, matchTypeString, @"N", nil];
        NSDictionary *matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        NSString *msg = [NSString stringWithFormat:@"Database Save Error %@ %@", matchTypeString, matchNumber];
        error = [NSError errorWithDomain:@"unpackageScoreForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return matchTransfer;
    }

    NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"alliance", @"team", @"transfer", nil];
    NSArray *objectList = [NSArray arrayWithObjects:score.matchNumber, matchTypeString, allianceString, score.teamNumber,  @"Y", nil];
    NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    return teamTransfer;
}

@end
