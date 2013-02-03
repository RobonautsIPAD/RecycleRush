//
//  CreateMatch.h
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class MatchData;
@class TeamScore;
@class TeamData;
@class TournamentData;

@interface CreateMatch : NSObject
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
-(AddRecordResults)createMatchFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(AddRecordResults)addMatchResultsFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(MatchData *)GetMatch:(NSNumber *)matchNumber forMatchType:(NSString *) type;
-(void)CreateMatch:(NSNumber *)number forTeam1:(NSNumber *)red1 
                                      forTeam2:(NSNumber *)red2 
                                      forTeam3:(NSNumber *)red3
                                      forTeam4:(NSNumber *)blue1 
                                      forTeam5:(NSNumber *)blue2 
                                      forTeam6:(NSNumber *)blue3 
                                      forMatch:(NSString *)matchType 
                                      forTournament:(NSString *)tournament
                                      forRedScore:(NSNumber *)redScore
                                      forBlueScore:(NSNumber *)blueScore;
-(TeamScore *)CreateScore:(NSNumber *)teamNumber forAlliance:(NSString *)alliance;
-(TeamData *)GetTeam:(NSNumber *)teamNumber;
-(void)setTeamDefaults:(TeamData *)blankTeam;
-(TournamentData *)getTournamentRecord:(NSString *)tournamentName;

@end
