//
//  TeamScore.h
//  AerialAssist
//
//  Created by FRC on 2/15/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FieldDrawing, MatchData, TeamData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSNumber * airCatch;
@property (nonatomic, retain) NSNumber * airPasses;
@property (nonatomic, retain) NSString * alliance;
@property (nonatomic, retain) NSNumber * allianceSection;
@property (nonatomic, retain) NSNumber * autonBlocks;
@property (nonatomic, retain) NSNumber * autonHighCold;
@property (nonatomic, retain) NSNumber * autonHighHot;
@property (nonatomic, retain) NSNumber * autonLowHot;
@property (nonatomic, retain) NSNumber * autonLowCold;
@property (nonatomic, retain) NSNumber * autonMissed;
@property (nonatomic, retain) NSNumber * autonMobility;
@property (nonatomic, retain) NSNumber * autonShotsMade;
@property (nonatomic, retain) NSNumber * defenseBlockRating;
@property (nonatomic, retain) NSNumber * defenseBullyRating;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSNumber * floorPasses;
@property (nonatomic, retain) NSNumber * floorPickUp;
@property (nonatomic, retain) NSNumber * humanPickUp;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * otherRating;
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
@property (nonatomic, retain) NSNumber * teleOpBlocks;
@property (nonatomic, retain) NSNumber * teleOpHigh;
@property (nonatomic, retain) NSNumber * teleOpLow;
@property (nonatomic, retain) NSNumber * teleOpMissed;
@property (nonatomic, retain) NSNumber * teleOpShots;
@property (nonatomic, retain) NSNumber * totalAutonShots;
@property (nonatomic, retain) NSNumber * totalTeleOpShots;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSNumber * trussCatch;
@property (nonatomic, retain) NSNumber * trussThrow;
@property (nonatomic, retain) NSNumber * wallPickUp;
@property (nonatomic, retain) NSNumber * wallPickUp1;
@property (nonatomic, retain) NSNumber * wallPickUp2;
@property (nonatomic, retain) NSNumber * wallPickUp3;
@property (nonatomic, retain) NSNumber * wallPickUp4;
@property (nonatomic, retain) FieldDrawing *fieldDrawing;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) TeamData *team;

@end
