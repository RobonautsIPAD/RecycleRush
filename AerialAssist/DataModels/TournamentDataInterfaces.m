//
//  TournamentDataInterfaces.m
//  AerialAssist
//
//  Created by FRC on 1/29/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TournamentDataInterfaces.h"
#import "TournamentData.h"
#import "DataManager.h"

@implementation TournamentDataInterfaces
@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(AddRecordResults)createTournament:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    if (![data count]) return DB_ERROR;
    NSString *tournamentName;
    
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }

    AddRecordResults results = DB_ADDED;
    
    // At the moment, the tournament record has only one field, so we don't need any
    //  parsing of different fields
    tournamentName = [data objectAtIndex: 0];
    TournamentData *tournament = [self getTournament:tournamentName];
    if (tournament) {
        //NSLog(@"createTournamentFromFile:Tournament %@ already exists", tournament);
        return DB_MATCHED;
    }
    else {
        TournamentData *tournament = [NSEntityDescription insertNewObjectForEntityForName:@"TournamentData"
                                                                   inManagedObjectContext:_dataManager.managedObjectContext];
        tournament.name = tournamentName;
        NSError *error;
        if (![_dataManager.managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;
    }
    
    return results;
}

-(NSData *)packageTournamentsForXFer:(NSMutableArray *)tournamentList {
    NSLog(@"tournaments = %@", tournamentList);
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:tournamentList];
    return myData;
}

-(NSArray *)unpackageTournamentsForXFer:(NSData *)xferData {
    
}

-(TournamentData *)getTournament:(NSString *)name {
    TournamentData *tournament;
    NSError *error;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name CONTAINS %@", name];
    [fetchRequest setPredicate:pred];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!tournamentData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([tournamentData count] > 0) {  // Tournament Exists
            tournament = [tournamentData objectAtIndex:0];
            // NSLog(@"Tournament %@ exists", tournament.name);
            return tournament;
        }
        else {
            return Nil;
        }
    }
}

- (void)dealloc {
    _dataManager = nil;
#ifdef TEST_MODE
	NSLog(@"dealloc %@", self);
#endif
}

@end
