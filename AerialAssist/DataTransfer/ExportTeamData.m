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
#import "DriveTypeDictionary.h"
#import "TrooleanDictionary.h"
#import "IntakeTypeDictionary.h"
#import "ShooterTypeDictionary.h"
#import "TunnelDictionary.h"
#import "QuadStateDictionary.h"

@implementation ExportTeamData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *attributes;
    NSArray *teamDataList;
    DriveTypeDictionary *driveDictionary;
    IntakeTypeDictionary *intakeDictionary;
    TrooleanDictionary *trooleanDictionary;
    ShooterTypeDictionary *shooterDictionary;
    TunnelDictionary *tunnelDictionary;
    QuadStateDictionary *quadStateDictionary;
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
    if (!driveDictionary) {
        driveDictionary = [[DriveTypeDictionary alloc] init];
    }
    if (!intakeDictionary) {
        intakeDictionary = [[IntakeTypeDictionary alloc] init];
    }
    if (!shooterDictionary) {
        shooterDictionary = [[ShooterTypeDictionary alloc] init];
    }
    if (!trooleanDictionary) {
        trooleanDictionary = [[TrooleanDictionary alloc] init];
    }
    if (!tunnelDictionary) {
        tunnelDictionary = [[TunnelDictionary alloc] init];
    }
    if (!quadStateDictionary) {
        quadStateDictionary = [[QuadStateDictionary alloc] init];
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
    for (NSDictionary *entry in teamDataList) {
        NSString *output = [team valueForKey:[entry objectForKey:@"key"]];
        if (output) {
            if ([[entry objectForKey:@"key"] isEqualToString:@"notes"]) {
            NSLog(@"key = p%@p", output);
            }
            csvString = [csvString stringByAppendingFormat:@", %@",[self outputFormat:[entry objectForKey:@"format"] forValue:[team valueForKey:[entry objectForKey:@"key"]]]];
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    NSLog(@"%@", csvString);
    
    return csvString;
}

-(NSString *) outputFormat:(NSString *)type forValue:data {
    if ([type isEqualToString:@"string"]) {
        NSLog(@"data = p%@p", data);
        if (data) {
            NSLog(@",\"%@\"", data);
            return [NSString stringWithFormat:@"\"%@\"", data];
        }
        else return @"";
    }
    else if ([type isEqualToString:@"driveTypeDictionary"]) {
        return [NSString stringWithFormat:@"%@", [driveDictionary getString:data]];
    }
    else if ([type isEqualToString:@"intakeTypeDictionary"]) {
        return [NSString stringWithFormat:@"%@", [intakeDictionary getString:data]];
    }
    else if ([type isEqualToString:@"shooterTypeDictionary"]) {
        return [NSString stringWithFormat:@"%@", [shooterDictionary getString:data]];
    }
    else if ([type isEqualToString:@"trooleanDictionary"]) {
        return [NSString stringWithFormat:@"%@", [trooleanDictionary getString:data]];
    }
    else if ([type isEqualToString:@"tunnelDictionary"]) {
        return [NSString stringWithFormat:@"%@", [tunnelDictionary getString:data]];
    }
    else if ([type isEqualToString:@"quadStateDictionary"]) {
        return [NSString stringWithFormat:@"%@", [quadStateDictionary getString:data]];
    }
    else return [NSString stringWithFormat:@"%@", data];
}


@end
