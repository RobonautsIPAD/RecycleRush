//
//  TeamDataInterfaces.h
// Robonauts Scouting
//
//  Created by FRC on 5/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class DataManager;
@class TeamData;
@class Regional;
@class Photo;

@interface TeamDataInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSDictionary *teamDataAttributes;
@property (nonatomic, strong) NSDictionary *teamDataProperties;
@property (nonatomic, strong) NSMutableDictionary *regionalDictionary;

-(id)initWithDataManager:(DataManager *)initManager;
-(void)setAttributeValue:record forValue:data forAttribute:(id) attribute;
-(AddRecordResults)addTeamHistoryFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(void)setRegionalValue:(Regional *)regional forHeader:(NSString *)header withValue:(NSString *)data withProperties:(NSDictionary *)properties;
-(TeamData *)getTeam:(NSNumber *)teamNumber;
-(NSArray *)getTeamListTournament:(NSString *)tournament;
-(Regional *)getRegionalRecord:(TeamData *)team forWeek:(NSNumber *)week;
-(id)checkAlternateKeys:(NSDictionary *)keyList forEntry:header;
-(void)addTournamentToTeam:(TeamData *)team forTournament:(NSString *)tournamentName;

#ifdef TEST_MODE
-(void)testTeamInterfaces;
#endif

@end
