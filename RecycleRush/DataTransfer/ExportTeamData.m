//
//  ExportTeamData.m
//  RecycleRush
//
//  Created by FRC on 2/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ExportTeamData.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "TeamUtilities.h"
#import "DataConvenienceMethods.h"

@implementation ExportTeamData {
    NSDictionary *teamDataAttributes;
    NSArray *teamDataList;
    TeamUtilities *teamUtilities;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
        teamDataAttributes = [entity attributesByName];
        teamUtilities = [[TeamUtilities alloc]init:_dataManager];
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
    NSArray *teamData = [TeamAccessors getTeamDataForTournament:tournamentName fromDataManager:_dataManager];
    if(![teamData count]) {
        NSError *error;
        error = [NSError errorWithDomain:@"teamDataCSVExport" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"No Team data to email" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
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

-(NSString *)teamBundleCSVExport:(NSString *)tournamentName {
    // Check if init function has run properly
    if (!_dataManager) return nil;
    NSArray *teamData = [TeamAccessors getTeamDataForTournament:tournamentName fromDataManager:_dataManager];
    if(![teamData count]) {
        NSError *error;
        error = [NSError errorWithDomain:@"teamBundleCSVExport" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"No Team data to export" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
    
    NSString *csvString;
    NSArray *allKeys = [teamDataAttributes allKeys];
    csvString = @"number, name";
    for (NSString *key in allKeys) {
        if ([key isEqualToString:@"name"] || [key isEqualToString:@"number"]) continue;
        csvString = [csvString stringByAppendingFormat:@", %@", key];
    }
 
    for (TeamData *team in teamData) {
        csvString = [csvString stringByAppendingFormat:@"\n%@, %@", team.number, team.name];
        for (NSString *key in allKeys) {
            if ([key isEqualToString:@"name"] || [key isEqualToString:@"number"]) continue;
            csvString = [csvString stringByAppendingFormat:@", "];
            NSDictionary *description = [teamDataAttributes valueForKey:key];
            csvString = [csvString stringByAppendingString:[DataConvenienceMethods outputCSVValue:[team valueForKey:key] forAttribute:description forEnumDictionary:Nil]];
        }
    }
    return csvString;
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
    NSDictionary *packagedTeam = [teamUtilities packageTeamForXFer:team];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:packagedTeam];
    [myData writeToFile:exportFile atomically:YES];
    NSString *msg = [NSString stringWithFormat:@"Exported %@.pck", fileNameBase];
    NSError *error = [NSError errorWithDomain:@"exportTeamForXFer" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
    [_dataManager writeErrorMessage:error forType:kWarningMessage];
}


@end
