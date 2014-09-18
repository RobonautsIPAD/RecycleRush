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
#import "QuadStateDictionary.h"
#import "TriStateDictionary.h"

@implementation DataConvenienceMethods
+(TournamentData *)getTournament:(NSString *)name fromContext:(NSManagedObjectContext *)managedObjectContext {
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

+(NSDictionary *)findKey:(NSString *)name forAttributes:(NSArray *)attributeNames forDictionary:(NSArray *)dataDictionary {
    
    BOOL found = FALSE;
    NSString *key;
    NSDictionary *itemDictionary;
    NSDictionary *attributeInfo;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"self == [cd] %@", name];
 
    NSLog(@"looking for %@", name);
    // Look in the data dictionary first, if the name is not there, then look in the
    // in the list off attributes. The dictionary contains additional information
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
            NSLog(@"%@ not found", name);
        }
    }
    return itemDictionary;
}

+(void)setAttributeValue:record forValue:data forAttribute:attribute forEnumDictionary:enumDictionary {
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        NSScanner *scanner = [NSScanner scannerWithString:data];
        BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
        NSLog(@"Is numeric??? %d", isNumeric);
        if (isNumeric) {
            [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
        }
        else {
            if (enumDictionary) {
                NSLog(@"Do something with enum %@", enumDictionary);
      //          NSNumber *numericValue = [enumDictionary valueForKey:data];
      //          NSLog(@"data = %@, value = %@", data, numericValue);
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
            NSLog(@"Is numeric??? %d", isNumeric);
            if (isNumeric) {
                // The data is numeric. Get the associated string value
                // from the dictionary
            //    [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
            }
            else {
                // The data is non-numeric. Make sure the string is
                // in the dictionary
                NSLog(@"Do something with enum %@", enumDictionary);
                NSLog(@"keys = %@", [enumDictionary allKeys]);
                if ([enumDictionary objectForKey:data]) {
                    NSLog(@"Found key = %@", data);
                    [record setValue:data forKey:[attribute name]];
                }
 //               NSPredicate *pred = [NSPredicate predicateWithFormat:@"key = %@", data];
 //               NSArray *acceptableStrings = [[enumDictionary allKeys] filteredArrayUsingPredicate:pred];
                    //   NSNumber *numericValue = [enumDictionary getEnumValue:data];
   //             NSLog(@"data = %@, string = %@", data, acceptableStrings);
            }
        }
        else {
            [record setValue:data forKey:[attribute name]];
        }
    }
}


@end
