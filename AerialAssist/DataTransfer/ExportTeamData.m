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
    for (NSString *item in attributes) {
        if ([item isEqualToString:@"number"]) continue; // We have already printed the team number
        if ([item isEqualToString:@"name"]) continue; // We have already printed the team name
        NSString *output = [[[attributes objectForKey:item] userInfo] objectForKey:@"output"];
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
    for (NSString *item in attributes) {
        if ([item isEqualToString:@"number"]) continue; // We have already printed the team number
        if ([item isEqualToString:@"name"]) continue; // We have already printed the team name
        NSString *output = [[[attributes objectForKey:item] userInfo] objectForKey:@"output"];
        if (output) {
            csvString = [csvString stringByAppendingFormat:@", %@",[self outputFormat:[[attributes objectForKey:item] attributeType] forValue:[team valueForKey:item]]];
            //NSLog(@"output = %@, value = %@", output, [team valueForKey:item]);
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
    return csvString;
}

-(NSString *) outputFormat:(NSAttributeType)type forValue:data {
    if (type == NSStringAttributeType) {
        if (data) return [NSString stringWithFormat:@",\"%@\"", data];
        else return @"";
    }
    else return [NSString stringWithFormat:@"%@", data];
}

-(NSArray *)lucienListExport {
    NSMutableDictionary *singleItem;
    NSMutableArray *fullList = [[NSMutableArray alloc] init];
    
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    if (!attributes) {
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchLimit:1];
        NSArray *team = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (team) attributes = [[[team objectAtIndex:0] entity] attributesByName];
    }
    for (NSString *item in attributes) {
        NSString *lucien = [[[attributes objectForKey:item] userInfo] objectForKey:@"lucien"];
        if (lucien) {
            singleItem = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects: lucien, item, @"TeamData", nil] forKeys:[NSArray arrayWithObjects:@"name", @"key", @"table", nil]];
            [fullList addObject:singleItem];
        }
    }
    return [fullList copy];;
}

@end
