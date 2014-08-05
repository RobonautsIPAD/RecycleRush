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

#define TEST_MODE

@implementation TournamentUtilities {
    NSDictionary *tournamentDataAttributes;
    NSArray *attributeNames;
}

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
        tournamentDataAttributes = [entity attributesByName];
        attributeNames = tournamentDataAttributes.allKeys;
	}
	return self;
}

-(void)createTournamentFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
 
    if (![csvContent count]) return;
 
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];

    // Check the first header to make sure this is a tournament file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Tournament"]) return;

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
            NSString *header = [headerLine objectAtIndex:i];
            id key = [tournamentDataAttributes valueForKey:header];
            if (!key) {
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"self LIKE[c] %@", header];
                NSArray *alternates = [attributeNames filteredArrayUsingPredicate: pred];
                if (alternates && [alternates count]) {
                    key = [tournamentDataAttributes valueForKey:[alternates objectAtIndex:0]];
                    if (!key) {
                        NSString *msg = [NSString stringWithFormat:@"Unable to decode, %@, from Tournament file", header];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tournament File Data Error"
                                                                        message:msg
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                        return;
                    }
                }
            }
            [self setAttributeValue:tournament forValue:[line objectAtIndex:i] forAttribute:key];
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



-(void)setAttributeValue:record forValue:data forAttribute:(id) attribute {
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) {
        [record setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSBooleanAttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSStringAttributeType) {
        [record setValue:data forKey:[attribute name]];
    }
}

-(TournamentData *)createNewTournament:(NSString *)name {
    TournamentData *tournament = [DataConvenienceMethods getTournament:name fromContext:_dataManager.managedObjectContext];
    if (tournament) return tournament;
    else {
        TournamentData *tournament = [NSEntityDescription insertNewObjectForEntityForName:@"TournamentData"
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
