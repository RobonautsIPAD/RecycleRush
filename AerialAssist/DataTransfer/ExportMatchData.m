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
#import "EnumerationDictionary.h"
#import "DataConvenienceMethods.h"

@implementation ExportMatchData {
    NSDictionary *matchDataAttributes;
    NSArray *matchDataList;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        NSLog(@"init export match data");
        _dataManager = initManager;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        matchDataAttributes = [entity attributesByName];
        matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
        allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
 	}
	return self;
}

-(NSData *)packageMatchForXFer:(MatchData *)match {
    if (!_dataManager) return Nil;
    
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!matchDataAttributes) matchDataAttributes = [[match entity] attributesByName];
    for (NSString *item in matchDataAttributes) {
        if ([match valueForKey:item]) {
            if (![DataConvenienceMethods compareAttributeToDefault:[match valueForKey:item] forAttribute:[matchDataAttributes valueForKey:item]]) {
                [keyList addObject:item];
                [valueList addObject:[match valueForKey:item]];
            }
        }
    }
    
    NSMutableArray *teamList = [NSMutableArray array];
    NSArray *allTeams = [match.score allObjects];
    for (TeamScore *score in allTeams) {
        //  NSLog(@"score team = %@", score.team);
        NSDictionary *teamInfo = [NSDictionary dictionaryWithObject:score.teamNumber forKey:[EnumerationDictionary getKeyFromValue:score.allianceStation forDictionary:allianceDictionary]];
        [teamList addObject:teamInfo];
    }
    [keyList addObject:@"teams"];
    [valueList addObject:teamList];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    NSLog(@"%@", dictionary);
    NSLog(@"packaging %@", dictionary);
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    return myData;
    
}

-(void)exportMatchForXFer:(MatchData *)match toFile:(NSString *)exportFilePath {
    NSString *baseName;
    NSString *matchTypeString = [EnumerationDictionary getKeyFromValue:match.matchType forDictionary:matchTypeDictionary];
    char matchCode;
    if (matchTypeString) matchCode = [matchTypeString characterAtIndex:0];
    if ([match.number intValue] < 10) {
    baseName = [NSString stringWithFormat:@"M%c%@", matchCode, [NSString stringWithFormat:@"00%d", [match.number intValue]]];
    } else if ( [match.number intValue] < 100) {
    baseName = [NSString stringWithFormat:@"M%c%@", matchCode, [NSString stringWithFormat:@"0%d", [match.number intValue]]];
    } else {
    baseName = [NSString stringWithFormat:@"M%c%@", matchCode, [NSString stringWithFormat:@"%d", [match.number intValue]]];
    }
    NSString *exportFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pck", baseName]];
    NSData *myData = [self packageMatchForXFer:match];
    [myData writeToFile:exportFile atomically:YES];
}

-(NSString *)matchDataCSVExport:(NSString *)tournamentName {
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    if (!matchDataList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MatchData" ofType:@"plist"];
        matchDataList = [[NSArray alloc] initWithContentsOfFile:plistPath];
    }

    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
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
    
    NSString *csvString;
    csvString = [self createHeader];

    for (MatchData *match in matchList) {
        csvString = [csvString stringByAppendingString:[self createMatch:match]];
    }
    NSLog(@"%@", csvString);
    return csvString;
}

-(NSString *)createHeader {
    NSString *csvString = [[NSString alloc] init];
    
    BOOL firstPass = TRUE;
    for (NSDictionary *item in matchDataList) {
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

-(NSString *)createMatch:(MatchData *)match {
    NSString *csvString = [[NSString alloc] init];
    NSArray *scores = [match.score allObjects];
    BOOL firstPass = TRUE;
    for (NSDictionary *item in matchDataList) {
        NSString *output = [item objectForKey:@"output"];
        NSDictionary *enumDictionary = [self getEnumDictionary:[item valueForKey:@"dictionary"]];
        if (output) {
            if (firstPass) {
                firstPass = FALSE;
            }
            else {
                csvString = [csvString stringByAppendingString:@", "];
            }
            NSString *key = [item objectForKey:@"key"];
            if ([key isEqualToString:@"score"]) {
               // NSLog(@"output = %@", output);
              //  csvString = [csvString stringByAppendingFormat:@", %@", tournament];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"allianceStation = %@", [EnumerationDictionary getValueFromKey:output forDictionary:allianceDictionary]];
                NSArray *scoreList = [scores filteredArrayUsingPredicate:pred];
                if ([scoreList count]) {
                    TeamScore *alliance = [scoreList objectAtIndex:0];
                    csvString = [csvString stringByAppendingFormat:@"%@", alliance.teamNumber];
                }
            }
            else {
                NSDictionary *description = [matchDataAttributes valueForKey:key];
               csvString = [csvString stringByAppendingString:[DataConvenienceMethods outputCSVValue:[match valueForKey:key] forAttribute:description forEnumDictionary:enumDictionary]];
            }
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
    return csvString;
}

-(id)getEnumDictionary:(NSString *) dictionaryName {
    if (!dictionaryName) {
        return nil;
    }
    if ([dictionaryName isEqualToString:@"matchTypeDictionary"]) {
        if (!matchTypeDictionary) matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
        return matchTypeDictionary;
    }
    else return nil;
}


@end
