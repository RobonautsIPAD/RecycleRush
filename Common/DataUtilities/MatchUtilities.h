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
-(BOOL)createMatchFromFile:(NSString *)filePath;
-(MatchData *)addMatch:(NSNumber *)matchNumber forMatchType:(NSString *)matchType forTeams:(NSArray *)teamList forTournament:(NSString *)tournamentName error:(NSError **)error;
-(NSNumber *)getTeamFromList:(NSArray *)teamList forAllianceStation:(NSNumber *)allianceStation;
-(NSDictionary *)unpackageMatchForXFer:(NSData *)xferData;

@end
