//
//  ExportTeamData.m
//  AerialAssist
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ExportTeamData.h"
#import "DataManager.h"
#import "TeamData.h"
#import "DataConvenienceMethods.h"

@implementation ExportTeamData {
    NSDictionary *teamDataAttributes;
    NSArray *teamDataList;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        NSLog(@"init export team data");
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        teamDataAttributes = [entity attributesByName];
 	}
	return self;
}

-(NSString *)teamDataCSVExport:(NSString *)tournamentName {
    // Check if init function has run properly
    if (!_dataManager) return nil;
    if (!teamDataList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TeamData" ofType:@"plist"];
        teamDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
    entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
     
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if (tournamentName) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournamentName];
        [fetchRequest setPredicate:pred];
    }
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minor Problem Encountered"
                                                         message:@"No Team data to email"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }

    NSString *csvString;
    csvString = [self createHeader:tournamentName];
    // NSLog(@"%@", csvString);

    for (TeamData *team in teamData) {
        csvString = [csvString stringByAppendingString:[self createTeam:team forTournament:tournamentName]];
    }
    return csvString;
}

-(NSString *)createHeader:(NSString *)tournament {
    NSString *csvString = [[NSString alloc] init];

    BOOL firstPass = TRUE;
    for (NSDictionary *item in teamDataList) {
        NSString *output = [item objectForKey:@"output"];
        if (output) {
            if (firstPass) {
                csvString = [csvString stringByAppendingFormat:@"%@", output];
                firstPass = FALSE;
            }
            else {
                csvString = [csvString stringByAppendingFormat:@", %@", output];
            }
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    return csvString;
}

-(NSString *)createTeam:(TeamData *)team forTournament:(NSString *)tournament {
    NSString *csvString = [[NSString alloc] init];
    
    BOOL firstPass = TRUE;
    for (NSDictionary *item in teamDataList) {
        NSString *output = [item objectForKey:@"output"];
        if (output) {
            NSString *key = [item objectForKey:@"key"];
            if ([key isEqualToString:@"tournaments"]) {
                csvString = [csvString stringByAppendingFormat:@", %@", tournament];
            }
            else {
                NSDictionary *description = [teamDataAttributes valueForKey:key];
                if (firstPass) {
                    firstPass = FALSE;
                }
                else {
                    csvString = [csvString stringByAppendingFormat:@", "];
                }
                csvString = [csvString stringByAppendingString:[DataConvenienceMethods outputCSVValue:[team valueForKey:key] forAttribute:description forEnumDictionary:Nil]];
            }
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
  return csvString;
}

-(NSData *)packageTeamForXFer:(TeamData *)team {
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamDataAttributes) teamDataAttributes = [[team entity] attributesByName];
    for (NSString *item in teamDataAttributes) {
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
    NSLog(@"Dictionary = %@", dictionary);
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    return myData;
}

-(void)exportTeamForXFer:(TeamData *)team toFile:(NSString *)exportFilePath {
    // File name format T#.pck
    NSString *fileNameBase;
    if ([team.number intValue] < 100) {
        fileNameBase = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [team.number intValue]]];
    } else if ( [team.number intValue] < 1000) {
        fileNameBase = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [team.number intValue]]];
    } else {
        fileNameBase = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [team.number intValue]]];
    }
    NSString *exportFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pck", fileNameBase]];
    NSData *myData = [self packageTeamForXFer:team];
    [myData writeToFile:exportFile atomically:YES];
}

-(NSDictionary *)unpackageTeamForXFer:(NSData *)xferData {
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
    NSLog(@"unpackage team needs work");
    /*
    //     Assign unpacked data to the team record
    //     Return team record
    NSNumber *teamNumber = [myDictionary objectForKey:@"number"];
    if (!teamNumber) return nil;
    
    TeamData *teamRecord = [self getTeam:teamNumber];
    if (!teamRecord) {
        teamRecord = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                                   inManagedObjectContext:_dataManager.managedObjectContext];
        [teamRecord setValue:teamNumber forKey:@"number"];
    }
    // Create the property dictionary if it hasn't been created yet
    if (!_teamDataProperties) _teamDataProperties = [[teamRecord entity] propertiesByName];
    // check retrieved team, if the saved and saveby match the imcoming data then just do nothing
    NSNumber *saved = [myDictionary objectForKey:@"saved"];
    NSString *savedBy = [myDictionary objectForKey:@"savedBy"];
    
    if ([saved floatValue] == [teamRecord.saved floatValue] && [savedBy isEqualToString:teamRecord.savedBy]) {
        NSLog(@"Team has already transferred, team = %@", teamNumber);
        NSArray *keyList = [NSArray arrayWithObjects:@"team", @"name", @"transfer", nil];
        NSArray *objectList = [NSArray arrayWithObjects:teamNumber, teamRecord.name, @"N", nil];
        NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];
        return teamTransfer;
    }
    
    // Cycle through each object in the transfer data dictionary
    for (NSString *key in myDictionary) {
        if ([key isEqualToString:@"number"]) continue; // We have already processed team number
        if ([key isEqualToString:@"primePhoto"]) {
            // Only do something with the prime photo if there is not photo already
            if (!teamRecord.primePhoto) {
                [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
            }
            continue;
        }
        // if key is property, branch to photoList or tournamentList to decode
        id value = [_teamDataProperties valueForKey:key];
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

        }
    }
    
    teamRecord.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    NSArray *keyList = [NSArray arrayWithObjects:@"team", @"name", @"transfer", nil];
    NSArray *objectList = [NSArray arrayWithObjects:teamNumber, teamRecord.name, @"Y", nil];
    NSDictionary *teamTransfer = [NSDictionary dictionaryWithObjects:objectList forKeys:keyList];*/
    return Nil;
}

@end
