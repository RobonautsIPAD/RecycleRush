//
//  MatchmakingServer.m
//  Snap
//
//  Created by Ray Wenderlich on 5/24/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "MatchmakingServer.h"
#define DEBUG 1

@implementation MatchmakingServer
{
	NSMutableArray *_connectedClients;
    ServerState _serverState;
}

@synthesize maxClients = _maxClients;
@synthesize session = _session;

- (id)init
{
	if ((self = [super init]))
	{
		_serverState = ServerStateIdle;
	}
	return self;
}

-(ServerState)getServerState {
    return _serverState;
}

- (void)startAcceptingConnectionsForSessionID:(NSString *)sessionID
{
    if (_serverState == ServerStateIdle)
	{
		_serverState = ServerStateAcceptingConnections;
        _connectedClients = [NSMutableArray arrayWithCapacity:self.maxClients];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeServer];
        _session.delegate = self;
        _session.available = YES;
    }
}

- (NSArray *)connectedClients
{
	return _connectedClients;
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: peer %@ changed state %d", peerID, state);
#endif
    
	switch (state)
	{
		case GKPeerStateAvailable:
            NSLog(@"GKPeerStateAvailable");
			break;
            
		case GKPeerStateUnavailable:
            NSLog(@"GKPeerStateUnavailable");
			break;
            
            // A new client has connected to the server.
		case GKPeerStateConnected:
			if (_serverState == ServerStateAcceptingConnections)
			{
				if (![_connectedClients containsObject:peerID])
				{
					[_connectedClients addObject:peerID];
					[self clientDidConnect:peerID];
				}
			}
			break;
            
            // A client has disconnected from the server.
		case GKPeerStateDisconnected:
			if (_serverState != ServerStateIdle)
			{
				if ([_connectedClients containsObject:peerID])
				{
					[_connectedClients removeObject:peerID];
					[self clientDidDisconnect:peerID];
				}
			}
			break;
            
		case GKPeerStateConnecting:
            NSLog(@"GKPeerStateConnecting");
			break;
	}
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: connection request from peer %@", peerID);
#endif
    
	if (_serverState == ServerStateAcceptingConnections && [self connectedClientCount] < self.maxClients)
	{
		NSError *error;
		if ([session acceptConnectionFromPeer:peerID error:&error])
			NSLog(@"MatchmakingServer: Connection accepted from peer %@", peerID);
		else
			NSLog(@"MatchmakingServer: Error accepting connection from peer %@, %@", peerID, error);
	}
	else  // not accepting connections or too many clients
	{
		[session denyConnectionFromPeer:peerID];
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: connection with peer %@ failed %@", peerID, error);
#endif
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingServer: session failed %@", error);
#endif
    
	if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serverStatusChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:ServerUnavailable] forKey:SESSION_ID]]];
			[self endSession];
		}
	}
}

- (NSUInteger)connectedClientCount
{
    if (_connectedClients) return [_connectedClients count];
	else return 0;
}

- (NSString *)peerIDForConnectedClientAtIndex:(NSUInteger)index
{
	return [_connectedClients objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
	return [_session displayNameForPeer:peerID];
}

- (void)stopAcceptingConnections
{
	NSAssert(_serverState == ServerStateAcceptingConnections, @"Wrong state");
    
	_serverState = ServerStateIgnoringNewConnections;
	_session.available = NO;
}

-(void)clientDidDisconnect:(NSString *)peerID {
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:ClientDisconnect], @"Message", [self displayNameForPeerID:peerID], @"PeerID", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"clientStatusChanged" object:nil userInfo:userDict]];
}

-(void)clientDidConnect:(NSString *)peerID {
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:ClientConnect], @"Message", [self displayNameForPeerID:peerID], @"PeerID", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"clientStatusChanged" object:nil userInfo:userDict]];
    //	NSString *peerID = [_matchmakingServer peerIDForConnectedClientAtIndex:indexPath.row];

}

- (void)endSession
{
	NSAssert(_serverState != ServerStateIdle, @"Wrong state");
    
	_serverState = ServerStateIdle;
    
	[_session disconnectFromAllPeers];
	_session.available = NO;
	_session.delegate = nil;
	_session = nil;
    
	_connectedClients = nil;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serverStatusChanged" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:ServerUnavailable] forKey:SESSION_ID]]];
}

@end
