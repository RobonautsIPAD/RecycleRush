//
//  ExportScoreData.m
//  RecycleRush
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ExportScoreData.h"
#import "DataManager.h"
#import "DataConvenienceMethods.h"
#import "TeamScore.h"
#import "FieldDrawing.h"
#import "MatchAccessors.h"
#import "ScoreUtilities.h"
#import "TeamData.h"
#import "TeamAccessors.h"
#import "TeamUtilities.h"
#import "MatchData.h"

@implementation ExportScoreData {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSDictionary *teamScoreAttributes;
    NSDictionary *properties;
    NSDictionary *attributes;
    NSDictionary *matchDictionary;
    NSArray *scoutingSpreadsheetList;
    ScoreUtilities *scoreUtilites;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        matchDictionary = _dataManager.matchTypeDictionary;
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
        teamScoreAttributes = [entity attributesByName];
        scoreUtilites = [[ScoreUtilities alloc] init:_dataManager];
	}
	return self;
}

-(NSString *)teamScoreCSVExport {
    if (!_dataManager) {
        NSError *error = [NSError errorWithDomain:@"teamScoreCSVExport" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing data manager" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
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

-(BOOL)spreadsheetCSVExport:(NSString *)tournament withTypes:(NSString *)dataType toFile:(NSString *)fullPath {
    NSError *error = nil;
    NSFileHandle *fullPathHandle;
    BOOL isData = FALSE;
    //int maxMatches = 0;
    if (!_dataManager) {
        error = [NSError errorWithDomain:@"teamScoreCSVExport" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing data manager" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return FALSE;
    }
    NSString *fullData = nil;
    if (!scoutingSpreadsheetList) {
        // Load dictionary with list of parameters for the scouting spreadsheet
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MarcusOutput" ofType:@"plist"];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        scoutingSpreadsheetList = [[[NSArray alloc] initWithContentsOfFile:plistPath] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    fullData = [self createSpreadsheetHeader];
    [fullData writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    fullPathHandle = [NSFileHandle fileHandleForWritingAtPath:fullPath];

    NSNumber *spreadsheetSync = [prefs objectForKey:@"spreadsheetSync"];

    NSArray *teamList = [TeamAccessors getTeamsInTournament:tournamentName fromDataManager:_dataManager];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchType" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    for (NSNumber *teamNumber in teamList) {
        NSPredicate *pred;
        if ([dataType isEqualToString:@"Practice"]) {
            pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ AND teamNumber = %@ && saved > %@", tournament, [NSNumber numberWithBool:YES], teamNumber, spreadsheetSync];
        }
        else {
            pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ AND match.matchType = %@ AND teamNumber = %@ && saved > %@", tournament, [NSNumber numberWithBool:YES], [MatchAccessors getMatchTypeFromString:@"Qualification" fromDictionary:matchDictionary], teamNumber, spreadsheetSync];
        }
        [fetchRequest setPredicate:pred];
        NSArray *teamScores = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        for (TeamScore *score in teamScores) {
            if([score.matchNumber intValue] == 4 && [score.teamNumber intValue] == 118) {
                NSLog(@"Stop here");
            }
            isData = TRUE;
            BOOL firstStack = TRUE;
            BOOL firstCan = TRUE;
            BOOL firstCap = TRUE;
            NSString *csvString = [NSString stringWithFormat:@"\n%@", teamNumber];
            for (NSDictionary *spreadsheetParameters in scoutingSpreadsheetList) {
                NSString *key = [spreadsheetParameters objectForKey:@"key"];
                if ([key isEqualToString:@"stack"]) {
                    if (firstStack) {
                        NSString *junk = [self getStackData:score];
                        csvString = [csvString stringByAppendingString:junk];
                        firstStack = FALSE;
                        continue;
                    }
                }
                else if ([key isEqualToString:@"blank"]) {
                    csvString = [csvString stringByAppendingFormat:@", "];
                }
                else if ([key isEqualToString:@"can"]) {
                    if (firstCan) {
                        NSString *junk = [self getCanData:score];
                        csvString = [csvString stringByAppendingString:junk];
                        firstCan = FALSE;
                        continue;
                    }
                }
                else if ([key isEqualToString:@"cap"]) {
                    if (firstCap) {
                        NSString *junk = [self getCapData:score];
                        csvString = [csvString stringByAppendingString:junk];
                        firstCap = FALSE;
                        continue;
                    }
                }
                else {
                    csvString = [csvString stringByAppendingFormat:@", %@", [score valueForKey:key]];
                }
            }
            [fullPathHandle seekToEndOfFile];
            [fullPathHandle writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [prefs setObject:[NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()] forKey:@"spreadsheetSync"];

    [fullPathHandle closeFile];
    return isData;
}

-(NSString *)createSpreadsheetHeader {
    NSString *csvString;
    
    csvString = @"Team Number";
    for (NSDictionary *spreadsheetParameters in scoutingSpreadsheetList) {
        csvString = [csvString stringByAppendingFormat:@", %@", [spreadsheetParameters objectForKey:@"header"]];
    }
    //csvString = [csvString stringByAppendingString:@"\n"];
    
    return csvString;
}

-(NSString *)getStackData:(TeamScore *)score {
    NSDictionary *stackDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:score.stacks];
    NSString *stacks = [[NSString alloc] init];
    //NSLog(@"%@", stackDictionary);
    NSArray *allKeys = [stackDictionary allKeys];
    allKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    int count = 0;
    for (NSString *key in allKeys) {
        NSDictionary *cell = [stackDictionary objectForKey:key];
        NSArray *allFields = [cell allKeys];
        allFields = [allFields sortedArrayUsingSelector:@selector(compare:)];
        int stackTotal = 0;
        for (int i=0; i<[allFields count]; i+=2) {
            NSString *numerator = [cell objectForKey:[allFields objectAtIndex:i]];
            NSString *denominator = [cell objectForKey:[allFields objectAtIndex:i+1]];
            NSDictionary *numeratorTotal = [self getTextFieldData:numerator];
            NSDictionary *denominatorTotal = [self getTextFieldData:denominator];
            stackTotal += [[numeratorTotal objectForKey:@"totes"] intValue];
        }
        stacks = [stacks stringByAppendingFormat:@", %d", stackTotal];
        count++;
        if (count >5) break;
    }
    for (int i=count; i<6; i++) {
        stacks = [stacks stringByAppendingString:@", 0"];
    }
    return stacks;
}

-(NSString *)getCanData:(TeamScore *)score {
    NSDictionary *stackDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:score.stacks];
    NSString *stacks = [[NSString alloc] init];
    //NSLog(@"%@", stackDictionary);
    NSArray *allKeys = [stackDictionary allKeys];
    allKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    int count = 0;
    for (NSString *key in allKeys) {
        NSDictionary *cell = [stackDictionary objectForKey:key];
        NSArray *allFields = [cell allKeys];
        allFields = [allFields sortedArrayUsingSelector:@selector(compare:)];
        int can = 0;
        int canDenom = 0;
        for (int i=0; i<[allFields count]; i+=2) {
            NSString *numerator = [cell objectForKey:[allFields objectAtIndex:i]];
            NSString *denominator = [cell objectForKey:[allFields objectAtIndex:i+1]];
            NSDictionary *numeratorTotal = [self getTextFieldData:numerator];
            NSDictionary *denominatorTotal = [self getTextFieldData:denominator];
            can = [[numeratorTotal objectForKey:@"cans"] intValue];
            if (can > 0) canDenom = [[denominatorTotal objectForKey:@"totes"] intValue];
        }
        if (can) {
            if (!canDenom) stacks = [stacks stringByAppendingFormat:@", %d", can];
            else stacks = [stacks stringByAppendingFormat:@", 0"];
        }
        else stacks = [stacks stringByAppendingFormat:@", 0"];
        count++;
        if (count >5) break;
    }
    for (int i=count; i<6; i++) {
        stacks = [stacks stringByAppendingString:@", 0"];
    }
    return stacks;
}

-(NSString *)getCapData:(TeamScore *)score {
    NSDictionary *stackDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:score.stacks];
    NSString *stacks = [[NSString alloc] init];
    //NSLog(@"%@", stackDictionary);
    NSArray *allKeys = [stackDictionary allKeys];
    allKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    int count = 0;
    for (NSString *key in allKeys) {
        NSDictionary *cell = [stackDictionary objectForKey:key];
        NSArray *allFields = [cell allKeys];
        allFields = [allFields sortedArrayUsingSelector:@selector(compare:)];
        int can = 0;
        int canDenom = 0;
        for (int i=0; i<[allFields count]; i+=2) {
            NSString *numerator = [cell objectForKey:[allFields objectAtIndex:i]];
            NSString *denominator = [cell objectForKey:[allFields objectAtIndex:i+1]];
            NSDictionary *numeratorTotal = [self getTextFieldData:numerator];
            NSDictionary *denominatorTotal = [self getTextFieldData:denominator];
            can = [[numeratorTotal objectForKey:@"cans"] intValue];
            if (can > 0) canDenom = [[denominatorTotal objectForKey:@"totes"] intValue];
        }
        if (can) {
            if (canDenom) stacks = [stacks stringByAppendingFormat:@", %d", can];
            else stacks = [stacks stringByAppendingFormat:@", 0"];
        }
        else stacks = [stacks stringByAppendingFormat:@", 0"];
        count++;
        if (count >5) break;
    }
    for (int i=count; i<6; i++) {
        stacks = [stacks stringByAppendingString:@", 0"];
    }
    return stacks;
}

-(NSDictionary *)getTextFieldData:(NSString *)field {
    NSNumber *totes = [NSNumber numberWithInt:0];
    NSNumber *cans = [NSNumber numberWithInt:0];
    NSNumber *litter = [NSNumber numberWithInt:0];
    for(int i =0 ;i<[field length]; i++) {
        char character = [field characterAtIndex:i];
        if (isdigit(character)) {
            totes = [NSNumber numberWithInt:(int)(character - '0')];
        }
        else if (character == 'C') cans = [NSNumber numberWithInt:1];
        else if (character == 'L') litter = [NSNumber numberWithInt:1];
    }
    NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:
                             totes, @"totes",
                             cans, @"cans",
                             litter, @"litter",
                             nil];
    return results;
}


-(BOOL)scoreBundleCSVExport:(NSString *)tournament toFile:(NSString *)fullPath {
    // Check if init function has run properly
    NSError *error = nil;
    NSFileHandle *fullPathHandle;
    if (!_dataManager) {
        error = [NSError errorWithDomain:@"teamScoreCSVExport" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing data manager" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return FALSE;
    }
    long int scoutingBundleSyncInt = [[prefs objectForKey:@"scoutingBundleSync"] longValue];

    NSString *csvString;
    NSArray *teamList = [TeamAccessors getTeamsInTournament:tournament fromDataManager:_dataManager];
    if (!teamList || ![teamList count]) {
        NSError *error;
        error = [NSError errorWithDomain:@"teamBundleCSVExport" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"No Team data to export" forKey:NSLocalizedDescriptionKey]];
        [_dataManager writeErrorMessage:error forType:[error code]];
        return FALSE;
    }

    TeamUtilities *teamUtilities = [[TeamUtilities alloc] init:_dataManager];
    NSArray *allKeys = [teamScoreAttributes allKeys];
    csvString = @"teamNumber, matchNumber, matchType";
    for (NSString *key in allKeys) {
        if ([key isEqualToString:@"teamNumber"] || [key isEqualToString:@"matchNumber"] || [key isEqualToString:@"matchType"]) continue;
        csvString = [csvString stringByAppendingFormat:@", %@", key];
    }
    [csvString writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    fullPathHandle = [NSFileHandle fileHandleForWritingAtPath:fullPath];
    //NSLog(@"%@", csvString);
    
    for (NSNumber *teamNumber in teamList) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.matchType" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"match.number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@ AND teamNumber = %@", tournament, [NSNumber numberWithBool:YES], teamNumber];
        [fetchRequest setPredicate:pred];
        NSArray *teamScores = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        // Update Max Tote Height and Max Can height for the team.
        TeamData *team = [TeamAccessors getTeam:teamNumber fromDataManager:_dataManager];
        if (team) {
            int max = [[teamScores valueForKeyPath:@"@max.maxToteHeight"] intValue];
            //NSLog(@"Max tote = %d", max);
            if ([team.maxToteStack intValue] != max) {
                team.maxToteStack = [NSNumber numberWithInt:max];
                team = [teamUtilities saveTeam:team];
            }
            max = [[teamScores valueForKeyPath:@"@max.maxCanHeight"] intValue];
            //NSLog(@"Max can = %d", max);
            if ([team.maxCanHeight intValue] != max) {
                team.maxCanHeight = [NSNumber numberWithInt:max];
                team = [teamUtilities saveTeam:team];
            }
        }
        for (TeamScore *score in teamScores) {
            // Skip if this record has been printed out already. So, always print if
            // the scoutingBundleSync is zero or the saved time is greater than the scoutingBundleSync
            if (scoutingBundleSyncInt && [score.saved longValue]<scoutingBundleSyncInt) continue;
            csvString = [NSString stringWithFormat:@"\n%@, %@, %@", score.teamNumber, score.matchNumber, score.matchType];
            for (NSString *key in allKeys) {
                if ([key isEqualToString:@"teamNumber"] || [key isEqualToString:@"matchNumber"] || [key isEqualToString:@"matchType"]) continue;
                csvString = [csvString stringByAppendingFormat:@", "];
                NSDictionary *description = [teamScoreAttributes valueForKey:key];
                csvString = [csvString stringByAppendingString:[DataConvenienceMethods outputCSVValue:[score valueForKey:key] forAttribute:description forEnumDictionary:nil]];
            }
            [fullPathHandle seekToEndOfFile];
            [fullPathHandle writeData:[csvString dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [fullPathHandle closeFile];
    return TRUE;
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
    NSString *matchTypeString = [MatchAccessors getMatchTypeString:score.matchType fromDictionary:matchDictionary];
    char matchCode = 'O';
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
     NSDictionary *packagedScore = [scoreUtilites packageScoreForXFer:score];
     NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:packagedScore];
     [myData writeToFile:exportFile atomically:YES];
}

- (void)dealloc
{
    //NSLog(@"Export Score dealloc");
    _dataManager = nil;
    prefs = nil;
    tournamentName = nil;
    properties = nil;
    attributes = nil;
    matchDictionary = nil;
    scoutingSpreadsheetList = nil;
}


@end
