//
//  ScoreUtilities.h
//  RecycleRush
//
//  Created by FRC on 10/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;
@class TeamScore;

@interface ScoreUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(NSDictionary *)unpackageScoreForXFer:(NSData *)xferData;
-(NSDictionary *)unpackageScoreForBluetooth:(NSDictionary *)xferData;
-(TeamScore *)addTeamScoreToMatch:(MatchData *)match forAlliance:(NSString *)allianceString forTeam:(NSNumber *)teamNumber error:(NSError **)error;
@end
