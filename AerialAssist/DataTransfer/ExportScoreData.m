//
//  ExportScoreData.m
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ExportScoreData.h"
#import "DataManager.h"
#import "DataConvenienceMethods.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "EnumerationDictionary.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "MatchData.h"

@implementation ExportScoreData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *teamScoreAttributes;
    NSDictionary *properties;
    NSDictionary *attributes;
    NSDictionary *matchDictionary;
    NSArray *scoutingSpreadsheetList;
    BOOL firstPass;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        matchDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
	}
    firstPass = TRUE;
	return self;
}

-(NSString *)teamScoreCSVExport {
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@", tournamentName, [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:pred];
    NSArray *teamScores = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamScores) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minor Problem Encountered"
                                                        message:@"No Score results to email"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    TeamScore *score;
    NSString *csvString;
    score = [teamScores objectAtIndex:0];
    properties = [[score entity] propertiesByName];
    csvString = [self createHeader:score];
    
    for (int i=0; i<[teamScores count]; i++) {
        score = [teamScores objectAtIndex:i];
        csvString = [csvString stringByAppendingString:[self createScore:score]];
    }
    return csvString;
}

-(NSString *)createHeader:(TeamScore *)score {
    NSString *csvString;
    
    csvString = @"Team, Match, Type, Tournament";
    for (NSString *item in properties) {
        if ([item isEqualToString:@"team"]) continue; // We have already printed the team number
        if ([item isEqualToString:@"match"]) continue; // We have already printed the match number
        if ([item isEqualToString:@"matchType"]) continue; // We have already printed the match type
        if ([item isEqualToString:@"tournamentName"]) continue; // We have already printed the tournament name
        NSString *output = [[[properties objectForKey:item] userInfo] objectForKey:@"output"];
        if (output) {
            csvString = [csvString stringByAppendingFormat:@", %@", output];
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
 
    return csvString;
}

-(NSString *)createScore:(TeamScore *)score {
    NSString *csvString;
    csvString = [[NSString alloc] initWithFormat:@"%@, %@, %@, %@", score.teamNumber, score.matchNumber, score.matchType, tournamentName];
    for (NSString *item in properties) {
        if ([item isEqualToString:@"team"]) continue; // We have already printed the team number
        if ([item isEqualToString:@"match"]) continue; // We have already printed the match number
        if ([item isEqualToString:@"matchType"]) continue; // We have already printed the match type
        if ([item isEqualToString:@"tournamentName"]) continue; // We have already printed the tournament name
        NSString *output = [[[properties objectForKey:item] userInfo] objectForKey:@"output"];
        if (output) {
            csvString = [csvString stringByAppendingFormat:@", %@",[self outputFormat:[[properties objectForKey:item] attributeType] forValue:[score valueForKey:item]]];
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
    return csvString;
}

-(NSString *) outputFormat:(NSAttributeType)type forValue:data {
    if (type == NSStringAttributeType) {
        if (data) return [NSString stringWithFormat:@"\"%@\"", data];
        else return @"";
    }
    else return [NSString stringWithFormat:@"%@", data];
}

-(NSString *)spreadsheetCSVExport:(NSString *)tournamentName {
    if (!_dataManager) return nil;

    NSString *csvString = nil;
/*    if (!scoutingSpreadsheetList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MarcusOutput" ofType:@"plist"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        scoutingSpreadsheetList = [[[NSArray alloc] initWithContentsOfFile:plistPath] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    }

    NSArray *allScores;// = [team.match allObjects];
 //   NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ and match.matchType = %@", tournamentName, [NSNumber numberWithBool:YES], choice];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ and match.matchType = %@", tournamentName, [NSNumber numberWithBool:YES], @"Seeding"];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchTypeSection" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    NSArray *teamScores = [[allScores filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:sortDescriptors];

    if(!teamScores) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minor Problem Encountered"
                                                        message:@"No Score results to email"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    TeamScore *score;
    int nmatches = [teamScores count];
    if (nmatches == 0) {
        csvString = [[NSString alloc] init];
        return csvString;
    }
    if (firstPass) {
        firstPass = FALSE;
        csvString = [self createSpreadsheetHeader:scoutingSpreadsheetList];
        csvString = [csvString stringByAppendingFormat:@"%@, %d", team.number, nmatches];
    }
    else {
        csvString = [[NSString alloc] initWithFormat:@"%@, %d", team.number, nmatches];
    }
    for (int i=0; i<nmatches; i++) {
        score = [teamScores objectAtIndex:i];
        csvString = [csvString stringByAppendingFormat:@", %@", score.match.number];
        for (int j=1; j<[scoutingSpreadsheetList count]; j++) {
            NSString *key = [[scoutingSpreadsheetList objectAtIndex:j] objectForKey:@"key"];
            csvString = [csvString stringByAppendingFormat:@", %@", [score valueForKey:key]];
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];*/
    return csvString;
}

-(NSString *)createSpreadsheetHeader:(NSArray *)scoreList {
    NSString *csvString;
    
    csvString = @"Team Number, Total Matches";
    for (int j=0; j<10; j++) {
        for (int i=0; i<[scoreList count]; i++) {
            csvString = [csvString stringByAppendingFormat:@", %@", [[scoutingSpreadsheetList objectAtIndex:i] objectForKey:@"header"]];
        }
    }
    csvString = [csvString stringByAppendingString:@"\n"];
    
    return csvString;
}

-(void)exportFullMatchData:(NSArray *)teamList {
/*    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    NSString *dirName = [NSString stringWithFormat:@"%@ FieldDrawings", tournamentName];

    NSString *exportPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if (![fileManager createDirectoryAtPath:exportPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Export Data Alert"
                                                          message:@"Unable to Create Export Directory"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return;
    }
    NSString *fileName = [NSString stringWithFormat:@"NewScoutingSheet_%.0f.csv", CFAbsoluteTimeGetCurrent()];
    NSString *filePath = [exportPath stringByAppendingPathComponent:fileName];

    CreateMatch *createMatch = [[CreateMatch alloc] initWithDataManager:_dataManager];

    if (!scoutingSpreadsheetList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MarcusOutput" ofType:@"plist"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        scoutingSpreadsheetList = [[[NSArray alloc] initWithContentsOfFile:plistPath] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ AND (match.matchType = %@ || match.matchType = %@)", tournament, [NSNumber numberWithBool:YES], @"Seeding", @"Elimination"];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *csvString = [self createFullHeader:scoutingSpreadsheetList];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"results = %@", [NSNumber numberWithBool:YES]];
        for (TeamData *team in teamList) {
            NSArray *matchList = [createMatch getMatchListTournament:team.number forTournament:tournamentName];
            matchList = [matchList filteredArrayUsingPredicate:pred];
            for (TeamScore *score in matchList) {
                csvString = [csvString stringByAppendingFormat:@"%@, %@, %@", team.number, score.match.matchType, score.match.number];
                for (NSDictionary *item in scoutingSpreadsheetList) {
                    NSString *key = [item objectForKey:@"key"];
                    if ([key isEqualToString:@"match.number"]) continue;
                    csvString = [csvString stringByAppendingFormat:@", %@", [score valueForKey:key]];
                }
                NSString *fieldDrawingName = [self createFieldDrawing:score toPath:exportPath];
                csvString = [csvString stringByAppendingFormat:@", %@\n", fieldDrawingName];
            }
        }
        [csvString writeToFile:filePath
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:nil];
        NSLog(@"%@", csvString);
        csvString = nil;
    });*/
}

-(NSString *)createFullHeader:(NSArray *)scoreList {
    NSString *csvString;
    
    csvString = @"Team Number, Match Type";
    for (NSDictionary *item in scoreList) {
        csvString = [csvString stringByAppendingFormat:@", %@", [item objectForKey:@"header"]];
    }
    csvString = [csvString stringByAppendingString:@", Field Drawing\n"];
    
    return csvString;
}

-(NSString *)createFieldDrawing:(TeamScore *)score toPath:(NSString *)pathName {
/*    if (score.fieldDrawing && score.fieldDrawing.trace) {
        // Build field drawing file name
        NSString *match;
        if ([score.match.number intValue] < 10) {
            match = [NSString stringWithFormat:@"M%c%@", [score.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [score.match.number intValue]]];
        } else if ( [score.match.number intValue] < 100) {
            match = [NSString stringWithFormat:@"M%c%@", [score.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [score.match.number intValue]]];
        } else {
            match = [NSString stringWithFormat:@"M%c%@", [score.match.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [score.match.number intValue]]];
        }
        NSString *team;
        if ([score.team.number intValue] < 100) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [score.team.number intValue]]];
        } else if ( [score.team.number intValue] < 1000) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [score.team.number intValue]]];
        } else {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        NSString *fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
        
        UIImage *backgroundImage = [UIImage imageNamed:@"2014_field.png"];
        UIImage *fieldTrace = [UIImage imageWithData:score.fieldDrawing.trace];
        
        UIGraphicsBeginImageContext(backgroundImage.size);
        [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
        [fieldTrace drawInRect:CGRectMake(backgroundImage.size.width - fieldTrace.size.width, backgroundImage.size.height - fieldTrace.size.height, fieldTrace.size.width, fieldTrace.size.height)];
        UIImage *combinedDrawing = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSString *fullPath = [pathName stringByAppendingPathComponent:fieldDrawingFile];
        [UIImagePNGRepresentation(combinedDrawing) writeToFile:fullPath atomically:YES];
        return fieldDrawingFile;
    }
    else return @"";*/
    return @"";
}

-(void)exportScoreForXFer:(TeamScore *)score toFile:(NSString *)exportFilePath {
    // File name format M(Type)#T#
    NSString *match;
    NSString *matchTypeString = [EnumerationDictionary getKeyFromValue:score.matchType forDictionary:matchDictionary];
    char matchCode;
    if (matchTypeString) matchCode = [matchTypeString characterAtIndex:0];
    if ([score.matchNumber intValue] < 10) {
        match = [NSString stringWithFormat:@"M%c%@", matchCode, [NSString stringWithFormat:@"00%d", [score.matchNumber intValue]]];
     } else if ( [score.match.number intValue] < 100) {
     match = [NSString stringWithFormat:@"M%c%@", matchCode, [NSString stringWithFormat:@"0%d", [score.matchNumber intValue]]];
     } else {
     match = [NSString stringWithFormat:@"M%c%@", matchCode, [NSString stringWithFormat:@"%d", [score.matchNumber intValue]]];
     }
     NSString *team;
     if ([score.teamNumber intValue] < 100) {
     team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [score.teamNumber intValue]]];
     } else if ( [score.teamNumber intValue] < 1000) {
     team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [score.teamNumber intValue]]];
     } else {
     team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [score.teamNumber intValue]]];
     }
     NSString *exportFile = [exportFilePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@_%@.pck", match, team]];
     NSData *myData = [self packageScoreForXFer:score];
     [myData writeToFile:exportFile atomically:YES];
    
}

-(NSData *)packageScoreForXFer:(TeamScore *)score {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!teamScoreAttributes) teamScoreAttributes = [[score entity] attributesByName];
    for (NSString *item in teamScoreAttributes) {
        if ([score valueForKey:item]) {
            // if (![DataConvenienceMethods compareAttributeToDefault:[score valueForKey:item] forAttribute:[teamScoreAttributes valueForKey:item]]) {
            [keyList addObject:item];
            [valueList addObject:[score valueForKey:item]];
            // }
        }
    }
    if (score.fieldDrawing && score.fieldDrawing.trace) {
        [keyList addObject:@"fieldDrawing"];
        [valueList addObject:score.fieldDrawing.trace];
    }
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    if ([score.match.number intValue] == 1) {
        NSLog(@"Match = %@, Type = %@, Team = %@, Results = %@", score.matchNumber, score.matchType, score.teamNumber, score.saved);
        NSLog(@"Data = %@", dictionary);
    }
    return myData;
}

- (void)dealloc
{
    NSLog(@"Export Score dealloc");
    _dataManager = nil;
    prefs = nil;
    tournamentName = nil;
    properties = nil;
    attributes = nil;
    matchDictionary = nil;
    scoutingSpreadsheetList = nil;
}


@end
