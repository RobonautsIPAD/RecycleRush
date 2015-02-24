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

@interface DataSync : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
-(NSArray *)getFilteredTournamentList:(SyncOptions)syncOption;
-(NSArray *)getFilteredTeamList:(SyncOptions)syncOption;
-(NSArray *)getFilteredMatchList:(SyncOptions)syncOption;
-(NSArray *)getFilteredResultsList:(SyncOptions)syncOption;
-(NSArray *)getImportFileList;
-(BOOL)packageDataForiTunes:(SyncType)syncType forData:(NSArray *)transferList error:(NSError **)error;
-(NSArray *)importiTunesSelected:(NSString *)importFile error:(NSError **)error;
-(void)bluetoothDataTranfer:(NSArray *)records toPeers:(NSString *)destination forConnection:(ConnectionUtility *)connectionUtility inSession:(GKSession *)session;
@end
