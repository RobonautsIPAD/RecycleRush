//
//  TeamScore.h
//  RecycleRush
//
//  Created by FRC on 11/4/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FieldDrawing, MatchData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSNumber * airCatch;
@property (nonatomic, retain) NSNumber * airPasses;
@property (nonatomic, retain) NSNumber * airPassMiss;
@property (nonatomic, retain) NSNumber * allianceStation;
@property (nonatomic, retain) NSNumber * assistRating;
@property (nonatomic, retain) NSNumber * autonBlocks;
@property (nonatomic, retain) NSNumber * autonHighCold;
@property (nonatomic, retain) NSNumber * autonHighHot;
@property (nonatomic, retain) NSNumber * autonHighMiss;
@property (nonatomic, retain) NSNumber * autonLowCold;
@property (nonatomic, retain) NSNumber * autonLowHot;
@property (nonatomic, retain) NSNumber * autonLowMiss;
@property (nonatomic, retain) NSNumber * autonMissed;
@property (nonatomic, retain) NSNumber * autonMobility;
@property (nonatomic, retain) NSNumber * autonShotsMade;
@property (nonatomic, retain) NSNumber * deadOnArrival;
@property (nonatomic, retain) NSNumber * defenseBlockRating;
@property (nonatomic, retain) NSNumber * defenseBullyRating;
@property (nonatomic, retain) NSNumber * defensiveDisruption;
@property (nonatomic, retain) NSNumber * disruptedShot;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSNumber * floorCatch;
@property (nonatomic, retain) NSNumber * floorCatchMiss;
@property (nonatomic, retain) NSNumber * floorPasses;
@property (nonatomic, retain) NSNumber * floorPassMiss;
@property (nonatomic, retain) NSNumber * floorPickUp;
@property (nonatomic, retain) NSNumber * floorPickUpMiss;
@property (nonatomic, retain) NSNumber * fouls;
@property (nonatomic, retain) NSNumber * humanMiss;
@property (nonatomic, retain) NSNumber * humanMiss1;
@property (nonatomic, retain) NSNumber * humanMiss2;
@property (nonatomic, retain) NSNumber * humanMiss3;
@property (nonatomic, retain) NSNumber * humanMiss4;
@property (nonatomic, retain) NSNumber * humanPickUp;
@property (nonatomic, retain) NSNumber * humanPickUp1;
@property (nonatomic, retain) NSNumber * humanPickUp2;
@property (nonatomic, retain) NSNumber * humanPickUp3;
@property (nonatomic, retain) NSNumber * humanPickUp4;
@property (nonatomic, retain) NSNumber * intakeRating;
@property (nonatomic, retain) NSNumber * knockout;
@property (nonatomic, retain) NSNumber * matchNumber;
@property (nonatomic, retain) NSNumber * matchType;
@property (nonatomic, retain) NSNumber * noShow;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * otherRating;
@property (nonatomic, retain) NSNumber * passesCaught;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * results;
@property (nonatomic, retain) NSNumber * robotIntake;
@property (nonatomic, retain) NSNumber * robotIntakeMiss;
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
@property (nonatomic, retain) NSString * scouter;
@property (nonatomic, retain) NSNumber * teamNumber;
@property (nonatomic, retain) NSNumber * teleOpBlocks;
@property (nonatomic, retain) NSNumber * teleOpHigh;
@property (nonatomic, retain) NSNumber * teleOpHighMiss;
@property (nonatomic, retain) NSNumber * teleOpLow;
@property (nonatomic, retain) NSNumber * teleOpLowMiss;
@property (nonatomic, retain) NSNumber * teleOpMissed;
@property (nonatomic, retain) NSNumber * teleOpShotsMade;
@property (nonatomic, retain) NSNumber * totalAutonShots;
@property (nonatomic, retain) NSNumber * totalPasses;
@property (nonatomic, retain) NSNumber * totalTeleOpShots;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSNumber * trussCatch;
@property (nonatomic, retain) NSNumber * trussCatchHuman;
@property (nonatomic, retain) NSNumber * trussCatchHumanMiss;
@property (nonatomic, retain) NSNumber * trussCatchMiss;
@property (nonatomic, retain) NSNumber * trussThrow;
@property (nonatomic, retain) NSNumber * trussThrowMiss;
@property (nonatomic, retain) FieldDrawing *fieldDrawing;
@property (nonatomic, retain) MatchData *match;

@end
