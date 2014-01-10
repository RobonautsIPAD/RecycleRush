//
//  TournamentData.h
//  AerialAssist
//
//  Created by FRC on 1/8/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData, TeamScore;

@interface TournamentData : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *score;
@property (nonatomic, retain) NSSet *teams;
@end

@interface TournamentData (CoreDataGeneratedAccessors)

- (void)addScoreObject:(TeamScore *)value;
- (void)removeScoreObject:(TeamScore *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

- (void)addTeamsObject:(TeamData *)value;
- (void)removeTeamsObject:(TeamData *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
