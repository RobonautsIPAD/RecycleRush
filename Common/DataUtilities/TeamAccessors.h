//
//  TeamAccessors.h
//  AerialAssist
//
//  Created by FRC on 11/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TeamData;

@interface TeamAccessors : NSObject
+(TeamData *)getTeam:(NSNumber *)teamNumber fromDataManager:(DataManager *)dataManager;
+(TeamData *)getTeam:(NSNumber *)teamNumber inTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext error:(NSError **)error;

@end
