//
//  MatchUtilities.m
//  AerialAssist
//
//  Created by FRC on 9/30/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchUtilities.h"
#import "DataManager.h"
#import "MatchData.h"
#import "ScoreUtilities.h"
#import "DataConvenienceMethods.h"
#import "FileIOMethods.h"
#import "EnumerationDictionary.h"
#import "parseCSV.h"


#define TEST_MODE
#ifdef TEST_MODE
#import "ExportMatchData.h"
#endif

@implementation MatchUtilities {
    NSDictionary *matchDataProperties;
    NSArray *attributeNames;
    NSArray *matchDataList;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    ScoreUtilities *scoreRecords;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        NSLog(@"init export team data");
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        matchDataProperties = [entity attributesByName];
        attributeNames = matchDataProperties.allKeys;
        [self initializePreferences];
        matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
        allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
        scoreRecords =[[ScoreUtilities alloc] init:_dataManager];
 	}
	return self;
}

-(void)createMatchFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
    
    if (![csvContent count]) return;
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];
    
    // Check the first header to make sure this is a match file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Match"]) return;
    
    NSMutableArray *columnDetails = [NSMutableArray array];
     NSLog(@"Header line = %@", headerLine);
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:attributeNames forDictionary:matchDataList];
        [columnDetails addObject:column];
    }
    
    // Find the match type and tournament name columns. These are required to uniquely define a match
    // I'm sure there is a better way, but for now I'm going brute force.
    int typeColumn = -1;
    int tournamentColumn = -1;
    for (int i=0; i <[columnDetails count]; i++) {
        NSDictionary *column = [columnDetails objectAtIndex:i];
        NSString *key = [column valueForKey:@"key"];
        if ([key isEqualToString:@"matchType"]) {
            typeColumn = i;
            matchTypeDictionary = [self getEnumDictionary:[column valueForKey:@"dictionary"]];
        }
        if ([key isEqualToString:@"tournamentName"]) tournamentColumn = i;
    }
    if (typeColumn < 0 || tournamentColumn < 0) {
        NSString *msg = [NSString stringWithFormat:@"Tournament or Match Type data missing from Match Data file"];
        [self errorAlertMessage:msg];
        return;
    }

    for (int c = 1; c < [csvContent count]; c++) {
        // Extract all the info needed to unqiuely define the match
            // Match Number, Match Type, Tournament
        NSArray *line = [NSArray arrayWithArray:[csvContent objectAtIndex:c]];
        // Already checked to make sure match number is in the first column
        NSNumber *matchNumber = [NSNumber numberWithInt:[[line objectAtIndex: 0] intValue]];
        // Get  the match type
        NSString *matchTypeString = [line objectAtIndex: typeColumn];
        // Get  the tournament
        NSString *tournament = [line objectAtIndex: tournamentColumn];
        NSLog(@"createMatchFromFile = %@", matchNumber);
        MatchData *match = [self createNewMatch:matchNumber forType:matchTypeString forTournament:tournament];
        if (!match) { // Unable to create team
            inputError = TRUE;
            NSString *msg = [NSString stringWithFormat:@"Error Creating Match %@ from Match Data file", match];
            [self errorAlertMessage:msg];
            continue;
        }
        // NSLog(@"%@", line);
        
        // Parse the rest of the line for any more data
        for (int i=1; i<[line count]; i++) {
            NSDictionary *column = [columnDetails objectAtIndex:i];
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"matchType"]) continue;
            if ([key isEqualToString:@"tournamentName"]) continue;
            // NSLog(@"%@", key);
            if ([key isEqualToString:@"Invalid Key"]) {
                // NSLog(@"Skipping");
                if (!inputError) {
                    // Only pop up one warning per file
                    inputError = TRUE;
                    NSString *msg = [NSString stringWithFormat:@"Invalid Data Member %@ from Match Data file", [headerLine objectAtIndex:i]];
                    [self errorAlertMessage:msg];
                }
                continue;
            }
            NSDictionary *enumDictionary = [self getEnumDictionary:[column valueForKey:@"dictionary"]];
            NSDictionary *description = [matchDataProperties valueForKey:key];
            if ([description isKindOfClass:[NSAttributeDescription class]]) {
                // NSLog(@"Key = %@", key);
                if ([DataConvenienceMethods setAttributeValue:match forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:enumDictionary]) {
                    if (!inputError) {
                        // Only pop up one warning per file
                        inputError = TRUE;
                        NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@ = %@, from Match Data file", [headerLine objectAtIndex:i], [line objectAtIndex:i]];
                        [self errorAlertMessage:msg];
                    }
                }
            }
            else {
                if ([key isEqualToString:@"score"]) {
                    NSLog(@"Adding team to match, fix to get error message");
                    NSString *errMsg = [scoreRecords addTeamScoreToMatch:match forAlliance:[column valueForKey:@"output"] forTeam:[self getNumber:[line objectAtIndex:i]]];
                  /*     if (!inputError) {
                            // Only pop up one warning per file
                            inputError = TRUE;
                            NSString *msg = [NSString stringWithFormat:@"Error adding Tournament %@ from Team Data file", [line objectAtIndex:i]];
                            [self errorAlertMessage:msg];
                        }*/
                    
                }
            }
        }
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        // NSLog(@"Team after full line = %@", team);
    }
    [parser closeFile];
    
#ifdef TEST_MODE
    [self testMatchUtilities];
#endif
    
}

-(MatchData *)createNewMatch:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTournament:(NSString *)tournament {
    // Check for input integrity
    if (!matchNumber || ([matchNumber intValue] < 1)) return nil;
    // Check match type to make sure it is valid
    NSNumber *matchType = [EnumerationDictionary getValueFromKey:matchTypeString forDictionary:matchTypeDictionary];
    if (!matchType) return nil;
    // Check to make sure tournament exists
    if (![DataConvenienceMethods getTournament:tournament fromContext:_dataManager.managedObjectContext]) return nil;

    MatchData *match = [DataConvenienceMethods getMatch:matchNumber forType:matchType forTournament:tournament fromContext:_dataManager.managedObjectContext];
    NSLog(@"match type = %@, tournament = %@", matchTypeString, tournament);
    if (match) return match;
    else {
        match = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData"
                                             inManagedObjectContext:_dataManager.managedObjectContext];
        if (match) {
            match.number = matchNumber;
            match.matchType = matchType;
            match.tournamentName = tournament;
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Unable to add Match %@ %@", matchType, matchNumber];
            [self errorAlertMessage:msg];
        }
        return match;
    }
}

-(id)getEnumDictionary:(NSString *) dictionaryName {
    if (!dictionaryName) {
        return nil;
    }
    if ([dictionaryName isEqualToString:@"matchTypeDictionary"]) {
        if (!matchTypeDictionary) matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
        return matchTypeDictionary;
    }
    else return nil;
}

-(NSString *)addMatch:(NSNumber *)matchNumber forMatchType:(NSString *)matchType forTeams:(NSArray *)teamList forTournament:(NSString *)tournamentName {
    NSString *error;
    MatchData *match = [self createNewMatch:matchNumber forType:matchType forTournament:tournamentName];
    if (!match) return @"Unable to add match";
    NSLog(@"%@", teamList);
    for (NSDictionary *team in teamList) {
        NSArray *keys = [team allKeys];
        if (keys && [keys count]) {
            NSString *key = [keys objectAtIndex:0];
            error = [scoreRecords addTeamScoreToMatch:match forAlliance:key forTeam:[NSNumber numberWithInt:[[team objectForKey:key] intValue]]];
        }
    }
    NSError *err;
    if (![_dataManager.managedObjectContext save:&err]) {
        NSLog(@"Whoops, couldn't save: %@", [err localizedDescription]);
    }
    return error;
}

-(NSNumber *)getNumber:inputData {
    NSScanner *scanner = [NSScanner scannerWithString:inputData];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    // NSLog(@"Is numeric??? %d", isNumeric);
    if (isNumeric) {
        return [NSNumber numberWithInt:[inputData intValue]];
    }
    else return Nil;
}

-(NSNumber *)getTeamFromList:(NSArray *)teamList forAllianceStation:(NSNumber *)allianceStation {
    if (!teamList || ![teamList count]) return Nil;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", allianceStation];
    NSArray *team = [teamList filteredArrayUsingPredicate:pred];
    if (!team || ![team count]) return Nil;
    return [[team objectAtIndex:0] valueForKey:@"teamNumber"];
}

-(void)initializePreferences {
    // Create a dictionary with
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MatchData" ofType:@"plist"];
    matchDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
}


-(void)errorAlertMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Match Data Error"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    [alert show];
}

#ifdef TEST_MODE
-(void)testMatchUtilities {
    NSLog(@"Testing Match Utilities");
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSSortDescriptor *tournamentDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tournamentName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:tournamentDescriptor, typeDescriptor, numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *matchData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Total Matches = %d", [matchData count]);
    
    ExportMatchData *matchDataPackage = [[ExportMatchData alloc] init:_dataManager];
    for (MatchData *match in matchData) {
        NSData *xferData = [matchDataPackage packageMatchForXFer:match];
    }
}
#endif

@end
