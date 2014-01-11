//
//  TeamScore.h
//  AerialAssist
//
//  Created by FRC on 1/10/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FieldDrawing, MatchData, TeamData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSString * alliance;
@property (nonatomic, retain) NSNumber * allianceSection;
@property (nonatomic, retain) NSNumber * autonHigh;
@property (nonatomic, retain) NSNumber * autonLow;
@property (nonatomic, retain) NSNumber * autonMid;
@property (nonatomic, retain) NSNumber * autonMissed;
@property (nonatomic, retain) NSNumber * autonShotsMade;
@property (nonatomic, retain) NSNumber * blocks;
@property (nonatomic, retain) NSNumber * climbAttempt;
@property (nonatomic, retain) NSNumber * climbLevel;
@property (nonatomic, retain) NSNumber * climbTimer;
@property (nonatomic, retain) NSNumber * defenseRating;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSNumber * floorPickUp;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * otherRating;
@property (nonatomic, retain) NSNumber * passes;
@property (nonatomic, retain) NSNumber * pyramid;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * robotSpeed;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * savedBy;
@property (nonatomic, retain) NSNumber * sc1;
@property (nonatomic, retain) NSNumber * sc2;
@property (nonatomic, retain) NSNumber * sc3;
@property (nonatomic, retain) NSNumber * sc4;
@property (nonatomic, retain) NSNumber * sc5;
@property (nonatomic, retain) NSNumber * sc6;
@property (nonatomic, retain) NSString * sc7;
@property (nonatomic, retain) NSString * sc8;
@property (nonatomic, retain) NSString * sc9;
@property (nonatomic, retain) NSData * storedFieldDrawing;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) NSNumber * teleOpHigh;
@property (nonatomic, retain) NSNumber * teleOpLow;
@property (nonatomic, retain) NSNumber * teleOpMid;
@property (nonatomic, retain) NSNumber * teleOpMissed;
@property (nonatomic, retain) NSNumber * teleOpShots;
@property (nonatomic, retain) NSNumber * totalAutonShots;
@property (nonatomic, retain) NSNumber * totalTeleOpShots;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSNumber * wallPickUp;
@property (nonatomic, retain) NSNumber * wallPickUp1;
@property (nonatomic, retain) NSNumber * wallPickUp2;
@property (nonatomic, retain) NSNumber * wallPickUp3;
@property (nonatomic, retain) NSNumber * wallPickUp4;
@property (nonatomic, retain) FieldDrawing *fieldDrawing;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) TeamData *team;

@end
