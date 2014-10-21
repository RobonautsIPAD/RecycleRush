//
//  ScoreUtilities.h
//  AerialAssist
//
//  Created by FRC on 10/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;

@interface ScoreUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(NSString *)addTeamScoreToMatch:(MatchData *)match forAlliance:(NSString *)alliance forTeam:(NSNumber *)teamNumber;
@end