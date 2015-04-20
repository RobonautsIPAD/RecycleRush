//
//  TeamUtilities.m
//  RecycleRush
//
//  Created by FRC on 8/7/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TeamUtilities.h"
#import "DataConvenienceMethods.h"
#import "TeamAccessors.h"
#import "TeamData.h"
#import "Regional.h"
#import "Competitions.h"
#import "TournamentUtilities.h"
#import "EnumerationDictionary.h"
#import "FileIOMethods.h"
#import "DataManager.h"
#import "parseCSV.h"

//#define TEST_MODE
#ifdef TEST_MODE
#import "ExportTeamData.h"
#endif

@implementation TeamUtilities {
    NSDictionary *teamDataAttributes;
    NSArray *attributeNames;
    NSDictionary *teamHistoryAttributes;
    NSArray *historyAttributeNames;
    NSUserDefaults *prefs;
    NSString *deviceName;
    NSArray *teamDataList;
    NSArray *teamHistoryList;
    NSDictionary *triStateDictionary;
    NSDictionary *quadStateDictionary;
    NSDictionary *driveTypeDictionary;
    NSDictionary *intakeTypeDictionary;
    NSDictionary *shooterTypeDictionary;
    NSDictionary *tunnelDictionary;
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        teamDataAttributes = [entity propertiesByName];
        attributeNames = teamDataAttributes.allKeys;
        entity = [NSEntityDescription entityForName:@"Regional" inManagedObjectContext:_dataManager.managedObjectContext];
        teamHistoryAttributes = [entity propertiesByName];
        historyAttributeNames = teamHistoryAttributes.allKeys;
        // NSLog(@"attirbute name = %@", attributeNames);
        [self initializePreferences];
        prefs = [NSUserDefaults standardUserDefaults];
        deviceName = [prefs objectForKey:@"deviceName"];
	}
	return self;
}

-(TeamData *)saveTeam:(TeamData *)team {
    team.savedBy = deviceName;
    team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    [_dataManager saveContext];
    return team;
}

-(BOOL)createTeamFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
    NSError *error = nil;
    if (![csvContent count]) return inputError;
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];

    // Check the first header to make sure this is a team file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Team Number"]) return inputError;
    
    NSMutableArray *columnDetails = [NSMutableArray array];
    // NSLog(@"Header line = %@", headerLine);
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:attributeNames forDictionary:teamDataList error:&error];
        [columnDetails addObject:column];
    }
    if (error) {
        [_dataManager writeErrorMessage:error forType:kErrorMessage];
        inputError = TRUE;
    }
    
    for (int c = 1; c < [csvContent count]; c++) {
        NSArray *line = [NSArray arrayWithArray:[csvContent objectAtIndex:c]];
        NSNumber *teamNumber = [NSNumber numberWithInt:[[line objectAtIndex: 0] intValue]];
        NSLog(@"createTeamFromFile:Team = %@", teamNumber);
        error = nil;
        TeamData *team = [self createNewTeam:teamNumber error:&error];
        if (error) [_dataManager writeErrorMessage:error forType:[error code]];
        if (!team) { // Unable to create team
            inputError = TRUE;
            continue;
        }
        // NSLog(@"%@", line);
 
        // Parse the rest of the line for any more data
        for (int i=1; i<[line count]; i++) {
            NSDictionary *column = [columnDetails objectAtIndex:i];
            // NSLog(@"%@", column);
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"Invalid Key"]) continue; // Error message already generated
            NSDictionary *enumDictionary = [self getEnumDictionary:[column valueForKey:@"dictionary"]];
            NSDictionary *description = [teamDataAttributes valueForKey:key];
            if ([description isKindOfClass:[NSAttributeDescription class]]) {
                // NSLog(@"Key = %@", key);
                if ([DataConvenienceMethods setAttributeValue:team forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:enumDictionary]) {
                    NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@ = %@, from Team Data file", [headerLine objectAtIndex:i], [line objectAtIndex:i]];
                    error = [NSError errorWithDomain:@"createTeamFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    inputError = TRUE;
                    [_dataManager writeErrorMessage:error forType:[error code]];
                    error = nil;
                }
            }
            else {
                // NSLog(@"Relationship");
                // NSLog(@"Key = %@, value = %@", key, [line objectAtIndex:i]);
                if ([key isEqualToString:@"tournaments"]) {
                    if (![self addTournamentToTeam:team forTournament:[line objectAtIndex:i]]) {
                        NSString *msg = [NSString stringWithFormat:@"Unable to add Team %@ to Tournament %@", teamNumber, [line objectAtIndex:i]];
                        error = [NSError errorWithDomain:@"createTeamFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                        inputError = TRUE;
                        [_dataManager writeErrorMessage:error forType:[error code]];
                        error = nil;
                    }
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
    [self testTeamUtilities];
#endif
    return inputError;
}

-(TeamData *)addTeam:(NSNumber *)teamNumber forName:(NSString *)teamName forTournament:(NSString *)tournamentName error:(NSError **)error {
    if (!_dataManager) {
        *error = [NSError errorWithDomain:@"addTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        return nil;
    }

    TeamData *team = [self createNewTeam:teamNumber error:error];
    if (!team) return nil; // Unable to create team, error retains value from getTeam

    if (![self addTournamentToTeam:team forTournament:tournamentName]) {
        NSString *msg = [NSString stringWithFormat:@"Unable to add Team %@ to Tournament %@", teamNumber, tournamentName];
        *error = [NSError errorWithDomain:@"addTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    if (teamName && ![teamName isEqualToString:@""]) team.name = teamName;
    team.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    team.savedBy = [prefs objectForKey:@"deviceName"];

    return team;
}

-(TeamData *)createNewTeam:(NSNumber *)teamNumber error:(NSError **)error {
    if (!teamNumber || ([teamNumber intValue] < 1)) {
        NSString *msg = [NSString stringWithFormat:@"Invalid team %@", teamNumber];
        *error = [NSError errorWithDomain:@"createNewTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    TeamData *team = [TeamAccessors getTeam:teamNumber fromDataManager:_dataManager];
    if (team) {
        NSString *msg = [NSString stringWithFormat:@"Team %@ already exists", teamNumber];
        *error = [NSError errorWithDomain:@"createNewTeam" code:kInfoMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        return team;
    }
    else {
        team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                        inManagedObjectContext:_dataManager.managedObjectContext];
        if (team) {
            team.number = teamNumber;
            NSString *msg = [NSString stringWithFormat:@"Team %@ added", teamNumber];
            *error = [NSError errorWithDomain:@"createNewTeam" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Unable to add Team %@", teamNumber];
            *error = [NSError errorWithDomain:@"createNewTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        }
        return team;
    }
}

-(BOOL)addTournamentToTeam:(TeamData *)team forTournament:(NSString *)tournamentName {
    if ([DataConvenienceMethods getTournament:tournamentName fromContext:_dataManager.managedObjectContext]) {
        // NSLog(@"Found = %@", tournamentName);
        // Check to make sure this team does not already have this tournament
        NSArray *allTournaments = [team.tournaments allObjects];
        // NSLog(@"All Tournaments = %@", allTournaments);
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentName];
        NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
        if (![list count]) {
            // NSLog(@"Adding Tournament");
            Competitions *tournament = [NSEntityDescription insertNewObjectForEntityForName:@"Competitions" inManagedObjectContext:_dataManager.managedObjectContext];
            tournament.name = tournamentName;
            [team addTournamentsObject:tournament];
        }
        else {
            NSLog(@"Tournament Exists, count = %lu", (unsigned long)[list count]);
        }
        return TRUE;
    }
    else return FALSE;
}

-(NSDictionary *)packageTeamForXFer:(TeamData *)team {
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamDataAttributes) teamDataAttributes = [[team entity] attributesByName];
    for (NSString *item in teamDataAttributes) {
        NSDictionary *description = [teamDataAttributes valueForKey:item];
        if (![description isKindOfClass:[NSAttributeDescription class]]) continue;
        if ([team valueForKey:item]) {
            if (![DataConvenienceMethods compareAttributeToDefault:[team valueForKey:item] forAttribute:[teamDataAttributes valueForKey:item]]) {
                [keyList addObject:item];
                [valueList addObject:[team valueForKey:item]];
            }
        }
    }
    
    NSArray *allTournaments = [team.tournaments allObjects];
    NSMutableArray *tournamentNames = [NSMutableArray array];
    for (NSString *competition in allTournaments) {
        [tournamentNames addObject:[competition valueForKey:@"name"]];
    }
    if ([tournamentNames count]) {
        [keyList addObject:@"tournament"];
        [valueList addObject:tournamentNames];
    }
    
    NSArray *allRegionals = [team.regional allObjects];
    NSMutableArray *regionalData = [NSMutableArray array];
    for (NSString *regional in allRegionals) {
        [regionalData addObject:[regional valueForKey:@"eventNumber"]];
    }
    if ([regionalData count]) {
        [keyList addObject:allRegionals];
        [valueList addObject:regionalData];
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    return dictionary;
}

-(NSDictionary *)unpackageTeamForXFer:(NSDictionary *)xferDictionary {
    NSError *error = nil;
    if (!_dataManager) {
        error = [NSError errorWithDomain:@"addTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"unpackageTeamForXFer" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSLog(@"unpackage team needs work");
    
    //     Assign unpacked data to the team record
    //     Return team record
    NSNumber *teamNumber = [xferDictionary objectForKey:@"number"];
    if (!teamNumber || ([teamNumber intValue] < 1)) {
        NSString *msg = [NSString stringWithFormat:@"Invalid team %@", teamNumber];
        error = [NSError errorWithDomain:@"unpackageTeamForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    
    TeamData *teamRecord = [TeamAccessors getTeam:teamNumber fromDataManager:_dataManager];
    if (!teamRecord) {
        teamRecord = [self createNewTeam:teamNumber error:&error];
        if (!teamRecord) {
            NSArray *keyList = [NSArray arrayWithObjects:@"team", @"name", @"transfer", nil];
            NSArray *objectList = [NSArray arrayWithObjects:teamNumber, @"", @"N", nil];
            NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
            [_dataManager writeErrorMessage:error forType:[error code]];
            return teamTransfer;
        }
    }
    // teamRecord = [self migrateData:myDictionary forTeam:teamRecord];

    // Create the property dictionary if it hasn't been created yet
    if (!teamDataAttributes) teamDataAttributes = [[teamRecord entity] attributesByName];
    // check retrieved team, if the saved and saveby match the imcoming data then just do nothing
    NSNumber *saved = [xferDictionary objectForKey:@"saved"];
    
    if ([teamRecord.saved floatValue] > [saved floatValue]) {
        NSLog(@"Team has already transferred, team = %@", teamNumber);
        //NSLog(@"Add a validation check or something");
        NSArray *keyList = [NSArray arrayWithObjects:@"record", @"team", @"name", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:@"TeamData", teamNumber, teamRecord.name, @"N", nil];
        NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        NSString *msg = [NSString stringWithFormat:@"Team has already transferred, team = %@", teamNumber];
        error = [NSError errorWithDomain:@"unpackageTeamForXFer" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return teamTransfer;
    }

    // Cycle through each object in the transfer data dictionary
    for (NSString *key in xferDictionary) {
        if ([key isEqualToString:@"number"]) continue; // We have already processed team number
        if ([key isEqualToString:@"tournament"]) continue; // Deal with tournament list later
        if ([key isEqualToString:@"regional"]) continue; // Deal with regional list later
        if ([key isEqualToString:@"primePhoto"]) {
            // Only do something with the prime photo if there is not photo already
            if (!teamRecord.primePhoto) {
                [teamRecord setValue:[xferDictionary objectForKey:key] forKey:key];
            }
            continue;
        }
        [teamRecord setValue:[xferDictionary objectForKey:key] forKey:key];
    }
    NSArray *tournamentList = [xferDictionary objectForKey:@"tournament"];
    for (NSString *tournamentName in tournamentList) {
        [self addTournamentToTeam:teamRecord forTournament:tournamentName];
    }
        /*        id value = [_teamDataProperties valueForKey:key];
     if ([value isKindOfClass:[NSAttributeDescription class]]) {
     [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
     }
     else {   // This is a relationship property
     NSRelationshipDescription *destination = [value inverseRelationship];
     }*/
    
    teamRecord.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    //NSLog(@"%@", teamRecord);
    if (![_dataManager saveContext]) {
        NSArray *keyList = [NSArray arrayWithObjects:@"record", @"team", @"name", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:@"TeamData", teamNumber, teamRecord.name, @"N", nil];
        NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        NSString *msg = [NSString stringWithFormat:@"Database Save Error %@", teamNumber];
        error = [NSError errorWithDomain:@"unpackageTeamForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return teamTransfer;
    }
    NSArray *keyList = [NSArray arrayWithObjects:@"record", @"team", @"name", @"transfer", nil];
    NSArray *objectList = [NSArray arrayWithObjects:@"TeamData", teamNumber, teamRecord.name, @"Y", nil];
    NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    return teamTransfer;
}

-(BOOL)addTeamHistoryFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
    NSError *error = nil;
    if (![csvContent count]) return inputError;
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];
    
    // Check the first header to make sure this is a team file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Team History"]) return inputError;
    
    NSMutableArray *columnDetails = [NSMutableArray array];
    // NSLog(@"Header line = %@", headerLine);
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:historyAttributeNames forDictionary:teamHistoryList error:&error];
        [columnDetails addObject:column];
    }
    if (error) {
        [_dataManager writeErrorMessage:error forType:kErrorMessage];
        inputError = TRUE;
    }
    // Find the event number column. This is required to uniquely define an event
    // I'm sure there is a better way, but for now I'm going brute force.
    int eventColumn = -1;
    for (int i=0; i <[columnDetails count]; i++) {
        NSDictionary *column = [columnDetails objectAtIndex:i];
        NSString *key = [column valueForKey:@"key"];
        if ([key isEqualToString:@"eventNumber"]) {
            eventColumn = i;
        }
    }
    if (eventColumn < 1) {
        NSString *msg = @"Event Number missing from team history file";
        error = [NSError errorWithDomain:@"addTeamHistoryFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        inputError = TRUE;
        [_dataManager writeErrorMessage:error forType:[error code]];
        return inputError;
    }

    for (int c = 1; c < [csvContent count]; c++) {
        NSArray *line = [NSArray arrayWithArray:[csvContent objectAtIndex:c]];
        NSNumber *teamNumber = [NSNumber numberWithInt:[[line objectAtIndex: 0] intValue]];
        NSLog(@"addTeamHistoryFromFile:Team = %@", teamNumber);
        TeamData *team = [TeamAccessors getTeam:teamNumber fromDataManager:_dataManager];
        error = nil;
        if (error) [_dataManager writeErrorMessage:error forType:[error code]];
        if (!team) { // Unable to fetch team (do not add new teams this way)
            NSString *msg = [NSString stringWithFormat:@"Team %@, in Team History file, does not exist", teamNumber];
            error = [NSError errorWithDomain:@"addTeamHistoryFromFile" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [_dataManager writeErrorMessage:error forType:[error code]];
            inputError = TRUE;
            continue;
        }
        NSNumber *eventNumber = [NSNumber numberWithInt:[[line objectAtIndex:eventColumn] intValue]];

        Regional *regionalRecord;
        //NSLog(@"%@", eventNumber);
        // Check to see if this regional data already exists in the db
        regionalRecord = [self getRegionalRecord:team forEvent:eventNumber];
        if (!regionalRecord) {
            // Create the regional record and add the data to it.
            regionalRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Regional"
                                                                     inManagedObjectContext:_dataManager.managedObjectContext];
            if (regionalRecord) {
                regionalRecord.eventNumber = eventNumber;
                [team addRegionalObject:regionalRecord];
            }
            else {
                NSString *msg = [NSString stringWithFormat:@"Error adding regional data for team %@", teamNumber];
                error = [NSError errorWithDomain:@"addTeamHistoryFromFile" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                [_dataManager writeErrorMessage:error forType:[error code]];
                inputError = TRUE;
                continue;
            }
        }
        // Parse the rest of the line for any more data
        for (int i=1; i<[line count]; i++) {
            NSDictionary *column = [columnDetails objectAtIndex:i];
            //NSLog(@"%@", column);
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"eventNumber"]) continue;
            if ([key isEqualToString:@"Invalid Key"]) continue; // Error message already generated
            NSDictionary *enumDictionary = [self getEnumDictionary:[column valueForKey:@"dictionary"]];
            NSDictionary *description = [teamHistoryAttributes valueForKey:key];
            if ([description isKindOfClass:[NSAttributeDescription class]]) {
                //NSLog(@"Key = %@", key);
                if ([DataConvenienceMethods setAttributeValue:regionalRecord forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:enumDictionary]) {
                    NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@ = %@, from Team History file", [headerLine objectAtIndex:i], [line objectAtIndex:i]];
                    error = [NSError errorWithDomain:@"createTeamFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    inputError = TRUE;
                    [_dataManager writeErrorMessage:error forType:[error code]];
                    error = nil;
                }
            }
        }
        if (![_dataManager saveContext]) {
            inputError = TRUE;
        }
        //NSLog(@"Regional after full line = %@", regionalRecord);
    }
    [parser closeFile];
    return FALSE;
}

-(Regional *)getRegionalRecord:(TeamData *)team forEvent:(NSNumber *)event {
    NSArray *regionalList = [team.regional allObjects];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"eventNumber = %@", event];
    NSArray *list = [regionalList filteredArrayUsingPredicate:pred];
    
    if ([list count]) return [list objectAtIndex:0];
    else return nil;
}

-(id)getEnumDictionary:(NSString *) dictionaryName {
    if (!dictionaryName) {
        return nil;
    }
    else if ([dictionaryName isEqualToString:@"triStateDictionary"]) {
        if (!triStateDictionary) triStateDictionary = [EnumerationDictionary initializeBundledDictionary:@"TriState"];
        return triStateDictionary;
    }
    else if ([dictionaryName isEqualToString:@"quadStateDictionary"]) {
        if (!quadStateDictionary) quadStateDictionary = [EnumerationDictionary initializeBundledDictionary:@"QuadState"];
        return quadStateDictionary;
    }
    else if ([dictionaryName isEqualToString:@"driveTypeDictionary"]) {
        if (!driveTypeDictionary) driveTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"DriveType"];
        return driveTypeDictionary;
    }
    else if ([dictionaryName isEqualToString:@"intakeTypeDictionary"]) {
        if (!intakeTypeDictionary) intakeTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"IntakeType"];
        return intakeTypeDictionary;
    }
    else if ([dictionaryName isEqualToString:@"shooterTypeDictionary"]) {
        if (!shooterTypeDictionary) shooterTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"ShooterType"];
        return shooterTypeDictionary;
    }
    else if ([dictionaryName isEqualToString:@"tunnelDictionary"]) {
        if (!tunnelDictionary) tunnelDictionary = [EnumerationDictionary initializeBundledDictionary:@"Tunnel"];
        return tunnelDictionary;
    }
    else {
        NSLog(@"Couldn't find team dictionary");
        return nil;
    }
    
    return nil;
}

-(void)initializePreferences {
    // Create a dictionary with
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TeamData" ofType:@"plist"];
    teamDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    plistPath = [[NSBundle mainBundle] pathForResource:@"TeamHistory" ofType:@"plist"];
    teamHistoryList = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

#ifdef TEST_MODE
-(void)testTeamUtilities {
    NSLog(@"Testing Team Utilities");
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Total Teams = %d", [teamData count]);
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"driveTrainType" ascending:YES];
    teamData = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    int prev_int = -99;
    BOOL firstTime = TRUE;
    int counter = 0;
    // ExportTeamData *teamDataPackage = [[ExportTeamData alloc] init:_dataManager];
    for (int i=0; i<[teamData count]; i++) {
        // NSData *xferData = [teamDataPackage packageTeamForXFer:[teamData objectAtIndex:i]];
//        NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
        int driveType = [[[teamData objectAtIndex:i] valueForKey:@"driveTrainType"] intValue];
        // NSLog(@"%d\t%d", i+1, driveType);
        if (driveType == prev_int) {
            counter++;
        }
        else {
            if (!firstTime) {
                NSLog(@"%d\tDrive Type = %d", counter, prev_int);
            }
            firstTime = FALSE;
            counter = 1;
            prev_int = driveType;
        }
    }
    NSLog(@"%d\tDrive Type = %d", counter, prev_int);
    
    sorter = [NSSortDescriptor sortDescriptorWithKey:@"intake" ascending:YES];
    teamData = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    prev_int = -99;
    firstTime = TRUE;
    for (int i=0; i<[teamData count]; i++) {
        int intake = [[[teamData objectAtIndex:i] valueForKey:@"toteIntake"] intValue];
        // NSLog(@"%d\t%d", i+1, intake);
        if (intake == prev_int) {
            counter++;
        }
        else {
            if (!firstTime) {
                NSLog(@"%d\tIntake Type = %d", counter, prev_int);
            }
            firstTime = FALSE;
            counter = 1;
            prev_int = intake;
        }
    }
    NSLog(@"%d\tIntake Type = %d", counter, prev_int);
    
    NSFetchRequest *fetchRegionals = [[NSFetchRequest alloc] init];
    NSEntityDescription *regionalEntity = [NSEntityDescription
                                           entityForName:@"Regional" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRegionals setEntity:regionalEntity];
    NSArray *regionalData = [_dataManager.managedObjectContext executeFetchRequest:fetchRegionals error:&error];
    if (regionalData) NSLog(@"History records = %d", [regionalData count]);
    else NSLog(@"History records = 0");
    
    NSFetchRequest *fetchTournaments = [[NSFetchRequest alloc] init];
    NSEntityDescription *tournamentEntity = [NSEntityDescription
                                             entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchTournaments setEntity:tournamentEntity];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchTournaments error:&error];
    
    if (tournamentData) {
        NSLog(@"Total Tournaments = %d", [tournamentData count]);
        for (int i=0; i<[tournamentData count]; i++) {
            NSString *tournament = [[tournamentData objectAtIndex:i] valueForKey:@"name"];
            entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
            [fetchRequest setEntity:entity];
            // Add the search for tournament name
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@",  tournament];
            [fetchRequest setPredicate:pred];
            teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (teamData) NSLog(@"Teams in tournament %@ = %d", tournament, [teamData count]);
            else NSLog(@"Teams in tournament %@ = 0", tournament);
        }
    }
    else {
        NSLog(@"Total Tournaments = 0");
    }
    
}
#endif


@end
