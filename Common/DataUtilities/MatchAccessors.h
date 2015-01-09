//
//  MatchAccessors.h
//  RecycleRush
//
//  Created by FRC on 11/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class MatchData;

@interface MatchAccessors : NSObject
+(MatchData *)getMatch:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager;
+(NSArray *)getMatchList:(NSString *)tournament fromDataManager:(DataManager *)dataManager;

+(NSString *)getMatchTypeString:(NSNumber *)matchType fromDictionary:(NSDictionary *)matchTypeDictionary;
+(NSNumber *)getMatchTypeFromString:(NSString *)matchTypeString fromDictionary:(NSDictionary *)matchTypeDictionary;
+(NSString *)getAllianceString:(NSNumber *)allianceStation fromDictionary:(NSDictionary *)allianceDictionary;
+(NSNumber *)getAllianceStation:(NSString *)allianceString fromDictionary:(NSDictionary *)allianceDictionary;
+(NSDictionary *)buildTeamList:(MatchData *)match forAllianceDictionary:allianceDistionary;
+(NSString *)getTeamNumber:(NSArray *)scoreList forAllianceString:(NSString *)allianceString forAllianceDictionary:allianceDictionary ;
@end
