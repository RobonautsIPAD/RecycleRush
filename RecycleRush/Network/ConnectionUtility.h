//
//  ConnectionUtility.h
//  RecycleRush
//
//  Created by FRC on 1/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatchmakingServer.h"
#import "MatchmakingClient.h"

@class Packet;
@class DataManager;
@interface ConnectionUtility : NSObject
@property (nonatomic, strong) DataManager *dataManager;
@property (readonly, strong, nonatomic) MatchmakingServer *matchMakingServer;
@property (readonly, strong, nonatomic) MatchmakingClient *matchMakingClient;
//@property (assign, nonatomic) QuitReason quitReason;
-(id)init:(DataManager *)initManager;
-(MatchmakingServer *)setMatchMakingServer;
-(MatchmakingClient *)setMatchMakingClient;
-(void)sendPacketToAllClients:(Packet *)packet inSession:(GKSession *)session;
-(void)sendPacketToClient:(Packet *)packet forClient:(NSString *)receiverID inSession:(GKSession *)session;

@end
