//
//  ExportMatchData.m
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ExportMatchData.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "MatchTypeDictionary.h"

@implementation ExportMatchData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *properties;
    MatchTypeDictionary *matchDictionary;
}

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(NSString *)matchDataCSVExport {
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    matchDictionary = [[MatchTypeDictionary alloc] init];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@", tournamentName];
    [fetchRequest setPredicate:pred];
    NSArray *matchList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchList) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minor Problem Encountered"
                                                        message:@"No Match List to email"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    MatchData *match;
    NSString *csvString;
    match = [matchList objectAtIndex:0];
    properties = [[match entity] relationshipsByName];
    csvString = [self createHeader:match];
    
    for (int i=0; i<[matchList count]; i++) {
        match = [matchList objectAtIndex:i];
        csvString = [csvString stringByAppendingString:[self createMatch:match]];
    }
    return csvString;
}

-(NSString *)createHeader:(MatchData *)match {
    NSString *csvString;
    csvString = @"Match, Red 1, Red 2, Red 3, Blue 1, Blue 2, Blue 3, Type, Tournament, Red Score, Blue Score\n";
    return csvString;
}

-(NSString *)createMatch:(MatchData *)match {
    NSString *csvString;
    csvString = [[NSString alloc] initWithFormat:@"%@", match.number];
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"allianceSection" ascending:YES];
    NSArray *data = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
    
    for (int i=0; i<[data count]; i++) {
        TeamScore *score = [data objectAtIndex:i];
        csvString = [csvString stringByAppendingFormat:@", %@", score.team.number];        
    }

    csvString = [csvString stringByAppendingFormat:@", %@, %@, %@, %@", match.matchType, match.tournamentName, match.redScore, match.blueScore];
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


@end
