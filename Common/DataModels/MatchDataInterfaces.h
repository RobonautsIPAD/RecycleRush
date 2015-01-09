//
//  MatchDataInterfaces.h
//  RecycleRush
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class DataManager;
@class MatchData;

@interface MatchDataInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSDictionary *matchDataAttributes;

-(id)initWithDataManager:(DataManager *)initManager;
-(NSDictionary *)unpackageMatchForXFer:(NSData *)xferData;
-(MatchData *)updateMatch:(NSDictionary *)matchInfo;
-(MatchData *)getMatch:(NSNumber *)matchNumber forMatchType:(NSString *) type forTournament:(NSString *) tournament;
@end
