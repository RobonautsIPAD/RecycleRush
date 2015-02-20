//
//  TeamScoreInterfaces.h
//  RecycleRush
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;
@class TeamData;
@class TeamScore;

@interface TeamScoreInterfaces : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(void)addScoreToMatch:(MatchData *)match forTeam:(NSNumber *)teamNumber forAlliance:(NSString *)alliance;
-(void)exportScoreForXFer:(TeamScore *)score toFile:(NSString *)exportFilePath;
-(TeamScore *)addScore:(TeamData *)team forAlliance:(NSString *)alliance forTournament:(NSString *)tournament;

@end
