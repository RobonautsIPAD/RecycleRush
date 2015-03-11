//
//  DallasMigration.m
//  RecycleRush
//
//  Created by FRC on 3/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "DallasMigration.h"
#import "DataManager.h"
#import "MatchPhotoUtilities.h"
#import "TeamScore.h"
#import "MatchAccessors.h"
#import "FieldPhoto.h"

@implementation DallasMigration {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    MatchPhotoUtilities *matchPhotoUtilities;
    NSDictionary *matchTypeDictionary;
}

-(id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        prefs = [NSUserDefaults standardUserDefaults];
        tournamentName = [prefs objectForKey:@"tournament"];
        matchPhotoUtilities = [[MatchPhotoUtilities alloc] init:_dataManager];
        matchTypeDictionary = _dataManager.matchTypeDictionary;
 	}
	return self;
}
#ifdef NOTUSED

-(void)dallasMigration2 {
    // Get all score record with results
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@", tournamentName, [NSNumber numberWithBool:YES]];
    //    pred = [NSPredicate predicateWithFormat:@"results = %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:pred];
    NSArray *matchResultsList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (TeamScore *score in matchResultsList) {
        NSString *matchTypeString = [MatchAccessors getMatchTypeString:score.matchType fromDictionary:matchTypeDictionary];
        NSLog(@"%@ %@ Team %@", matchTypeString, score.matchNumber, score.teamNumber);
        score.fieldPhotoName = score.sc7;
        score.toteIntakeLandfill = score.sc1;
        score.autonToteSet = score.sc2;
        score.autonCansFromStep = score.sc3;
        if (![_dataManager saveContext]) {
            NSLog(@"Bad save");
        }
    }
}

-(void)dallasMigration1 {
    // Get all score record with results
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamScore" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournamentName = %@ AND results = %@", tournamentName, [NSNumber numberWithBool:YES]];
//    pred = [NSPredicate predicateWithFormat:@"results = %@", [NSNumber numberWithBool:YES]];
    [fetchRequest setPredicate:pred];
    NSArray *matchResultsList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (TeamScore *score in matchResultsList) {
        NSString *matchTypeString = [MatchAccessors getMatchTypeString:score.matchType fromDictionary:matchTypeDictionary];
        NSLog(@"%@ %@ Team %@", matchTypeString, score.matchNumber, score.teamNumber);
        score.sc7 = [matchPhotoUtilities savePhoto:score.field.paper forMatch:score.matchNumber forType:matchTypeString forTeam:score.teamNumber];
        [_dataManager.managedObjectContext deleteObject:score.field];
        score.field = nil;
        score.sc1 = [NSNumber numberWithInt:([score.toteIntakeBottomFloor intValue] + [score.toteIntakeTopFloor intValue])];
        score.toteIntakeStep = [NSNumber numberWithInt:([score.toteStepBottom intValue] + [score.toteStepTop intValue])];
        score.totalTotesIntake = [NSNumber numberWithInt:([score.sc1 intValue] + [score.toteIntakeStep intValue] + [score.toteIntakeHP intValue])];
        score.sc2 = score.autonTotesSet;
        score.sc3 = score.canDomination;
        if (![_dataManager saveContext]) {
            NSLog(@"Bad save");
        }
    }
}
#endif

@end