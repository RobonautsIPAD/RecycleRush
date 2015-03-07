//
//  DataConvenienceMethods.m
//  RecycleRush
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

+(NSDictionary *)findKey:(NSString *)name forAttributes:(NSArray *)attributeNames forDictionary:(NSArray *)dataDictionary error:(NSError **)error {
    
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
        if ([name caseInsensitiveCompare:[item objectForKey:@"key"]] == NSOrderedSame ) {
            // key = [item objectForKey:@"key"];
            itemDictionary = item;
            found = TRUE;
            break;
        }
        else {
            NSArray *inputList = [[item objectForKey:@"input"] componentsSeparatedByString:@", "];
            NSArray *match = [inputList filteredArrayUsingPredicate:pred];
            if (match && [match count] == 1) {
                // key = [item objectForKey:@"key"];
                itemDictionary = item;
                found = TRUE;
                break;
            }
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
            NSString *msg = [NSString stringWithFormat:@"Invalid Key: %@", name];
            *error = [NSError errorWithDomain:@"findKey" code:100 userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            // NSLog(@"%@ not found", name);
        }
    }
    return itemDictionary;
}

+(BOOL)setAttributeValue:record forValue:data forAttribute:attribute forEnumDictionary:enumDictionary {
    BOOL error = FALSE;
    NSAttributeType attributeType = [attribute attributeType];
    NSScanner *scanner = [NSScanner scannerWithString:data];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        // NSLog(@"Is numeric??? %d", isNumeric);
        if (isNumeric) {
            [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
        }
        else {
            if (enumDictionary) {
               // NSLog(@"Do something with enum %@", enumDictionary);
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
        BOOL isNumeric = [scanner scanFloat:NULL] && [scanner isAtEnd];
        if (isNumeric) {
            [record setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:[attribute name]];
        }
        else {
            error = true;
        }
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
                // Check if the number is a key string in the dictionary
                // An example is Intake type = 118. In that case, the
                //  118 is a valid string key in the dictionary
                NSNumber *valueObject = [EnumerationDictionary getValueFromKey:data forDictionary:enumDictionary];
                if (valueObject) {
                    [record setValue:data forKey:[attribute name]];
                }
                else {
                    // The data is numeric. Get the associated string value
                    // from the dictionary
                    NSString *text = [EnumerationDictionary getKeyFromValue:[NSNumber numberWithInt:[data intValue]] forDictionary:enumDictionary];
                    if (text && ![text isEqualToString:@""]) {
                        // Value was found in dictionary
                        [record setValue:text forKey:[attribute name]];
                        error = FALSE;
                    }
                    else {
                        // Value was not found in dictionary
                        error = TRUE;
                    }
                }
            }
            else {
                // The data is non-numeric. Make sure the string is
                // in the dictionary
                NSString *actualKey = [EnumerationDictionary getCaseInsensitiveKey:data forDictionary:enumDictionary];
                if (actualKey) {
                    // NSLog(@"Found key = %@", data);
                    [record setValue:actualKey forKey:[attribute name]];
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
        // NSLog(@"Integer");
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
            NSNumber *factor = [data objectForKey:@"factor"];
            float realFactor = 1.0;
            if (factor) realFactor = [factor floatValue];
            result = [NSString stringWithFormat:descriptor, [value floatValue]*realFactor];
        }
        else {
            result = [NSString stringWithFormat:descriptor, 0];
        }
    }
    return result;
}

@end
