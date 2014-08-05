//
//  TournamentUtilities.h
//  AerialAssist
//
//  Created by FRC on 7/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TournamentData;

@interface TournamentUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(void)createTournamentFromFile:(NSString *)filePath;
-(NSData *)packageTournamentsForXFer:(NSArray *)tournamentList;
-(NSDictionary *)unpackageTournamentsForXFer:(NSData *)xferData;
@end
