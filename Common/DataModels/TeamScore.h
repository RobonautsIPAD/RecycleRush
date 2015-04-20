//
//  TeamScore.h
//  RecycleRush
//
//  Created by FRC on 4/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FieldDrawing, MatchData;

@interface TeamScore : NSManagedObject

@property (nonatomic, retain) NSNumber * allianceScore;
@property (nonatomic, retain) NSNumber * allianceStation;
@property (nonatomic, retain) NSNumber * autonCansFromStep;
@property (nonatomic, retain) NSNumber * autonCansScored;
@property (nonatomic, retain) NSNumber * autonRobotSet;
@property (nonatomic, retain) NSNumber * autonToteSet;
@property (nonatomic, retain) NSNumber * autonToteStack;
@property (nonatomic, retain) NSNumber * blacklist;
@property (nonatomic, retain) NSNumber * blacklistDriver;
@property (nonatomic, retain) NSNumber * blacklistHP;
@property (nonatomic, retain) NSNumber * blacklistRobot;
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
@property (nonatomic, retain) NSNumber * coop10;
@property (nonatomic, retain) NSNumber * coop13;
@property (nonatomic, retain) NSNumber * coop20;
@property (nonatomic, retain) NSNumber * coop22;
@property (nonatomic, retain) NSNumber * coop30;
@property (nonatomic, retain) NSNumber * coop31;
@property (nonatomic, retain) NSNumber * coopSetDenominator;
@property (nonatomic, retain) NSNumber * coopSetNumerator;
@property (nonatomic, retain) NSNumber * coopSetNY;
@property (nonatomic, retain) NSNumber * coopStackDenominator;
@property (nonatomic, retain) NSNumber * coopStackNumerator;
@property (nonatomic, retain) NSNumber * coopYN;
@property (nonatomic, retain) NSNumber * deadOnArrival;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSString * fieldPhotoName;
@property (nonatomic, retain) NSString * foulNotes;
@property (nonatomic, retain) NSNumber * fouls;
@property (nonatomic, retain) NSNumber * litterHP;
@property (nonatomic, retain) NSNumber * litterInCan;
@property (nonatomic, retain) NSNumber * matchNumber;
@property (nonatomic, retain) NSNumber * matchType;
@property (nonatomic, retain) NSNumber * maxCanHeight;
@property (nonatomic, retain) NSNumber * maxToteHeight;
@property (nonatomic, retain) NSNumber * noShow;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * oppositeZoneLitter;
@property (nonatomic, retain) NSNumber * otherRating;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * redCards;
@property (nonatomic, retain) NSNumber * results;
@property (nonatomic, retain) NSString * robotNotes;
@property (nonatomic, retain) NSNumber * robotSpeed;
@property (nonatomic, retain) NSString * robotType;
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
@property (nonatomic, retain) NSData * stacks;
@property (nonatomic, retain) NSNumber * teamNumber;
@property (nonatomic, retain) NSNumber * totalCansScored;
@property (nonatomic, retain) NSNumber * totalLandfillLitterScored;
@property (nonatomic, retain) NSNumber * totalScore;
@property (nonatomic, retain) NSNumber * totalTotesIntake;
@property (nonatomic, retain) NSNumber * totalTotesScored;
@property (nonatomic, retain) NSNumber * toteIntakeHP;
@property (nonatomic, retain) NSNumber * toteIntakeLandfill;
@property (nonatomic, retain) NSNumber * toteIntakeStep;
@property (nonatomic, retain) NSNumber * totesOn0;
@property (nonatomic, retain) NSNumber * totesOn1;
@property (nonatomic, retain) NSNumber * totesOn2;
@property (nonatomic, retain) NSNumber * totesOn3;
@property (nonatomic, retain) NSNumber * totesOn4;
@property (nonatomic, retain) NSNumber * totesOn5;
@property (nonatomic, retain) NSNumber * totesOn6;
@property (nonatomic, retain) NSString * tournamentName;
@property (nonatomic, retain) NSNumber * wowList;
@property (nonatomic, retain) NSNumber * wowlistDriver;
@property (nonatomic, retain) NSNumber * wowlistHP;
@property (nonatomic, retain) NSNumber * wowlistRobot;
@property (nonatomic, retain) NSNumber * yellowCards;
@property (nonatomic, retain) FieldDrawing *autonDrawing;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) FieldDrawing *teleOpDrawing;

@end
