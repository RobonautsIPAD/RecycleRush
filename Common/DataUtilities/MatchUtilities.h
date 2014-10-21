//
//  MatchUtilities.h
//  AerialAssist
//
//  Created by FRC on 9/30/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;

@interface MatchUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(void)createMatchFromFile:(NSString *)filePath;
-(MatchData *)addMatch:(NSNumber *)matchNumber forMatchType:(NSNumber *)matchType forTournament:(NSString *)tournamentName;
-(NSNumber *)getTeamFromList:(NSArray *)teamList forAllianceStation:(NSNumber *)allianceStation;

@end
