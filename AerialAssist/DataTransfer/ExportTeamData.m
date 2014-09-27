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
    NSDictionary *attributes;
    NSArray *teamDataList;
}

-(NSString *)teamDataCSVExport:(NSString *)tournamentName fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return nil;

    if (!teamDataList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TeamData" ofType:@"plist"];
        teamDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
    entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
     
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if (tournamentName) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournamentName];
        [fetchRequest setPredicate:pred];
    }
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minor Problem Encountered"
                                                         message:@"No Team data to email"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    }

    TeamData *team;
    NSString *csvString;
    team = [teamData objectAtIndex:0];
    attributes = [[team entity] attributesByName];
    csvString = [self createHeader:team forTournament:tournamentName];
    NSLog(@"%@", csvString);

    for (TeamData *team in teamData) {
        csvString = [csvString stringByAppendingString:[self createTeam:team forTournament:tournamentName]];
    }
    return csvString;
}

-(NSString *)createHeader:(TeamData *)team forTournament:(NSString *)tournament {
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
                NSDictionary *description = [attributes valueForKey:key];
                if (firstPass) {
                    firstPass = FALSE;
                }
                else {
                    csvString = [csvString stringByAppendingFormat:@", "];
                }
                csvString = [csvString stringByAppendingString:[DataConvenienceMethods outputCSVValue:[team valueForKey:key] forAttribute:description]];
            }
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
  return csvString;
}

@end
