//
//  SharedSyncController.h
//  AerialAssist
//
//  Created by FRC on 4/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class DataManager;

@interface SharedSyncController : NSObject <GKSessionDelegate, GKPeerPickerControllerDelegate>

@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(NSArray *)fetchTournamentList:(SyncType)syncOption;
-(NSArray *)fetchTeamList:(SyncType)syncOption;
-(NSArray *)fetchMatchList:(SyncType)syncOption;
-(NSArray *)fetchResultsList:(SyncType)syncOption;

- (void) mySendDataToPeers:(NSData *)data type:(SyncType)syncType withSession:(GKSession *)currentSession;
-(IBAction) createDataPackage:(SyncType)syncType withSession:(GKSession *)currentSession;

@end
