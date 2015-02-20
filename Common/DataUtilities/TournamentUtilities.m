//
//  TournamentUtilities.m
//  RecycleRush
//
//  Created by FRC on 7/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TournamentUtilities.h"
#import "DataConvenienceMethods.h"
#import "TournamentData.h"
#import "DataManager.h"
#import "parseCSV.h"

//#define TEST_MODE

@implementation TournamentUtilities {
    NSDictionary *tournamentDataAttributes;
    NSArray *attributeNames;
    NSArray *tournamentDataList;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
        tournamentDataAttributes = [entity attributesByName];
        attributeNames = tournamentDataAttributes.allKeys;
        [self initializePreferences];
	}
	return self;
}

-(NSArray *)getTournamentList {
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *tournamentSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:tournamentSort]];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    else {
        NSMutableArray *tournamentList = [[NSMutableArray alloc] init];
        for (TournamentData *tournament in tournamentData) {
            // NSLog(@"Tournament %@ exists", t.name);
            [tournamentList addObject:tournament.name];
        }
        return tournamentList;
    }
}

-(BOOL)createTournamentFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
    NSError *error = nil;
 
    if (![csvContent count]) return inputError;
 
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];

    // Check the first header to make sure this is a tournament file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Tournament"]) return inputError;
    NSMutableArray *columnDetails = [NSMutableArray array];
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:attributeNames forDictionary:tournamentDataList error:&error];
        [columnDetails addObject:column];
    }

    for (int c = 1; c < [csvContent count]; c++) {
        NSArray *line = [NSArray arrayWithArray:[csvContent objectAtIndex: c]];
        NSString *tournamentName = [line objectAtIndex: 0];
        // NSLog(@"createTournamentFromFile:Tournament = %@", tournamentName);
        // Check to see if the tournament exists already, if not create it
        TournamentData *tournament = [DataConvenienceMethods getTournament:tournamentName fromContext:_dataManager.managedObjectContext];
        if (!tournament) {
            tournament = [self createNewTournament:tournamentName];
            if (!tournament) { // Unable to create tournament
                continue;
            }
        }
        tournament.name = tournamentName;
        // Parse the rest of the line for any more data
        for (int i=1; i<[line count]; i++) {
            error = nil;
            NSDictionary *column = [columnDetails objectAtIndex:i];
            // NSLog(@"%@", column);
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"Invalid Key"]) {
                NSLog(@"Skipping");
                    // Only pop up one warning per file
                    inputError = TRUE;
                    NSString *msg = [NSString stringWithFormat:@"Invalid Data Member %@ from Tournament Data file", [headerLine objectAtIndex:i]];
                    error = [NSError errorWithDomain:@"createTournamentFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                    [_dataManager writeErrorMessage:error forType:kErrorMessage];
                continue;
            }
            NSDictionary *description = [tournamentDataAttributes valueForKey:key];
            if ([DataConvenienceMethods setAttributeValue:tournament forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:nil]) {
                // Only pop up one warning per file
                inputError = TRUE;
                NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@ = %@, from Tournament Data file", [headerLine objectAtIndex:i], [line objectAtIndex:i]];
                error = [NSError errorWithDomain:@"createTournamentFromFile" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
                [_dataManager writeErrorMessage:error forType:kErrorMessage];
            }
        }
    }
    [parser closeFile];
    if (![_dataManager saveContext]) {
        inputError = TRUE;
    }
    
#ifdef TEST_MODE
    [self testTournamentRecords];
#endif
    return inputError;
}

-(NSData *)packageTournamentsForXFer:(NSArray *)tournamentList {
    NSMutableArray *allTournaments = [[NSMutableArray alloc] init];
    // Loop through each tournament and create a dictionary with the name and code
    for (TournamentData *tournament in tournamentList) {
        NSMutableArray *keyList = [NSMutableArray array];
        NSMutableArray *valueList = [NSMutableArray array];
        if (!tournamentDataAttributes) tournamentDataAttributes = [[tournament entity] attributesByName];
        // Loop through each attribute in the tournament record
        for (NSString *item in tournamentDataAttributes) {
            if ([tournament valueForKey:item] && [tournament valueForKey:item] != [[tournamentDataAttributes valueForKey:item] valueForKey:@"defaultValue"]) {
                // NSLog(@"%@ = %@, not equal to default = %@", item, [team valueForKey:item], [[_teamDataAttributes valueForKey:item] valueForKey:@"defaultValue"]);
                [keyList addObject:item];
                [valueList addObject:[tournament valueForKey:item]];
            }
        }
        // Only create the tournament dictionary if keys and values exist, add dictionary to array of tournament dictionaries
        if (keyList && valueList) {
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
            [allTournaments addObject:dictionary];
        }
    }
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:allTournaments];
    return myData;
}

-(NSMutableArray *)unpackageTournamentsForXFer:(NSArray *)tournamentList {
    NSMutableArray *receivedList = [[NSMutableArray alloc] init];
    for (NSDictionary *tournamentDictionary in tournamentList) {
        NSString *tournamentName = [tournamentDictionary objectForKey:@"name"];
        TournamentData *tournament = [self createNewTournament:tournamentName];
        if (tournament) {
            for (NSString *key in tournamentDictionary) {
                if ([key isEqualToString:@"name"]) continue; // We have already processed tournament name
                [tournament setValue:[tournamentDictionary objectForKey:key] forKey:key];
            }
            [receivedList addObject:tournament];
        }
    }
    return receivedList;
}

-(TournamentData *)createNewTournament:(NSString *)name {
    NSError *error = nil;
    TournamentData *tournament = [DataConvenienceMethods getTournament:name fromContext:_dataManager.managedObjectContext];
    if (tournament) return tournament;
    else {
        tournament = [NSEntityDescription insertNewObjectForEntityForName:@"TournamentData"
                                            inManagedObjectContext:_dataManager.managedObjectContext];
        if (tournament) {
            tournament.name = name;
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Unable to add Tournament %@", name];
            error = [NSError errorWithDomain:@"createNewTournament" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [_dataManager writeErrorMessage:error forType:[error code]];
        }
        return tournament;
    }
}

-(void)initializePreferences {
    // Create a dictionary with
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TournamentData" ofType:@"plist"];
    tournamentDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

#ifdef TEST_MODE
-(void)testTournamentRecords {
    NSLog(@"Testing Tournament Records");
    NSError *error;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"%d Tournaments", [tournamentData count]);
    for (TournamentData *tournament in tournamentData) {
        NSLog(@"Tournament = %@, Code = %@", tournament.name, tournament.code);
    }
    NSData *testPackage = [self packageTournamentsForXFer:tournamentData];
    NSLog(@"Packaged Tournament Data\n%@", testPackage);

    NSLog(@"Unpackage Tournament Data");
    NSDictionary *testUnpackage = [self unpackageTournamentsForXFer:testPackage];
    NSLog(@"Unpackaged Tournament Data\n%@", testUnpackage);
}

#endif

@end
