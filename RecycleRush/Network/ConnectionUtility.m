//
//  ConnectionUtility.m
//  RecycleRush
//
//  Created by FRC on 1/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "ConnectionUtility.h"
#import "Packet.h"

@implementation ConnectionUtility {
    int sendPacketNumber;
}


- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
#ifdef DEBUG
	//NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
#endif
    NSLog(@"Receiving");
    NSString *myType = (NSString*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"%@", myType);
    if (myType) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Receive"
                                                          message:myType
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
    /*	Packet *packet = [Packet packetWithData:data];
     if (packet == nil)
     {
     NSLog(@"Invalid packet: %@", data);
     return;
     }
     
     Player *player = [self playerWithPeerID:peerID];
     if (player != nil)
     {
     if (packet.packetNumber != -1 && packet.packetNumber <= player.lastPacketNumberReceived)
     {
     NSLog(@"Out-of-order packet!");
     return;
     }
     
     player.lastPacketNumberReceived = packet.packetNumber;
     player.receivedResponse = YES;
     }
     
     if (self.isServer)
     [self serverReceivedPacket:packet fromPlayer:player];
     else
     [self clientReceivedPacket:packet];*/
}

-(void)sendPacketToAllClients:(Packet *)packet {
    if (packet.packetNumber != -1)
		packet.packetNumber = sendPacketNumber++;
    
	GKSendDataMode dataMode = GKSendDataReliable;
	NSData *data = [packet data];
	NSError *error;
/*
    [_players enumerateKeysAndObjectsUsingBlock:^(id key, Player *obj, BOOL *stop)
     {
         obj.receivedResponse = [_session.peerID isEqualToString:obj.peerID];
     }];
    
	if (![_session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to clients: %@", error);
	}*/
}

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
