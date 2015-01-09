//
//  TournamentUtilities.h
//  RecycleRush
//
//  Created by FRC on 7/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TournamentData;

@interface TournamentUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)init:(DataManager *)initManager;
-(BOOL)createTournamentFromFile:(NSString *)filePath;
-(NSData *)packageTournamentsForXFer:(NSArray *)tournamentList;
-(NSMutableArray *)unpackageTournamentsForXFer:(NSData *)xferData;
@end
