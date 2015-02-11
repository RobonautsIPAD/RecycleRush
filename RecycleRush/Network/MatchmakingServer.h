//
//  MatchmakingServer.h
//  Snap
//
//  Created by Ray Wenderlich on 5/24/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

@class MatchmakingServer;

@interface MatchmakingServer : NSObject <GKSessionDelegate>

@property (nonatomic, assign) int maxClients;
@property (nonatomic, strong, readonly) NSArray *connectedClients;
@property (nonatomic, strong, readonly) GKSession *session;

- (void)endSession;
- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID;
- (NSUInteger)connectedClientCount;
- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;
- (void)stopAcceptingConnections;
-(ServerState)getServerState;
-(void)sendDataFromServer:(NSString *)stuff;

@end
