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
#import "MatchUtilities.h"
#import "TeamAccessors.h"
#import "MatchAccessors.h"
#import "ScoreAccessors.h"
#import "FieldDrawing.h"
#import "DataConvenienceMethods.h"
#import "EnumerationDictionary.h"

@implementation ScoreUtilities {
    NSDictionary *allianceDictionary;
    NSDictionary *matchTypeDictionary;
    MatchUtilities *matchUtilities;
    NSDictionary *teamScoreAttributes;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
        matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
 	}
	return self;
}

-(TeamScore *)addTeamScoreToMatch:(MatchData *)match forAlliance:(NSString *)alliance forTeam:(NSNumber *)teamNumber error:(NSError **)error {
    NSString *msg;
    // Check team to make sure it exists
    NSString *matchTypeString = [EnumerationDictionary getKeyFromValue:match.matchType forDictionary:matchTypeDictionary];
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
    NSNumber *allianceStation = [EnumerationDictionary getValueFromKey:alliance forDictionary:allianceDictionary];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", allianceStation];
    NSArray *allianceList = [allScores filteredArrayUsingPredicate:pred];
    if ([allianceList count]) {
        for (TeamScore *score in allianceList) {
            if ([teamNumber intValue] == [score.teamNumber intValue]) continue; // This team is in this slot
            if ([score.results boolValue]) {
                msg = [NSString stringWithFormat:@"Results already exist for %@ Match %@, Alliance %@", matchTypeString, match.number, alliance];
                *error = [NSError errorWithDomain:@"addTeamScoreToMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                return nil;
            }
            else {
                [match removeScoreObject:score];
                [_dataManager.managedObjectContext deleteObject:score];
                if ([score.results boolValue]) {
                    msg = [NSString stringWithFormat:@"Removing unused %@ Match %@, Alliance %@ Record", matchTypeString, match.number, alliance];
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
                    msg = [NSString stringWithFormat:@"%@ Match %@ Team %@ is already at alliance station %@", matchTypeString, score.matchNumber, score.teamNumber, [EnumerationDictionary getKeyFromValue:score.allianceStation forDictionary:allianceDictionary]];
                    *error = [NSError errorWithDomain:@"createNewScore" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    return nil;
                }
            }
        }
    }

    TeamScore *newScore = [self createNewScore:match forTeam:teamNumber forAllianceStation:allianceStation error:error];
    
    if (newScore) {
        [match addScoreObject:newScore];
        NSLog(@"score count = %ul", [[match.score allObjects] count]);
        return newScore;
    }
    msg = [NSString stringWithFormat:@"Unable to add %@ Match %@ Team %@ in alliance station %@", matchTypeString, match.number, teamNumber, alliance];
    *error = [NSError errorWithDomain:@"createNewScore" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
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
    
    if ([ScoreAccessors getScoreRecord:match.number forType:match.matchType forAlliance:allianceStation forTournament:match.tournamentName fromDataManager:_dataManager]) {
        NSString *msg = [NSString stringWithFormat:@"%@ Match %@ for Alliance %@ already exists", match.matchType, match.number, allianceStation];
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
        NSString *msg = [NSString stringWithFormat:@"%@ Match %@ for Alliance %@ and Team %@ added", match.matchType, match.number, allianceStation, teamNumber];
        *error = [NSError errorWithDomain:@"createNewScore" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return score;
    }
    else {
        NSString *msg = [NSString stringWithFormat:@"Unable to add %@ Match %@ for Alliance %@ and Team %@", match.matchType, match.number, allianceStation, teamNumber];
        *error = [NSError errorWithDomain:@"createNewScore" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
}

-(NSDictionary *)unpackageScoreForXFer:(NSData *)xferData {
    if (!_dataManager) return Nil;
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
    NSNumber *matchNumber = [myDictionary objectForKey:@"matchNumber"];
    NSNumber *matchType = [myDictionary objectForKey:@"matchType"];
    NSString *matchTypeString = [EnumerationDictionary getKeyFromValue:matchType forDictionary:matchTypeDictionary];
    NSString *tournamentName = [myDictionary objectForKey:@"tournamentName"];
    NSNumber *teamNumber = [myDictionary objectForKey:@"teamNumber"];
    NSNumber *alliance = [myDictionary objectForKey:@"allianceStation"];
    NSString *allianceString = [EnumerationDictionary getKeyFromValue:alliance forDictionary:allianceDictionary];
    NSLog(@"%@", myDictionary);
    MatchData *match = [MatchAccessors getMatch:matchNumber forType:matchType forTournament:tournamentName fromDataManager:_dataManager];
    if (!match) {
        // Match does not already exist (someone probably forgot to transfer the match schedule)
        if(!matchUtilities) matchUtilities = [[MatchUtilities alloc] init:_dataManager];
        NSArray *teamList = [[NSArray alloc] initWithObjects:[NSDictionary dictionaryWithObject:teamNumber forKey:alliance], nil];
        match = [matchUtilities addMatch:matchNumber forMatchType:matchTypeString forTeams:teamList forTournament:tournamentName];
        if (!match) return Nil;
    }

    // Fetch score record
    // Copy the data into the right places
    // Put the match drawing in the correct directory
    TeamScore *score = [ScoreAccessors getScoreRecord:matchNumber forType:matchType forAlliance:alliance forTournament:tournamentName fromDataManager:_dataManager];
    if (!score) return Nil;
    
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    // check retrieved match, if the saved and saveby match the imcoming data then just do nothing
    NSNumber *saved = [myDictionary objectForKey:@"saved"];
    NSString *savedBy = [myDictionary objectForKey:@"savedBy"];

    if ([saved floatValue] == [score.saved floatValue] && [savedBy isEqualToString:score.savedBy]) {
        NSLog(@"Match has already transferred, match = %@", score.matchNumber);
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"alliance", @"team", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:score.matchNumber, matchTypeString, allianceString, score.teamNumber, @"N", nil];
        NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        return teamTransfer;
    }

    for (NSString *key in myDictionary) {
        if ([key isEqualToString:@"matchNumber"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"matchType"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"tournamentName"]) continue; // Already resolved
        if ([key isEqualToString:@"teamNumber"]) continue; // Comes with the relationship
        if ([key isEqualToString:@"fieldDrawing"]) continue; // Needs
        if ([teamScoreAttributes valueForKey:key]) {
            [score setValue:[myDictionary objectForKey:key] forKey:key];
        }
    }
    if (!score.fieldDrawing) {
        FieldDrawing *drawing = [NSEntityDescription insertNewObjectForEntityForName:@"FieldDrawing"
                                                          inManagedObjectContext:_dataManager.managedObjectContext];
        score.fieldDrawing = drawing;
    }
    score.fieldDrawing.trace = [myDictionary objectForKey:@"fieldDrawing"];

    score.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    NSError *error = nil;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

    NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"alliance", @"team", @"transfer", nil];
    NSArray *objectList = [NSArray arrayWithObjects:score.matchNumber, matchTypeString, allianceString, score.teamNumber,  @"Y", nil];
    NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    return teamTransfer;
}


@end
