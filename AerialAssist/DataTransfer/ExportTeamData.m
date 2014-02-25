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

@implementation ExportTeamData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *attributes;
    NSArray *teamDataList;
}

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(NSString *)teamDataCSVExport {
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    if (!teamDataList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"TeamDataOutput" ofType:@"plist"];
        teamDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
    entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
     
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@", tournamentName];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
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
    csvString = [self createHeader:team];

    for (int i=0; i<[teamData count]; i++) {
        team = [teamData objectAtIndex:i];
        csvString = [csvString stringByAppendingString:[self createTeam:team]];
    }
    return csvString;
}

-(NSString *)createHeader:(TeamData *)team {
    NSString *csvString;

    csvString = @"Team Number, Team Name, Tournament";
    for (int i=0; i<[teamDataList count]; i++) {
        NSString *output = [[teamDataList objectAtIndex:i] objectForKey:@"header"];
        if (output) {
            csvString = [csvString stringByAppendingFormat:@", %@", output];
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];

    return csvString;
}

-(NSString *)createTeam:(TeamData *)team {
    NSString *csvString;
    csvString = [[NSString alloc] initWithFormat:@"%@, %@, %@", team.number, team.name, tournamentName];
    for (int i=0; i<[teamDataList count]; i++) {
        NSDictionary *entry = [teamDataList objectAtIndex:i];
        NSString *output = [team valueForKey:[entry objectForKey:@"key"]];
        if (output) {
            csvString = [csvString stringByAppendingFormat:@", %@",[self outputFormat:[entry objectForKey:@"format"] forValue:[team valueForKey:[entry objectForKey:@"key"]]]];
            //NSLog(@"output = %@, value = %@", output, [team valueForKey:item]);
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
    return csvString;
}

-(NSString *) outputFormat:(NSString *)type forValue:data {
    if ([type isEqualToString:@"string"]) {
        if (data) return [NSString stringWithFormat:@",\"%@\"", data];
        else return @"";
    }
    else return [NSString stringWithFormat:@"%@", data];
}


@end
