//
//  MatchAccessors.m
//  AerialAssist
//
//  Created by FRC on 11/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchAccessors.h"
#import "DataManager.h"

@implementation MatchAccessors
+(MatchData *)getMatch:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    MatchData *match;
    // A match needs 3 unique items to define it. A match number, the match type and the tournament name.
    //NSLog(@"Searching for match = %@ %@", matchType, matchNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MatchData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND number = %@ AND matchType = %@", tournament, matchNumber, matchType];
    [fetchRequest setPredicate:pred];
    NSArray *matchData = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!matchData) return nil; // error will have value from executeFetchRequest

    NSString *msg;
    switch ([matchData count]) {
        case 0:
            msg = [NSString stringWithFormat:@"Unable to get %@ Match %@", matchType, matchNumber];
            error = [NSError errorWithDomain:@"getMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            return nil;
            break;
        case 1:
            match = [matchData objectAtIndex:0];
            // NSLog(@"Match %@ %@ exists", matchType, matchNumber);
            return match;
            break;
        default:
            msg = [NSString stringWithFormat:@"Match %@ %@ found multiple times", matchType, matchNumber];
            error = [NSError errorWithDomain:@"getMatch" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            return match;
            break;
    }
}


@end
