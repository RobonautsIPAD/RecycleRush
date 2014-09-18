//
//  TeamUtilities.m
//  AerialAssist
//
//  Created by FRC on 8/7/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TeamUtilities.h"
#import "DataConvenienceMethods.h"
#import "TeamData.h"
#import "Competitions.h"
#import "TournamentUtilities.h"
#import "FileIOMethods.h"
#import "TriStateDictionary.h"
#import "QuadStateDictionary.h"
#import "DataManager.h"
#import "parseCSV.h"

#define TEST_MODE

@implementation TeamUtilities {
    NSDictionary *teamDataAttributes;
    NSArray *attributeNames;
    NSArray *teamDataList;
    TriStateDictionary *triStateDictionary;
    QuadStateDictionary *quadStateDictionary;
    NSDictionary *driveTypeDictionary;
}

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        teamDataAttributes = [entity propertiesByName];
        attributeNames = teamDataAttributes.allKeys;
        NSLog(@"attirbute name = %@", attributeNames);
        [self initializePreferences];
	}
	return self;
}

-(void)createTeamFromFile:(NSString *)filePath {
    CSVParser *parser = [CSVParser new];
    [parser openFile: filePath];
    NSMutableArray *csvContent = [parser parseFile];
    BOOL inputError = FALSE;
    
    if (![csvContent count]) return;
    // Get the first row, column headers
    NSMutableArray *headerLine = [NSMutableArray arrayWithArray:[csvContent objectAtIndex: 0]];
    NSMutableArray *columnDetails = [NSMutableArray array];
    NSLog(@"Header line = %@", headerLine);
    for (NSString *item in headerLine) {
        NSDictionary *column = [DataConvenienceMethods findKey:item forAttributes:attributeNames forDictionary:teamDataList];
        [columnDetails addObject:column];
    }
    NSLog(@"Team Util add error message");

    // Check the first header to make sure this is a team file
    if (![[headerLine objectAtIndex:0] isEqualToString:@"Team Number"]) return;

    for (int c = 1; c < [csvContent count]; c++) {
        NSArray *line = [NSArray arrayWithArray:[csvContent objectAtIndex:c]];
        NSNumber *teamNumber = [NSNumber numberWithInt:[[line objectAtIndex: 0] intValue]];
        NSLog(@"createTeamFromFile:Team = %@", teamNumber);
        // Check to see if the team exists already, if not create it
        TeamData *team = [DataConvenienceMethods getTeam:teamNumber fromContext:_dataManager.managedObjectContext];

        if (!team) {
            team = [self createNewTeam:teamNumber];
            if (!team) { // Unable to create team
                inputError = TRUE;
                continue;
            }
        }
        NSLog(@"%@", line);
 
        // Parse the rest of the line for any more data
        for (int i=1; i<[line count]; i++) {
            NSDictionary *column = [columnDetails objectAtIndex:i];
            NSLog(@"%@", column);
            NSString *key = [column valueForKey:@"key"];
            if ([key isEqualToString:@"Invalid Key"]) {
                NSLog(@"Skipping");
                continue;
            }
            NSDictionary *enumDictionary = [self getEnumDictionary:[column valueForKey:@"dictionary"]];
            NSDictionary *description = [teamDataAttributes valueForKey:key];
            if ([description isKindOfClass:[NSAttributeDescription class]]) {
                NSLog(@"Key = %@", key);
                [DataConvenienceMethods setAttributeValue:team forValue:[line objectAtIndex:i] forAttribute:description forEnumDictionary:enumDictionary];
            }
            else {
                NSLog(@"Relationship");
                NSLog(@"Key = %@, value = %@", key, [line objectAtIndex:i]);
                if ([key isEqualToString:@"tournaments"]) {
                    BOOL success =[self addTournamentToTeam:team forTournament:[line objectAtIndex:i]];
                    if (!success) {
                        inputError = TRUE;
                    }
                }
            }
            NSLog(@"For now, save after every attribute to work out bugs");
            NSError *error;
            if (![_dataManager.managedObjectContext save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
        NSLog(@"Team after full line = %@", team);
    }
    [parser closeFile];
    NSLog(@"Move this to save after every line to minimize data loss in a crash");
/*    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }*/
    
#ifdef TEST_MODE
    [self testTeamInterfaces];
#endif
    
}

-(TeamData *)createNewTeam:(NSNumber *)teamNumber {
    TeamData *team = [DataConvenienceMethods getTeam:teamNumber fromContext:_dataManager.managedObjectContext];
    if (team) return team;
    else {
        team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                        inManagedObjectContext:_dataManager.managedObjectContext];
        if (team) {
            team.number = teamNumber;
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"Unable to add Team %@", teamNumber];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Team Database Error"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        return team;
    }
}

-(BOOL)addTournamentToTeam:(TeamData *)team forTournament:(NSString *)tournamentName {
    if ([DataConvenienceMethods getTournament:tournamentName fromContext:_dataManager.managedObjectContext]) {
        NSLog(@"Found = %@", tournamentName);
        // Check to make sure this team does not already have this tournament
        NSArray *allTournaments = [team.tournaments allObjects];
        NSLog(@"All Tournaments = %@", allTournaments);
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentName];
        NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
        if (![list count]) {
            NSLog(@"Adding Tournament");
            Competitions *tournament = [NSEntityDescription insertNewObjectForEntityForName:@"Competitions"
                                                                     inManagedObjectContext:_dataManager.managedObjectContext];
            tournament.name = tournamentName;
            [team addTournamentsObject:tournament];
        }
        else {
            NSLog(@"Tournament Exists, count = %d", [list count]);
        }
        return TRUE;
    }
    else return FALSE;
}

-(NSDictionary *)initializeDictionaries:(NSString *)fileName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return [FileIOMethods getDictionaryFromPListFile:plistPath];
}

-(id)getEnumDictionary:(NSString *) dictionaryName {
    if (!dictionaryName) {
        return nil;
    }
    else if ([dictionaryName isEqualToString:@"triStateDictionary"]) {
        if (!triStateDictionary) triStateDictionary = [[TriStateDictionary alloc] init];
        return triStateDictionary;
    }
    else if ([dictionaryName isEqualToString:@"quadStateDictionary"]) {
        if (!quadStateDictionary) quadStateDictionary = [[QuadStateDictionary alloc] init];
        return quadStateDictionary;
 
    }
    else if ([dictionaryName isEqualToString:@"driveTypeDictionary"]) {
        if (!driveTypeDictionary) driveTypeDictionary = [self initializeDictionaries:@"DriveType"];
        return driveTypeDictionary ;
    }
    else if ([dictionaryName isEqualToString:@"intakeTypeDictionary"]) {
        NSLog(@"Intake dictionary");
        return nil;
    }
    else if ([dictionaryName isEqualToString:@"shooterTypeDictionary"]) {
        NSLog(@"Shooter dictionary");
        return nil;
    }
    else if ([dictionaryName isEqualToString:@"tunnelDictionary"]) {
        NSLog(@"Tunnel dictionary");
        return nil;
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
-(void)testTeamInterfaces {
    NSLog(@"Testing Team Interfaces");
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
    for (int i=0; i<[teamData count]; i++) {
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
        int intake = [[[teamData objectAtIndex:i] valueForKey:@"intake"] intValue];
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
