//
//  TeamScoreInterfaces.h
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;
@class TeamScore;

@interface TeamScoreInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(void)addTeamToMatch:(MatchData *)match forTeam:(NSNumber *)teamNumber forAlliance:(NSString *)alliance;
-(NSData *)packageMatchForXFer:(TeamScore *)score;
-(TeamScore *)unpackageMatchForXFer:(NSData *)xferData;

@end
