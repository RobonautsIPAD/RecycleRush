//
//  TeamAccessors.h
//  RecycleRush
//
//  Created by FRC on 11/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TeamData;

@interface TeamAccessors : NSObject
+(TeamData *)getTeam:(NSNumber *)teamNumber fromDataManager:(DataManager *)dataManager;
+(TeamData *)getTeam:(NSNumber *)teamNumber inTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager;
+(NSArray *)getTeamsInTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager;
+(NSArray *)getTeamDataForTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager;

@end
