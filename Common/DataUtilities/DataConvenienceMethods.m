//
//  DataConvenienceMethods.m
//  AerialAssist
//
//  Created by FRC on 7/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "DataConvenienceMethods.h"
#import "TournamentData.h"

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

@end
