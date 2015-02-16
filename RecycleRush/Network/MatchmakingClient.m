//
//  MatchmakingClient.m
//  Snap
//
//  Created by Ray Wenderlich on 5/25/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "MatchmakingClient.h"

@implementation MatchmakingClient
{
	NSMutableArray *_availableServers;
    ClientState _clientState;
    NSString *_serverPeerID;
}

@synthesize session = _session;
@synthesize delegate = _delegate;

- (id)init
{
	if ((self = [super init]))
	{
		_clientState = ClientStateIdle;
	}
	return self;
}

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID
{
	if (_clientState == ClientStateIdle)
	{
		_clientState = ClientStateSearchingForServers;
		_availableServers = [NSMutableArray arrayWithCapacity:10];
        
        _session = [[GKSession alloc] initWithSessionID:sessionID displayName:nil sessionMode:GKSessionModeClient];
        _session.delegate = self;
        _session.available = YES;
        NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:ClientStateSearchingForServers], @"Message", nil];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"clientStatusChanged" object:nil userInfo:userDict]];
	}
}

- (NSArray *)availableServers
{
	return _availableServers;
}

- (void)connectToServerWithPeerID:(NSString *)peerID
{
	NSAssert(_clientState == ClientStateSearchingForServers, @"Wrong state");
    
	_clientState = ClientStateConnecting;
	_serverPeerID = peerID;
	[_session connectToPeer:peerID withTimeout:_session.disconnectTimeout];
}

#pragma mark - GKSessionDelegate

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
#ifdef DEBUG
	NSLog(@"MatchmakingClient: peer %@ changed state %d", peerID, state);
#endif
    
	switch (state)
	{
            // The client has discovered a new server.
		case GKPeerStateAvailable:
			if (_clientState == ClientStateSearchingForServers)
			{		
				if (![_availableServers containsObject:peerID])
				{
					[_availableServers addObject:peerID];
					[self serverBecameAvailable:peerID];
				}
			}
			break;
            
            // The client sees that a server goes away.
		case GKPeerStateUnavailable:
			if (_clientState == ClientStateSearchingForServers)
			{
				if ([_availableServers containsObject:peerID])
				{
					[_availableServers removeObject:peerID];
					[self serverBecameUnavailable:peerID];
				}
			}
            // Is this the server we're currently trying to connect with?
			if (_clientState == ClientStateConnecting && [peerID isEqualToString:_serverPeerID])
			{
				[self disconnectFromServer];
			}
			break;
            
            // You're now connected to the server.
        case GKPeerStateConnected:
			if (_clientState == ClientStateConnecting)
			{
				_clientState = ClientStateConnected;
				[self didConnectToServer:peerID];
			}
			break;
            
            // You're now no longer connected to the server.
		case GKPeerStateDisconnected:
			if (_clientState == ClientStateConnected)
			{
				[self disconnectFromServer];
			}
			break;
            
		case GKPeerStateConnecting:
			break;
	}	
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
#ifdef DEBUG
	NSLog(@"MatchmakingClient: connection request from peer %@", peerID);
#endif
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingClient: connection with peer %@ failed %@", peerID, error);
#endif
    
	[self disconnectFromServer];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
#ifdef DEBUG
	NSLog(@"MatchmakingClient: session failed %@", error);
#endif
    
	if ([[error domain] isEqualToString:GKSessionErrorDomain])
	{
		if ([error code] == GKSessionCannotEnableError)
		{
			[self.delegate matchmakingClientNoNetwork:self];
			[self disconnectFromServer];
		}
	}
}

- (NSUInteger)availableServerCount
{
	return [_availableServers count];
}

-(ClientState)getClientState {
    return _clientState;
}

- (NSString *)peerIDForAvailableServerAtIndex:(NSUInteger)index
{
	return [_availableServers objectAtIndex:index];
}

- (NSString *)displayNameForPeerID:(NSString *)peerID
{
	return [_session displayNameForPeer:peerID];
}

- (void)disconnectFromServer
{
	NSAssert(_clientState != ClientStateIdle, @"Wrong state");
    
	_clientState = ClientStateIdle;
    
	[_session disconnectFromAllPeers];
	_session.available = NO;
	_session.delegate = nil;
	_session = nil;
    
	_availableServers = nil;
    
	[self didDisconnectFromServer:_serverPeerID];
	_serverPeerID = nil;
}

- (void)serverBecameAvailable:(NSString *)peerID
{
    NSLog(@"serverBecameAvailable");
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server became available", @"Message", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serverStatusChanged" object:nil userInfo:userDict]];
}

- (void)serverBecameUnavailable:(NSString *)peerID
{
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Server became unavailable", @"Message", nil];
    NSLog(@"serverBecameUnavailable");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"serverStatusChanged" object:nil userInfo:userDict]];
}

- (void)didDisconnectFromServer:(NSString *)peerID
{
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Disconnected from Server", @"Message", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"clientStatusChanged" object:nil userInfo:userDict]];
}

- (void)didConnectToServer:(NSString *)peerID
{
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Connected to server", @"Message", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"clientStatusChanged" object:nil userInfo:userDict]];
}

- (void)matchmakingClientNoNetwork:(MatchmakingClient *)client
{
    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:@"No network", @"Message", nil];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"clientStatusChanged" object:nil userInfo:userDict]];
}


- (void)dealloc
{
#ifdef DEBUG
	NSLog(@"dealloc %@", self);
#endif
}

@end
