//
//  TournamentDataInterfaces.h
//  AerialAssist
//
//  Created by FRC on 1/29/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddRecordResults.h"

@class DataManager;
@class TournamentData;

@interface TournamentDataInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(AddRecordResults)createTournament:(NSMutableArray *)headers dataFields:(NSMutableArray *)data;
-(TournamentData *)getTournament:(NSString *)name;

-(NSData *)packageTournamentsForXFer:(NSMutableArray *)tournamentList;
-(NSArray *)unpackageTournamentsForXFer:(NSData *)xferData;
@end
