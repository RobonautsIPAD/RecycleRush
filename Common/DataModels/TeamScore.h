//
//  TeamScore.h
//  RecycleRush
//
//  Created by FRC on 2/16/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FieldDrawing, FieldPhoto, MatchData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSNumber * allianceStation;
@property (nonatomic, retain) NSNumber * autonCanSet;
@property (nonatomic, retain) NSNumber * autonCansStep;
@property (nonatomic, retain) NSNumber * autonRobotSet;
@property (nonatomic, retain) NSNumber * autonTotePickUp;
@property (nonatomic, retain) NSNumber * autonToteSet;
@property (nonatomic, retain) NSNumber * autonToteStack;
@property (nonatomic, retain) NSNumber * blacklist;
@property (nonatomic, retain) NSNumber * canDomination;
@property (nonatomic, retain) NSNumber * canDominationTime;
@property (nonatomic, retain) NSNumber * canIntakeFloor;
@property (nonatomic, retain) NSNumber * cansFromStep;
@property (nonatomic, retain) NSNumber * cansOn0;
@property (nonatomic, retain) NSNumber * cansOn1;
@property (nonatomic, retain) NSNumber * cansOn2;
@property (nonatomic, retain) NSNumber * cansOn3;
@property (nonatomic, retain) NSNumber * cansOn4;
@property (nonatomic, retain) NSNumber * cansOn5;
@property (nonatomic, retain) NSNumber * cansOn6;
@property (nonatomic, retain) NSNumber * coopSet;
@property (nonatomic, retain) NSNumber * coopStack;
@property (nonatomic, retain) NSNumber * deadOnArrival;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSNumber * fouls;
@property (nonatomic, retain) NSNumber * litterHP;
@property (nonatomic, retain) NSNumber * litterHPTop;
@property (nonatomic, retain) NSNumber * litterinCan;
@property (nonatomic, retain) NSNumber * matchNumber;
@property (nonatomic, retain) NSNumber * matchType;
@property (nonatomic, retain) NSNumber * maxCanHeight;
@property (nonatomic, retain) NSNumber * maxToteHeight;
@property (nonatomic, retain) NSNumber * noShow;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * oppositeZoneLitter;
@property (nonatomic, retain) NSNumber * otherRating;
@property (nonatomic, retain) NSString * photo;
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
@property (nonatomic, retain) NSNumber * stackNumber;
@property (nonatomic, retain) NSNumber * teamNumber;
@property (nonatomic, retain) NSNumber * totalCansScored;
@property (nonatomic, retain) NSNumber * totalLandfillLitterScored;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) NSNumber * totalTotesIntake;
@property (nonatomic, retain) NSNumber * totalTotesScored;
@property (nonatomic, retain) NSNumber * toteFloorBottom;
@property (nonatomic, retain) NSNumber * toteFloorTop;
@property (nonatomic, retain) NSNumber * toteHPBottom;
@property (nonatomic, retain) NSNumber * toteHPTop;
@property (nonatomic, retain) NSNumber * toteIntakeBottomFloor;
@property (nonatomic, retain) NSNumber * toteIntakeHP;
@property (nonatomic, retain) NSNumber * toteIntakeStep;
@property (nonatomic, retain) NSNumber * toteIntakeTopFloor;
@property (nonatomic, retain) NSNumber * totesOn0;
@property (nonatomic, retain) NSNumber * totesOn1;
@property (nonatomic, retain) NSNumber * totesOn2;
@property (nonatomic, retain) NSNumber * totesOn3;
@property (nonatomic, retain) NSNumber * totesOn4;
@property (nonatomic, retain) NSNumber * totesOn5;
@property (nonatomic, retain) NSNumber * totesOn6;
@property (nonatomic, retain) NSNumber * toteStepBottom;
@property (nonatomic, retain) NSNumber * toteStepTop;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSNumber * wowList;
@property (nonatomic, retain) FieldDrawing *autonDrawing;
@property (nonatomic, retain) FieldPhoto *field;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) FieldDrawing *teleOpDrawing;

@end
