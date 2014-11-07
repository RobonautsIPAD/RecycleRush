//
//  DataConvenienceMethods.m
//  AerialAssist
//
//  Created by FRC on 7/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "DataConvenienceMethods.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "EnumerationDictionary.h"

@implementation DataConvenienceMethods
+(TournamentData *)getTournament:(NSString *)name fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return Nil;
    TournamentData *tournament;
    NSError *error;
        
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                    entityForName:@"TournamentData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", name];
    [fetchRequest setPredicate:pred];
    NSArray *tournamentData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch tournament record"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    else {
        switch ([tournamentData count]) {
            case 0:
                return Nil;
                break;
            case 1:
                tournament = [tournamentData objectAtIndex:0];
                // NSLog(@"Tournament %@ exists", tournament.name);
                return tournament;
                break;
            default: {
                NSString *msg = [NSString stringWithFormat:@"Tournament %@ found multiple times", name];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tournament Database Error"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                tournament = [tournamentData objectAtIndex:0];
                return tournament;
            }
            break;
        }
    }
}

+(TeamData *)getTeam:(NSNumber *)teamNumber fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return Nil;
    TeamData *team;
    NSError *error;

    // NSLog(@"Searching for team = %@", teamNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch team record"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    else {
        switch ([teamData count]) {
            case 0:
                return Nil;
                break;
            case 1:
                team = [teamData objectAtIndex:0];
                // NSLog(@"Team %@ exists", team.number);
                return team;
                break;
            default: {
                NSString *msg = [NSString stringWithFormat:@"Team %@ found multiple times", teamNumber];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Team Database Error"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                team = [teamData objectAtIndex:0];
                return team;
            }
                break;
        }
    }
}

+(TeamData *)getTeamInTournament:(NSNumber *)teamNumber forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return Nil;
    TeamData *team;
    NSError *error;
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@ AND (ANY tournaments.name = %@)", teamNumber, tournament];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch team record"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    else {
        switch ([teamData count]) {
            case 0:
                return Nil;
                break;
            case 1:
                team = [teamData objectAtIndex:0];
                // NSLog(@"Team %@ exists", team.number);
                return team;
                break;
            default: {
                NSString *msg = [NSString stringWithFormat:@"Team %@ found multiple times", teamNumber];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Team Database Error"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                team = [teamData objectAtIndex:0];
                return team;
            }
                break;
        }
    }
}

+(NSArray *)getTournamentTeamList:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return Nil;
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    NSError *error;
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournament];
    [fetchRequest setPredicate:pred];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (TeamData *team in teamData) {
        [teamList addObject:team.number];
    }
    return teamList;
}

+(MatchData *)getMatch:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return Nil;
    MatchData *match;
    NSError *error;
    // A match needs 3 unique items to define it. A match number, the match type and the tournament name.
    //NSLog(@"Searching for match = %@ %@", matchType, matchNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND number = %@ AND matchType = %@", tournament, matchNumber, matchType];
    [fetchRequest setPredicate:pred];
    NSArray *matchData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch match record"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    else {
        switch ([matchData count]) {
            case 0:
                return Nil;
                break;
            case 1:
                match = [matchData objectAtIndex:0];
                // NSLog(@"Match %@ %@ exists", matchType, matchNumber);
                return match;
                break;
            default: {
                NSString *msg = [NSString stringWithFormat:@"Match %@ %@ found multiple times", matchType, matchNumber];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Match Database Error"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                match = [matchData objectAtIndex:0];
                return match;
            }
                break;
        }
    }
    return nil;
}

+(NSArray *)getMatchListForTeam:(NSNumber *)teamNumber forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext {
    
    if (!managedObjectContext) return Nil;
    NSError *error;
    // NSLog(@"Searching for team %@ matches in tournament %@", teamNumber, tournament);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND teamNumber = %@", tournament, teamNumber];
    [fetchRequest setPredicate:pred];
    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchType" ascending:YES];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchNumber" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *matchList = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchList) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch match record"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    return matchList;
}


+(NSArray *)getMatchScores:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *error;
    if (!managedObjectContext) return Nil;
    // A match needs 4 unique items to define it. A match number, the match type and the tournament name.
    // NSLog(@"Searching for match = %@ %@", matchType, matchNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND matchNumber = %@ AND matchType = %@", tournament, matchNumber, matchType];
    [fetchRequest setPredicate:pred];
    NSArray *matchScores = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchScores) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch score records"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    else return matchScores;
}

+(TeamScore *)getScoreRecord:(NSNumber *)matchNumber forType:(NSNumber *)matchType forAlliance:(NSNumber *)alliance forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext {
    if (!managedObjectContext) return Nil;
    // Only one record should meet all these criteria. If more than one
    // is found, then a database corruption has occurred.
    TeamScore *scoreRecord;
    NSError *error;
    // A match needs 3 unique items to define it. A match number, the match type and the tournament name.
    // NSLog(@"Searching for match = %@ %@", matchType, matchNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND matchNumber = %@ AND matchType = %@ AND allianceStation = %@", tournament, matchNumber, matchType, alliance];
    [fetchRequest setPredicate:pred];
    NSArray *matchScores = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchScores) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Database Error Encountered"
                                                        message:@"Not able to fetch score records"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return Nil;
    }
    else {
        switch ([matchScores count]) {
            case 0:
                return Nil;
                break;
            case 1:
                scoreRecord = [matchScores objectAtIndex:0];
                // NSLog(@"Match %@ %@ exists", matchType, matchNumber);
                return scoreRecord;
                break;
            default: {
                NSString *msg = [NSString stringWithFormat:@"Match %@ %@ found multiple times", matchType, matchNumber];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Match Database Error"
                                                                message:msg
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                scoreRecord = [matchScores objectAtIndex:0];
                return scoreRecord;
            }
                break;
        }
    }
    return Nil;
}

+(NSDictionary *)findKey:(NSString *)name forAttributes:(NSArray *)attributeNames forDictionary:(NSArray *)dataDictionary {
    
    BOOL found = FALSE;
    NSString *key;
    NSDictionary *itemDictionary;
    NSDictionary *attributeInfo;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self == [cd] %@", name];
 
    // NSLog(@"looking for %@", name);
    // Look in the data dictionary first, if the name is not there, then look in the
    // in the list of attributes. The dictionary contains additional information
    // useful for input. Not every atttribute has of needs additional info.
    
    for (NSDictionary *item in dataDictionary) {
        NSArray *inputList = [[item objectForKey:@"input"] componentsSeparatedByString:@", "];
        NSArray *match = [inputList filteredArrayUsingPredicate:pred];
        if (match && [match count] == 1) {
            key = [item objectForKey:@"key"];
            itemDictionary = item;
            found = TRUE;
            break;
        }
    }
    if (found) {
        attributeInfo = itemDictionary;
    }
    else {
        NSArray *match = [attributeNames filteredArrayUsingPredicate:pred];
        if (match && [match count] == 1) {
            key = [match objectAtIndex:0];
            itemDictionary = [NSDictionary dictionaryWithObject:key forKey:@"key"];
        }
        else {
            itemDictionary = [NSDictionary dictionaryWithObject:@"Invalid Key" forKey:@"key"];
            // NSLog(@"%@ not found", name);
        }
    }
    return itemDictionary;
}

+(BOOL)setAttributeValue:record forValue:data forAttribute:attribute forEnumDictionary:enumDictionary {
    BOOL error = FALSE;
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        // NSLog(@"Is numeric??? %d", isNumeric);
        if (isNumeric) {
            [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
        }
        else {
            if (enumDictionary) {
                NSLog(@"Do something with enum %@", enumDictionary);
      //          NSNumber *numericValue = [enumDictionary valueForKey:data];
      //          NSLog(@"data = %@, value = %@", data, numericValue);
                error = TRUE;
            }
            else {
                error = TRUE;
            }
        }
    }
    else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) {
        [record setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSBooleanAttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSStringAttributeType) {
        // Check if a dictionary of acceptable choices has been passed in
        if (enumDictionary) {
            // There is a dictionary of accepted choices
            // Check if the data is a number.
            NSScanner *scanner = [NSScanner scannerWithString:data];
            BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
            // NSLog(@"Is numeric??? %d", isNumeric);
            if (isNumeric) {
                // The data is numeric. Get the associated string value
                // from the dictionary
            //    [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
                error = TRUE;
            }
            else {
                // The data is non-numeric. Make sure the string is
                // in the dictionary
                // NSLog(@"Do something with enum %@", enumDictionary);
                // NSLog(@"keys = %@", [enumDictionary allKeys]);
                if ([enumDictionary objectForKey:data]) {
                    // NSLog(@"Found key = %@", data);
                    [record setValue:data forKey:[attribute name]];
                }
                else {
                    error = TRUE;
                }
             }
        }
        else {
            [record setValue:data forKey:[attribute name]];
        }
    }
    return error;
}

+(BOOL)compareAttributeToDefault:(id)value forAttribute:attribute {
    BOOL isDefaultValue = FALSE;
    id defaultValue = [attribute valueForKey:@"defaultValue"];
    if (!defaultValue) return isDefaultValue;
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        if ([value intValue] == [defaultValue intValue]) {
            isDefaultValue = TRUE;
        }
    }
    else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) {
        if ([value floatValue] == [[attribute valueForKey:@"defaultValue"] floatValue]) {
            isDefaultValue = TRUE;
        }

    }
    else if (attributeType == NSBooleanAttributeType) {
        if ([value intValue] == [[attribute valueForKey:@"defaultValue"] intValue]) {
            isDefaultValue = TRUE;
        }
    }
    else if (attributeType == NSStringAttributeType) {
        if ([value isEqualToString:[attribute valueForKey:@"defaultValue"]]) {
            isDefaultValue = TRUE;
        }
    }
    return isDefaultValue;
}

+(NSString *)outputCSVValue:data forAttribute:attribute forEnumDictionary:enumDictionary; {
    NSString *csvString = [[NSString alloc] init];
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSStringAttributeType) {
        // NSLog(@"String");
        NSString *replaced;
        replaced = [data stringByReplacingOccurrencesOfString:@"," withString:@";"];
        if (replaced) {
            replaced = [replaced stringByReplacingOccurrencesOfString:@"\n" withString:@"\\"];
            csvString = [NSString stringWithFormat:@"%@", replaced];
        }
    }
    else if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        NSLog(@"Integer");
        if (enumDictionary) {
            // There is a dictionary of strings to output
            csvString = [EnumerationDictionary getKeyFromValue:data forDictionary:enumDictionary];
        }
        else {
            csvString = [NSString stringWithFormat:@"%@", data];
        }
    }
    else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) {
        // NSLog(@"Float");
        csvString = [NSString stringWithFormat:@"%@", data];
    }
    else if (attributeType == NSBooleanAttributeType) {
        // NSLog(@"Boolean");
        csvString = [NSString stringWithFormat:@"%@", data];
    }
    else {
        NSLog(@"Unsupported Type");
    }
    return csvString;
}

+(NSString *)getTableFormat:(NSDictionary *)data forField:(NSDictionary *)formatData {
    NSString *result = @"";
    NSString *type = [formatData objectForKey:@"type"];
    NSString *descriptor = [formatData objectForKey:@"format"];
    NSNumber *value = [data objectForKey:@"key"];
    
    if ([type isEqualToString:@"integer"]) {
        if (value) {
            result = [NSString stringWithFormat:descriptor, [value intValue]];
        }
        else {
            result = [NSString stringWithFormat:descriptor, 0];
        }
    }
    if ([type isEqualToString:@"float"]) {
        if (value) {
            result = [NSString stringWithFormat:descriptor, [value floatValue]];
        }
        else {
            result = [NSString stringWithFormat:descriptor, 0];
        }
    }
    return result;
}

@end
