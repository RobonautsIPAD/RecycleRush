//
//  ConnectionUtility.m
//  RecycleRush
//
//  Created by FRC on 1/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "ConnectionUtility.h"

@implementation ConnectionUtility
-(MatchmakingServer *)setMatchMakingServer {
    if (_matchMakingServer == nil) {
        _matchMakingServer = [[MatchmakingServer alloc] init];
        _matchMakingServer.maxClients = 7;
//        _matchMakingServer.delegate = self;
    }
    return _matchMakingServer;
}

-(MatchmakingClient *)setMatchMakingClient {
    if (_matchMakingClient == nil) {
        _matchMakingClient = [[MatchmakingClient alloc] init];
//        _matchMakingClient.delegate = self;
    }
    return _matchMakingClient;
}

@end
