//
//  MatchAccessors.h
//  AerialAssist
//
//  Created by FRC on 11/22/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class MatchData;

@interface MatchAccessors : NSObject
+(MatchData *)getMatch:(NSNumber *)matchNumber forType:(NSNumber *)matchType forTournament:(NSString *)tournament fromDataManager:(DataManager *)dataManager;


@end
