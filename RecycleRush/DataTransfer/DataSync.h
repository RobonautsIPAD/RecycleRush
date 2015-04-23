//
//  DataSync.h
//  RecycleRush
//
//  Created by FRC on 11/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SyncMethods.h"

@class DataManager;
@class ConnectionUtility;
@class TeamScore;

@interface DataSync : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(NSArray *)getQuickRequestStatus:(NSNumber *)matchType;
-(NSArray *)getFilteredTournamentList:(SyncOptions)syncOption;
-(NSArray *)getFilteredTeamList:(SyncOptions)syncOption;
-(NSArray *)getFilteredMatchList:(SyncOptions)syncOption;
-(NSArray *)getFilteredResultsList:(SyncOptions)syncOption;
-(NSArray *)getQuickRequestList:(NSNumber *)matchType forMatchNumber:(NSNumber *)matchNumber forOneMatch:(BOOL)oneMatch;
-(TeamScore *)getScoreRecord:(NSNumber *)matchType forMatchNumber:(NSNumber *)matchNumber forAlliance:(NSNumber *)alliance;
-(NSDictionary *)getMatchPhoto:(NSNumber *)matchType forMatchNumber:(NSNumber *)matchNumber forAlliance:(NSNumber *)alliance;
-(NSArray *)getImportFileList;
-(BOOL)packageDataForiTunes:(SyncType)syncType forData:(NSArray *)transferList error:(NSError **)error;
-(NSArray *)importiTunesSelected:(NSString *)importFile error:(NSError **)error;
-(void)bluetoothDataTranfer:(NSArray *)records toPeers:(NSString *)destination forConnection:(ConnectionUtility *)connectionUtility inSession:(GKSession *)session;
@end
