//
//  TeamData.h
//  AerialAssist
//
//  Created by FRC on 3/9/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Regional, TeamScore, TournamentData;

@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSNumber * autonCapacity;
@property (nonatomic, retain) NSNumber * autonMobility;
@property (nonatomic, retain) NSNumber * ballReleaseHeight;
@property (nonatomic, retain) NSNumber * catcher;
@property (nonatomic, retain) NSNumber * cims;
@property (nonatomic, retain) NSNumber * classA;
@property (nonatomic, retain) NSNumber * classB;
@property (nonatomic, retain) NSNumber * classC;
@property (nonatomic, retain) NSNumber * classD;
@property (nonatomic, retain) NSNumber * classE;
@property (nonatomic, retain) NSNumber * classF;
@property (nonatomic, retain) NSNumber * driveTrainType;
@property (nonatomic, retain) NSNumber * fthing1;
@property (nonatomic, retain) NSNumber * fthing2;
@property (nonatomic, retain) NSNumber * fthing3;
@property (nonatomic, retain) NSNumber * fthing4;
@property (nonatomic, retain) NSNumber * fthing5;
@property (nonatomic, retain) NSNumber * goalie;
@property (nonatomic, retain) NSNumber * hotTracker;
@property (nonatomic, retain) NSNumber * intake;
@property (nonatomic, retain) NSNumber * maxHeight;
@property (nonatomic, retain) NSNumber * minHeight;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * nwheels;
@property (nonatomic, retain) NSString * primePhoto;
@property (nonatomic, retain) NSNumber * received;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSString * savedBy;
@property (nonatomic, retain) NSNumber * shooterType;
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
@property (nonatomic, retain) NSNumber * wheelDiameter;
@property (nonatomic, retain) NSString * wheelType;
@property (nonatomic, retain) NSSet *match;
@property (nonatomic, retain) NSSet *photoList;
@property (nonatomic, retain) NSSet *regional;
@property (nonatomic, retain) NSSet *tournament;
@end

@interface TeamData (CoreDataGeneratedAccessors)

- (void)addMatchObject:(TeamScore *)value;
- (void)removeMatchObject:(TeamScore *)value;
- (void)addMatch:(NSSet *)values;
- (void)removeMatch:(NSSet *)values;

- (void)addPhotoListObject:(Photo *)value;
- (void)removePhotoListObject:(Photo *)value;
- (void)addPhotoList:(NSSet *)values;
- (void)removePhotoList:(NSSet *)values;

- (void)addRegionalObject:(Regional *)value;
- (void)removeRegionalObject:(Regional *)value;
- (void)addRegional:(NSSet *)values;
- (void)removeRegional:(NSSet *)values;

- (void)addTournamentObject:(TournamentData *)value;
- (void)removeTournamentObject:(TournamentData *)value;
- (void)addTournament:(NSSet *)values;
- (void)removeTournament:(NSSet *)values;

@end
