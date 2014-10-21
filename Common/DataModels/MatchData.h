//
//  MatchData.h
//  AerialAssist
//
//  Created by FRC on 10/16/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore;

@interface MatchData : NSManagedObject

@property (nonatomic, retain) NSNumber * blueScore;
@property (nonatomic, retain) NSNumber * matchType;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * redScore;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * savedBy;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSSet *score;
@end

@interface MatchData (CoreDataGeneratedAccessors)

- (void)addScoreObject:(TeamScore *)value;
- (void)removeScoreObject:(TeamScore *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

@end
