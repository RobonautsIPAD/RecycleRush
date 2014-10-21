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

@end
