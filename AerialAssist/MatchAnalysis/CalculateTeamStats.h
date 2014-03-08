//
//  CalculateTeamStats.h
// Robonauts Scouting
//
//  Created by FRC on 3/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeamData;
@class DataManager;

@interface CalculateTeamStats : NSObject
@property (nonatomic, strong) DataManager *dataManager;
- (id)initWithDataManager:(DataManager *)initManager;
-(NSMutableDictionary *)calculateMasonStats:(TeamData *)team forTournament:(NSString *)tournament;

@end
