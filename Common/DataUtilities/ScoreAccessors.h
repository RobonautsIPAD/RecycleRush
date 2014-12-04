//
//  ScoreAccessors.h
//  AerialAssist
//
//  Created by FRC on 11/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TeamScore;

@interface ScoreAccessors : NSObject
+(TeamScore *)getScoreRecord:(NSNumber *)matchNumber forType:(NSNumber *)matchType forAlliance:(NSNumber *)alliance forTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager;


@end
