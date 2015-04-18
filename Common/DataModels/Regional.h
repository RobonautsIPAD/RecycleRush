//
//  Regional.h
//  RecycleRush
//
//  Created by FRC on 4/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData;

@interface Regional : NSManagedObject

@property (nonatomic, retain) NSString * awards;
@property (nonatomic, retain) NSNumber * ccwm;
@property (nonatomic, retain) NSString * eliminated;
@property (nonatomic, retain) NSString * eliminationRecord;
@property (nonatomic, retain) NSString * finishPosition;
@property (nonatomic, retain) NSNumber * opr;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * reg1;
@property (nonatomic, retain) NSNumber * reg2;
@property (nonatomic, retain) NSNumber * reg3;
@property (nonatomic, retain) NSNumber * reg4;
@property (nonatomic, retain) NSString * reg5;
@property (nonatomic, retain) NSString * reg6;
@property (nonatomic, retain) NSString * seedingRecord;
@property (nonatomic, retain) NSString * finalRank;
@property (nonatomic, retain) NSString * alliance;
@property (nonatomic, retain) NSNumber * averageScore;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSNumber * eventNumber;
@property (nonatomic, retain) TeamData *team;

@end
