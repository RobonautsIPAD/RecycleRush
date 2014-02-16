//
//  MatchDataInterfaces.h
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;

@interface MatchDataInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(NSString *) exportMatchListToCSV:(BOOL)header forMatch:(MatchData *)match forTournament:(NSString *)tournament;

@end
