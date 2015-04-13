//
//  TeamData.h
//  RecycleRush
//
//  Created by FRC on 4/11/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Competitions, Regional;

@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSString * autonMobility;
@property (nonatomic, retain) NSString * bumpers;
@property (nonatomic, retain) NSNumber * canDom;
@property (nonatomic, retain) NSString * canIntake;
@property (nonatomic, retain) NSNumber * cims;
@property (nonatomic, retain) NSString * driveTrainType;
@property (nonatomic, retain) NSNumber * fthing1;
@property (nonatomic, retain) NSNumber * fthing2;
@property (nonatomic, retain) NSNumber * fthing3;
@property (nonatomic, retain) NSNumber * fthing4;
@property (nonatomic, retain) NSNumber * fthing5;
@property (nonatomic, retain) NSString * language;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * liftType;
@property (nonatomic, retain) NSNumber * maxCanHeight;
@property (nonatomic, retain) NSNumber * maxHeight;
@property (nonatomic, retain) NSNumber * maxToteStack;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * noodler;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * nwheels;
@property (nonatomic, retain) NSString * primePhoto;
@property (nonatomic, retain) NSNumber * projectBane;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * savedBy;
@property (nonatomic, retain) NSString * stackMechanism;
@property (nonatomic, retain) NSString * sthing1;
@property (nonatomic, retain) NSString * sthing3;
@property (nonatomic, retain) NSString * sthing4;
@property (nonatomic, retain) NSString * sthing5;
@property (nonatomic, retain) NSString * sting2;
@property (nonatomic, retain) NSNumber * thing1;
@property (nonatomic, retain) NSNumber * thing2;
@property (nonatomic, retain) NSNumber * thing3;
@property (nonatomic, retain) NSNumber * thing4;
@property (nonatomic, retain) NSNumber * thing5;
@property (nonatomic, retain) NSString * toteIntake;
@property (nonatomic, retain) NSString * visionTracker;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSNumber * wheelDiameter;
@property (nonatomic, retain) NSString * wheelType;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * typeOfBane;
@property (nonatomic, retain) NSString * numberOfCans;
@property (nonatomic, retain) NSSet *regional;
@property (nonatomic, retain) NSSet *tournaments;
@end

@interface TeamData (CoreDataGeneratedAccessors)

- (void)addRegionalObject:(Regional *)value;
- (void)removeRegionalObject:(Regional *)value;
- (void)addRegional:(NSSet *)values;
- (void)removeRegional:(NSSet *)values;

- (void)addTournamentsObject:(Competitions *)value;
- (void)removeTournamentsObject:(Competitions *)value;
- (void)addTournaments:(NSSet *)values;
- (void)removeTournaments:(NSSet *)values;

@end
