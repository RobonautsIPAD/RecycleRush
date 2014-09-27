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

@interface DataConvenienceMethods : NSObject
+(TournamentData *)getTournament:(NSString *)name fromContext:(NSManagedObjectContext *)managedObjectContext;
+(TeamData *)getTeam:(NSNumber *)teamNumber fromContext:(NSManagedObjectContext *)managedObjectContext;
+(NSDictionary *)findKey:(NSString *)name forAttributes:(NSArray *)attributeNames forDictionary:(NSArray *)dataDictionary;
+(BOOL)setAttributeValue:record forValue:data forAttribute:description forEnumDictionary:enumDictionary;
+(NSString *)outputCSVValue:data forAttribute:attribute;

@end
