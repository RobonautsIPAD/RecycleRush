//
//  DataConvenienceMethods.h
//  AerialAssist
//
//  Created by FRC on 7/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TournamentData;
@class TeamData;
@class MatchData;
@class TeamScore;

@interface DataConvenienceMethods : NSObject
+(TournamentData *)getTournament:(NSString *)name fromContext:(NSManagedObjectContext *)managedObjectContext;

+(TeamData *)getTeam:(NSNumber *)teamNumber fromContext:(NSManagedObjectContext *)managedObjectContext;
+(TeamData *)getTeamInTournament:(NSNumber *)teamNumber forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext;
+(NSArray *)getTournamentTeamList:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext;

+(MatchData *)getMatch:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext;

+(NSArray *)getMatchListForTeam:(NSNumber *)teamNumber forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext;

+(NSArray *)getMatchScores:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext;
+(TeamScore *)getScoreRecord:(NSNumber *)matchNumber forType:(NSNumber *)matchType forAlliance:(NSNumber *)alliance forTournament:(NSString *)tournament fromContext:(NSManagedObjectContext *)managedObjectContext;



+(NSDictionary *)findKey:(NSString *)name forAttributes:(NSArray *)attributeNames forDictionary:(NSArray *)dataDictionary;
+(BOOL)setAttributeValue:record forValue:data forAttribute:description forEnumDictionary:enumDictionary;
+(BOOL)compareAttributeToDefault:(id)value forAttribute:attribute;

+(NSString *)outputCSVValue:data forAttribute:attribute forEnumDictionary:enumDictionary;

+(NSString *)getTableFormat:(NSDictionary *)data forField:(NSDictionary *)formatData;

@end
