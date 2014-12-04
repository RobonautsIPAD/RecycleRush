//
//  TeamAccessors.m
//  AerialAssist
//
//  Created by FRC on 11/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TeamAccessors.h"
#import "DataManager.h"
#import "TeamData.h"

@implementation TeamAccessors
+(TeamData *)getTeam:(NSNumber *)teamNumber fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    TeamData *team;
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if(!teamData) {
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }
    NSString *msg;
    switch ([teamData count]) {
        case 0:
            msg = [NSString stringWithFormat:@"Team %@ does not exist", teamNumber];
            error = [NSError errorWithDomain:@"getTeam" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [dataManager writeErrorMessage:error forType:[error code]];
            return nil;
            break;
        case 1:
            team = [teamData objectAtIndex:0];
            // NSLog(@"Team %@ exists", team.number);
            return team;
            break;
        default:
            msg = [NSString stringWithFormat:@"Team %@ found multiple times", teamNumber];
            error = [NSError errorWithDomain:@"getTeam" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [dataManager writeErrorMessage:error forType:[error code]];
            team = [teamData objectAtIndex:0];
            return team;
            break;
    }
}

+(TeamData *)getTeam:(NSNumber *)teamNumber inTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getTeam inTournament" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
        return nil;
    }

    TeamData *team;
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@ AND (ANY tournaments.name = %@)", teamNumber, tournament];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    if(!teamData) return nil; // error will have value from executeFetchRequest failure
    
    NSString *msg;
    switch ([teamData count]) {
        case 0:
            msg = [NSString stringWithFormat:@"Team %@ is not in Tournament %@", teamNumber, tournament];
            error = [NSError errorWithDomain:@"getTeam" code:kWarningMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            [dataManager writeErrorMessage:error forType:[error code]];
            return nil;
            break;
        case 1:
            team = [teamData objectAtIndex:0];
            // NSLog(@"Team %@ exists", team.number);
            return team;
            break;
        default: {
            NSString *msg = [NSString stringWithFormat:@"Team %@ found multiple times", teamNumber];
            error = [NSError errorWithDomain:@"getTeam inTournament" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
            team = [teamData objectAtIndex:0];
            return team;
        }
            break;
    }
}

+(NSArray *)getTeamsInTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getTeamsInTournament" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        return nil;
    }
    NSMutableArray *teamList = [[NSMutableArray alloc] init];
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournament];
    [fetchRequest setPredicate:pred];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamData = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        [dataManager writeErrorMessage:error forType:[error code]];
    }
    for (TeamData *team in teamData) {
        [teamList addObject:team.number];
    }
    return teamList;
}

+(NSArray *)getTeamDataForTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager {
    NSError *error = nil;
    if (!dataManager.managedObjectContext) {
        error = [NSError errorWithDomain:@"getTeamDataForTournament" code:kErrorMessage userInfo:[NSDictionary dictionaryWithObject:@"Missing managedObjectContext" forKey:NSLocalizedDescriptionKey]];
        [dataManager writeErrorMessage:error forType:[error code]];
       return nil;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if (tournament) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournaments.name = %@", tournament];
        [fetchRequest setPredicate:pred];
    }
    NSArray *teamData = [dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        [dataManager writeErrorMessage:error forType:[error code]];
    }
    return teamData;
}


@end
