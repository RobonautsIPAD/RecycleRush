//
//  TournamentData.h
//  AerialAssist
//
//  Created by FRC on 4/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData;

@interface TournamentData : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSSet *teams;
@end

@interface TournamentData (CoreDataGeneratedAccessors)

- (void)addTeamsObject:(TeamData *)value;
- (void)removeTeamsObject:(TeamData *)value;
- (void)addTeams:(NSSet *)values;
- (void)removeTeams:(NSSet *)values;

@end
