//
//  MatchUtilities.m
//  RecycleRush
//
//  Created by FRC on 9/30/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchUtilities.h"
#import "DataManager.h"
#import "MatchData.h"
#import "ScoreUtilities.h"
#import "DataConvenienceMethods.h"
#import "MatchAccessors.h"
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
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        matchDataProperties = [entity attributesByName];
        attributeNames = matchDataProperties.allKeys;
        [self initializePreferences];
        matchTypeDictionary = _dataManager.matchTypeDictionary;
        allianceDictionary = _dataManager.allianceDictionary;
        scoreRecords =[[ScoreUtilities alloc] init:_dataManager];
 	}
	return self;
}

-(BOOL)createMatchFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
    NSError *error = nil;
    
    if (![csvContent count]) return inputError;
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];
    
    // Check the first header to make sure this is a match file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Match"]) return inputError;
    
    NSMutableArray *columnDetails = [NSMutableArray array];
    // NSLog(@"Header line = %@", headerLine);
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:attributeNames forDictionary:matchDataList error:&error];
        [columnDetails addObject:column];
    }
    if (error) {
        [_dataManager writeErrorMessage:error forType:kErrorMessage];
        inputError = TRUE;
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
        NSString *msg = @"Tournament or Match Type data missing from Match Data file";
        error = [NSError errorWithDomain:@"createMatchFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        inputError = TRUE;
        [_dataManager writeErrorMessage:error forType:[error code]];
        return inputError;
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
        // NSLog(@"createMatchFromFile = %@", matchNumber);
        MatchData *match = [self createNewMatch:matchNumber forType:matchTypeString forTournament:tournament error:&error];
        if (error) [_dataManager writeErrorMessage:error forType:[error code]];
        if (!match) { // Unable to create match
            inputError = TRUE;
            continue;
        }
        // NSLog(@"%@", line);
        
        // Parse the rest of the line for any more data
        for (int i=1; i<[line count]; i++) {
            error = nil;
            NSDictionary *column = [columnDetails objectAtIndex:i];
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"matchType"]) continue;
            if ([key isEqualToString:@"tournamentName"]) continue;
            // NSLog(@"%@", key);
            if ([key isEqualToString:@"Invalid Key"]) continue; // Error message already generated
            NSDictionary *enumDictionary = [self getEnumDictionary:[column valueForKey:@"dictionary"]];
            NSDictionary *description = [matchDataProperties valueForKey:key];
            if ([description isKindOfClass:[NSAttributeDescription class]]) {
                // NSLog(@"Key = %@", key);
                if ([DataConvenienceMethods setAttributeValue:match forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:enumDictionary]) {
                    inputError = TRUE;
                    NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@ = %@, from Match Data file",[headerLine objectAtIndex:i], [line objectAtIndex:i]];
                    error = [NSError errorWithDomain:@"createMatchFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    [_dataManager writeErrorMessage:error forType:[error code]];
                }
            }
            else {
                if ([key isEqualToString:@"score"]) {
                    if (![scoreRecords addTeamScoreToMatch:match forAlliance:[column valueForKey:@"output"] forTeam:[self getNumber:[line objectAtIndex:i]] error:&error]) {
                        inputError = TRUE;
                    }
                    if (error) [_dataManager writeErrorMessage:error forType:[error code]];                    
                }
            }
        }
        if (![_dataManager saveContext]) {
            inputError = TRUE;
        }
       // NSLog(@"Team after full line = %@", team);
    }
    [parser closeFile];
    
#ifdef TEST_MODE
    [self testMatchUtilities];
#endif
    return inputError;
}

-(MatchData *)createNewMatch:(NSNumber *)matchNumber forType:(NSString *)matchTypeString forTournament:(NSString *)tournament  error:(NSError **)error {
    // Check for input integrity
    if (!matchNumber || ([matchNumber intValue] < 1)) {
        NSString *msg = [NSString stringWithFormat:@"Invalid Match %@ %@", matchTypeString, matchNumber];
        *error = [NSError errorWithDomain:@"createNewMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }

    // Check match type to make sure it is valid
    NSNumber *matchType = [MatchAccessors getMatchTypeFromString:matchTypeString fromDictionary:matchTypeDictionary];
    if (!matchType) {
        NSString *msg = [NSString stringWithFormat:@"Invalid Match Type %@", matchTypeString];
        *error = [NSError errorWithDomain:@"createMatchFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    // Check to make sure tournament exists
    if (![DataConvenienceMethods getTournament:tournament fromContext:_dataManager.managedObjectContext]) {
        NSString *msg = [NSString stringWithFormat:@"Invalid Tournament %@ for Match %@ %@", tournament, matchTypeString, matchNumber];
        *error = [NSError errorWithDomain:@"createNewMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }

    MatchData *match = [MatchAccessors getMatch:matchNumber forType:matchType forTournament:tournament fromDataManager:_dataManager];
    // NSLog(@"match type = %@, tournament = %@", matchTypeString, tournament);
    if (match) {
        NSString *msg = [NSString stringWithFormat:@"%@ Match %@ already exists", matchTypeString, match.number];
        *error = [NSError errorWithDomain:@"createNewMatch" code:kInfoMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return match;
    }
    else {
        match = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData"
                                             inManagedObjectContext:_dataManager.managedObjectContext];
        if (match) {
            match.number = matchNumber;
            match.matchType = matchType;
            match.tournamentName = tournament;
            NSString *msg = [NSString stringWithFormat:@"%@ Match %@ added", matchTypeString, matchNumber];
            *error = [NSError errorWithDomain:@"createNewMatch" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Unable to add %@ Match %@", matchTypeString, matchNumber];
            *error = [NSError errorWithDomain:@"createNewMatch" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        }
        return match;
    }
}

-(id)getEnumDictionary:(NSString *) dictionaryName {
    if (!dictionaryName) {
        return nil;
    }
    if ([dictionaryName isEqualToString:@"matchTypeDictionary"]) {
        return matchTypeDictionary;
    }
    else return nil;
}

-(MatchData *)addMatch:(NSNumber *)matchNumber forMatchType:(NSString *)matchType forTeams:(NSDictionary *)teamList forTournament:(NSString *)tournamentName error:(NSError **)error {
    MatchData *match = [self createNewMatch:matchNumber forType:matchType forTournament:tournamentName error:error];
    if (!match) return nil; // Unable to create match, error retains value from getMatch
    NSInteger count = [teamList count];
    id __unsafe_unretained teamNumbers[count];
    id __unsafe_unretained alliance[count];
    
    [teamList getObjects:teamNumbers andKeys:alliance];
    for (int i=0; i<count; i++) {
        NSLog(@"%@ = %@", alliance[i], teamNumbers[i]);
        NSLog(@"add match messaging");
        if (![scoreRecords addTeamScoreToMatch:match forAlliance:alliance[i] forTeam:teamNumbers[i] error:error]) {
            
        }
        if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
    }
    for (NSDictionary *team in teamList) {
        NSArray *keys = [team allKeys];
        if (keys && [keys count]) {
            NSString *key = [keys objectAtIndex:0];
            NSLog(@"add match messaging");
            if (![scoreRecords addTeamScoreToMatch:match forAlliance:key forTeam:[NSNumber numberWithInt:[[team objectForKey:key] intValue]] error:error]) {
                
            }
            if (*error) [_dataManager writeErrorMessage:*error forType:[*error code]];
        }
    }
    return match;
}

-(NSDictionary *)unpackageMatchForXFer:(NSData *)xferData {
    NSError *error = nil;
    if (!_dataManager) {
        error = [NSError errorWithDomain:@"unpackageMatchForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
    NSNumber *matchNumber = [myDictionary objectForKey:@"number"];
    NSNumber *matchType = [myDictionary objectForKey:@"matchType"];
    NSString *matchTypeString = [MatchAccessors getMatchTypeString:matchType fromDictionary:matchTypeDictionary];
    NSString *tournamentName = [myDictionary objectForKey:@"tournamentName"];
    if (!matchNumber || !matchType || !tournamentName) {
        NSString *msg = [NSString stringWithFormat:@"Invalid match number, match type or tournament name %@ %@ %@", tournamentName, matchTypeString, matchNumber];
        error = [NSError errorWithDomain:@"unpackageMatchForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }

    // NSLog(@"receiving %@", myDictionary);
    MatchData *matchRecord = [MatchAccessors getMatch:matchNumber forType:matchType forTournament:tournamentName fromDataManager:_dataManager];
    
    if (matchRecord) {
        // check retrieved match, if the saved and saveby match the imcoming data then just do nothing
        NSNumber *saved = [myDictionary objectForKey:@"saved"];
        NSString *savedBy = [myDictionary objectForKey:@"savedBy"];
        if (saved && savedBy) {
            if ([saved floatValue] == [matchRecord.saved floatValue] && [savedBy isEqualToString:matchRecord.savedBy]) {
                // NSLog(@"Match has already transferred, match = %@", score.match.number);
                NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"transfer", nil];
                NSArray *objectList = [NSArray arrayWithObjects:matchRecord.number, matchTypeString, @"N", nil];
                NSDictionary *matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
                NSString *msg = [NSString stringWithFormat:@"Match has already transferred, %@ %@", matchTypeString, matchNumber];
                error = [NSError errorWithDomain:@"unpackageMatchForXFer" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                [_dataManager writeErrorMessage:error forType:[error code]];
                return matchTransfer;
            }
        }
    }
    NSDictionary *teams = [myDictionary objectForKey:@"teams"];
    NSLog(@"%@", teams);
    MatchData *match = [self addMatch:matchNumber forMatchType:matchTypeString forTeams:teams forTournament:tournamentName error:&error];
    if (!match) {
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:matchNumber, matchTypeString, @"N", nil];
        NSDictionary *matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return matchTransfer;
    }

    match.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    if (![_dataManager saveContext]) {
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:matchRecord.number, matchTypeString, @"N", nil];
        NSDictionary *matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        NSString *msg = [NSString stringWithFormat:@"Database Save Error %@ %@", matchTypeString, matchNumber];
        error = [NSError errorWithDomain:@"unpackageTeamForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return matchTransfer;
    }
    // Rebuild the team list dictionary to reflect what actually got saved just in case something went wrong
    NSDictionary *matchTransfer;
    NSDictionary *teamList = [MatchAccessors buildTeamList:match forAllianceDictionary:allianceDictionary];
    if (teamList) {
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"teams", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:match.number, matchTypeString, teamList, @"Y", nil];
        matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    }
    else {
        NSArray *keyList = [NSArray arrayWithObjects:@"match", @"type", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:match.number, matchTypeString, @"Y", nil];
        matchTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    }
    // NSLog(@"%@", matchTransfer);
    return matchTransfer;
}

-(NSNumber *)getNumber:inputData {
    NSScanner *scanner = [NSScanner scannerWithString:inputData];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    // NSLog(@"Is numeric??? %d", isNumeric);
    if (isNumeric) {
        return [NSNumber numberWithInt:[inputData intValue]];
    }
    else return nil;
}

-(NSNumber *)getTeamFromList:(NSArray *)teamList forAllianceStation:(NSNumber *)allianceStation {
    if (!teamList || ![teamList count]) return nil;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", allianceStation];
    NSArray *team = [teamList filteredArrayUsingPredicate:pred];
    if (!team || ![team count]) return nil;
    return [[team objectAtIndex:0] valueForKey:@"teamNumber"];
}

-(void)initializePreferences {
    // Create a dictionary with
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MatchData" ofType:@"plist"];
    matchDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
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
    
/*    ExportMatchData *matchDataPackage = [[ExportMatchData alloc] init:_dataManager];
    for (MatchData *match in matchData) {
        NSData *xferData = [matchDataPackage packageMatchForXFer:match];
    }*/
}
#endif

@end
