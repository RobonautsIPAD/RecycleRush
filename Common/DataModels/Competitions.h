//
//  Competitions.h
//  AerialAssist
//
//  Created by FRC on 9/30/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData;

@interface Competitions : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) TeamData *team;

@end
