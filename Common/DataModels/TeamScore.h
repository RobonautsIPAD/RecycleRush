//
//  TeamScore.h
//  RecycleRush
//
//  Created by FRC on 1/30/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FieldDrawing, MatchData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSNumber * allianceStation;
@property (nonatomic, retain) NSNumber * assistRating;
@property (nonatomic, retain) NSNumber * autonBlocks;
@property (nonatomic, retain) NSNumber * autonHighCold;
@property (nonatomic, retain) NSNumber * autonHighHot;
@property (nonatomic, retain) NSNumber * autonMobility;
@property (nonatomic, retain) NSNumber * autonShotsMade;
@property (nonatomic, retain) NSNumber * autonTotePickUp;
@property (nonatomic, retain) NSNumber * canIntakeFloor;
@property (nonatomic, retain) NSNumber * cansFromStep;
@property (nonatomic, retain) NSNumber * deadOnArrival;
@property (nonatomic, retain) NSNumber * driverRating;
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
@property (nonatomic, retain) NSNumber * matchNumber;
@property (nonatomic, retain) NSNumber * matchType;
@property (nonatomic, retain) NSNumber * noShow;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * otherRating;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * results;
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
@property (nonatomic, retain) NSNumber * stackKnockdowns;
@property (nonatomic, retain) NSNumber * teamNumber;
@property (nonatomic, retain) NSNumber * totalAutonShots;
@property (nonatomic, retain) NSNumber * totalPasses;
@property (nonatomic, retain) NSNumber * totalTeleOpShots;
@property (nonatomic, retain) NSNumber * toteIntakeFloor;
@property (nonatomic, retain) NSNumber * toteIntakeHP;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) FieldDrawing *fieldDrawing;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) FieldDrawing *autonDrawing;

@end
