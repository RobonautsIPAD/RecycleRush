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
    NSArray *teamDataList;
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
        // NSLog(@"attirbute name = %@", attributeNames);
        [self initializePreferences];
	}
	return self;
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

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

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
        [regionalData addObject:[regional valueForKey:@"week"]];
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
        NSArray *keyList = [NSArray arrayWithObjects:@"team", @"name", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:teamNumber, teamRecord.name, @"N", nil];
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
    
    /*        id value = [_teamDataProperties valueForKey:key];
     if ([value isKindOfClass:[NSAttributeDescription class]]) {
     [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
     }
     else {   // This is a relationship property
     NSRelationshipDescription *destination = [value inverseRelationship];
     if ([destination.entity.name isEqualToString:@"TournamentData"]) {
     // NSLog(@"T dictionary = %@", [myDictionary objectForKey:key]);
     for (int i=0; i<[[myDictionary objectForKey:key] count]; i++) {
     [self addTournamentToTeam:teamRecord forTournament:[[myDictionary objectForKey:key] objectAtIndex:i]];
     }
     }
     
     }*/
    
    teamRecord.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    NSLog(@"%@", teamRecord);
    if (![_dataManager saveContext]) {
        NSArray *keyList = [NSArray arrayWithObjects:@"team", @"name", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:teamNumber, teamRecord.name, @"N", nil];
        NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        NSString *msg = [NSString stringWithFormat:@"Database Save Error %@", teamNumber];
        error = [NSError errorWithDomain:@"unpackageTeamForXFer" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return teamTransfer;
    }
    NSArray *keyList = [NSArray arrayWithObjects:@"team", @"name", @"transfer", nil];
    NSArray *objectList = [NSArray arrayWithObjects:teamNumber, teamRecord.name, @"Y", nil];
    NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
    return teamTransfer;
}

-(BOOL)addTeamHistoryFromFile:(NSString *)filePath {
/*    NSNumber *teamNumber;
    TeamData *team;
    AddRecordResults results = DB_ADDED;
    
    if (![data count]) return DB_ERROR;
    
    // For now, I am going to only allow it to work if the team number is in the first column
    // and the header is Team History
    if (![[headers objectAtIndex:0] isEqualToString:@"Team History"]) {
        return DB_ERROR;
    }
    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    team = [self getTeam:teamNumber];
    
    // Team doesn't exist, return error
    if (!team) return DB_ERROR;
    
    // NSLog(@"Team History for %@", teamNumber);
    NSString *week = [data objectAtIndex:1];
    
    // Week is not the first field after team number or is blank, return error
    if (!week || [week isEqualToString:@""]) return DB_ERROR;
    
    NSNumber *weekNumber = [NSNumber numberWithInt:[[data objectAtIndex: 1] intValue]];
    
    // Check to see if this regional data already exists in the db
    if ([self getRegionalRecord:team forWeek:weekNumber]) return DB_MATCHED;
    
    // Create the regional record and add the data to it.
    Regional *regionalRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Regional"
                                                             inManagedObjectContext:_dataManager.managedObjectContext];
    // NSLog(@"Adding week = %@", weekNumber);
    regionalRecord.reg1 = [NSNumber numberWithInt:[weekNumber intValue]];
    NSDictionary *attributes = [[regionalRecord entity] attributesByName];
    for (int i=2; i<[data count]; i++) {
        [self setRegionalValue:regionalRecord forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i] withProperties:attributes];
    }
    // NSLog(@"Regional = %@", regionalRecord);
    
    [team addRegionalObject:regionalRecord];
    
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        results = DB_ERROR;
    }
    
    return results;*/
    return FALSE;
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

#ifdef NOT_USED
-(TeamData *)migrateData:(NSDictionary *)myDictionary forTeam:(TeamData *)teamRecord {
    // Cycle through each object in the transfer data dictionary
    if (!triStateDictionary) triStateDictionary = [EnumerationDictionary initializeBundledDictionary:@"TriState"];
    if (!quadStateDictionary) quadStateDictionary = [EnumerationDictionary initializeBundledDictionary:@"QuadState"];
    if (!driveTypeDictionary) driveTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"DriveType"];
    if (!intakeTypeDictionary) intakeTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"IntakeType"];
    if (!shooterTypeDictionary) shooterTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"ShooterType"];
    if (!tunnelDictionary) tunnelDictionary = [EnumerationDictionary initializeBundledDictionary:@"Tunnel"];
    for (NSString *key in myDictionary) {
        NSLog(@"%@", key);
        if ([key isEqualToString:@"number"]) continue; // We have already processed team number
        if ([key isEqualToString:@"tournament"]) continue; // Deal with tournament list later
        if ([key isEqualToString:@"regional"]) continue; // Deal with regional list later
        if ([key length] > 4 &&  [[key substringToIndex:5] isEqualToString:@"class"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:triStateDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        if ([key isEqualToString:@"spitBot"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:quadStateDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        if ([key isEqualToString:@"goalie"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:triStateDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        if ([key isEqualToString:@"autonMobility"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:triStateDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        if ([key isEqualToString:@"catcher"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:triStateDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        if ([key isEqualToString:@"toteIntake"]) {
            id value = [myDictionary objectForKey:key];
            NSString *newValue;
            if ([value intValue] == -1) newValue = @"Unknown";
            if ([value intValue] == 0) newValue = @"None";
            if ([value intValue] == 1) newValue = @"JVN";
            if ([value intValue] == 2) newValue = @"EveryBot";
            if ([value intValue] == 3) newValue = @"Clamp";
            if ([value intValue] == 4) newValue = @"118";
            if ([value intValue] == 5) newValue = @"Other";
            [teamRecord setValue:newValue forKey:key];
            continue;
        }
        if ([key isEqualToString:@"shooterType"]) {
            id value = [myDictionary objectForKey:key];
            NSString *newValue;
            if ([value intValue] == -1) newValue = @"Unknown";
            if ([value intValue] == 0) newValue = @"None";
            if ([value intValue] == 1) newValue = @"Wheel";
            if ([value intValue] == 2) newValue = @"Plunger";
            if ([value intValue] == 3) newValue = @"Catapult";
            if ([value intValue] == 4) newValue = @"Kicker";
            if ([value intValue] == 5) newValue = @"Other";
            [teamRecord setValue:newValue forKey:key];
            continue;
        }
        if ([key isEqualToString:@"tunneler"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:tunnelDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        if ([key isEqualToString:@"driveTrainType"]) {
            id value = [myDictionary objectForKey:key];
            NSString *newValue;
            if ([value intValue] == -1) newValue = @"Unknown";
            if ([value intValue] == 0) newValue = @"Mech";
            if ([value intValue] == 1) newValue = @"Omni";
            if ([value intValue] == 2) newValue = @"Swerve";
            if ([value intValue] == 3) newValue = @"Traction";
            if ([value intValue] == 4) newValue = @"Multi";
            if ([value intValue] == 5) newValue = @"Tread";
            if ([value intValue] == 6) newValue = @"Butterfly";
            if ([value intValue] == 7) newValue = @"Other";
            [teamRecord setValue:newValue forKey:key];
            continue;
        }
        if ([key isEqualToString:@"hotTracker"]) {
            NSString *value = [EnumerationDictionary getKeyFromValue:[myDictionary objectForKey:key] forDictionary:triStateDictionary];
            [teamRecord setValue:value forKey:key];
            continue;
        }
        
        if ([key isEqualToString:@"primePhoto"]) {
            // Only do something with the prime photo if there is not photo already
            if (!teamRecord.primePhoto) {
                [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
            }
            continue;
        }
        [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
    }
    
    return teamRecord;
}
#endif


@end
