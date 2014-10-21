//
//  TournamentUtilities.m
//  AerialAssist
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

-(void)createTournamentFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
 
    if (![csvContent count]) return;
 
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];

    // Check the first header to make sure this is a tournament file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Tournament"]) return;
    NSMutableArray *columnDetails = [NSMutableArray array];
    NSLog(@"Header line = %@", headerLine);
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:attributeNames forDictionary:tournamentDataList];
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
            NSDictionary *column = [columnDetails objectAtIndex:i];
            NSLog(@"%@", column);
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"Invalid Key"]) {
                NSLog(@"Skipping");
                if (!inputError) {
                    // Only pop up one warning per file
                    inputError = TRUE;
                    NSString *msg = [NSString stringWithFormat:@"Invalid Data Member %@ from Tournament Data file", [headerLine objectAtIndex:i]];
                    [self errorAlertMessage:msg];
                }
                continue;
            }
            NSDictionary *description = [tournamentDataAttributes valueForKey:key];
            if ([DataConvenienceMethods setAttributeValue:tournament forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:nil]) {
                // Only pop up one warning per file
                inputError = TRUE;
                NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@ = %@, from Tournament Data file", [headerLine objectAtIndex:i], [line objectAtIndex:i]];
                [self errorAlertMessage:msg];
            }
        }
    }
    [parser closeFile];
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

#ifdef TEST_MODE
    [self testTournamentRecords];
#endif
    
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

-(NSDictionary *)unpackageTournamentsForXFer:(NSData *)xferData {
    NSDictionary *tournamentList = (NSDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
    for (NSDictionary *tournamentDictionary in tournamentList) {
        NSString *tournamentName = [tournamentDictionary objectForKey:@"name"];
        TournamentData *tournament = [self createNewTournament:tournamentName];
        if (tournament) {
            for (NSString *key in tournamentDictionary) {
                if ([key isEqualToString:@"name"]) continue; // We have already processed tournament name
                [tournament setValue:[tournamentDictionary objectForKey:key] forKey:key];
            }
        }
    }
    return tournamentList;
}

-(TournamentData *)createNewTournament:(NSString *)name {
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tournament Database Error"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [alert show];
        }
        return tournament;
    }
}

-(void)initializePreferences {
    // Create a dictionary with
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TournamentData" ofType:@"plist"];
    tournamentDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
}

-(void)errorAlertMessage:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tournament File Data Error"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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
