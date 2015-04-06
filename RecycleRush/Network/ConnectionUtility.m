//
//  ConnectionUtility.m
//  RecycleRush
//
//  Created by FRC on 1/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "ConnectionUtility.h"
#import "Packet.h"
#import "DataSync.h"
#import "TeamUtilities.h"
#import "MatchUtilities.h"
#import "ScoreUtilities.h"
#import "SyncMethods.h"

@implementation ConnectionUtility {
    int sendPacketNumber;
    DataSync *dataSyncPackage;
    TeamUtilities *teamUtilities;
    MatchUtilities *matchUtilities;
    ScoreUtilities *scoreUtilities;
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
        teamUtilities = [[TeamUtilities alloc] init:_dataManager];
        matchUtilities = [[MatchUtilities alloc] init:_dataManager];
        scoreUtilities = [[ScoreUtilities alloc] init:_dataManager];
    }
	return self;
}
/*-(void)setSendList {
 if (_syncType == SyncTeams) {
 filteredSendList = [dataSyncPackage getFilteredTeamList:_syncOption];
 }
 else if (_syncType == SyncMatchList) {
 filteredSendList = [dataSyncPackage getFilteredMatchList:_syncOption];
 }
 else if (_syncType == SyncMatchResults) {
 filteredSendList = [dataSyncPackage getFilteredResultsList:_syncOption];
 }
 else if (_syncType == SyncTournaments) {
 filteredSendList = [dataSyncPackage getFilteredTournamentList:_syncOption];
 }
 }*/
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peerID inSession:(GKSession *)session context:(void *)context
{
#ifdef DEBUG
	//NSLog(@"Game: receive data from peer: %@, data: %@, length: %d", peerID, data, [data length]);
#endif
    // NSLog(@"Receiving");
    Packet *packet = [self unarchiveData:data];
    //NSLog(@"dataDictionary = %@", packet.dataDictionary);
//    NSString *myType = (NSString*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //NSLog(@"%@, %@", peerID, [session displayNameForPeer:peerID]);

     if (packet == nil) {
         NSLog(@"Invalid packet: %@", data);
         return;
     }

    switch (packet.packetType) {
		case PacketTypeQuickRequest:
            [self sendQuickResponse:peerID forRequest:packet inSession:session];
			break;
        case PacketTypeSendData:
            [self decodeSendData:packet];
            break;
        case PacketTypeTeamData:
        case PacketTypeMatchData:
        case PacketTypeScoreData:
            [self decodeReceivedData:packet];
            break;
        default:
            break;
    }
}

- (void)sendQuickResponse:(NSString *)requesterID forRequest:(Packet *)requesterPacket inSession:(GKSession *)session {
    NSDictionary *dataDictionary = requesterPacket.dataDictionary;
    NSNumber *matchType = [dataDictionary objectForKey:@"MatchType"];
    NSNumber *matchRequest = [dataDictionary objectForKey:@"MatchRequest"];
    NSNumber *oneMatch = [dataDictionary objectForKey:@"OneMatch"];
    if (!dataSyncPackage) dataSyncPackage = [[DataSync alloc] init:_dataManager];
    NSArray *filteredList = [dataSyncPackage getQuickRequestList:matchType forMatchNumber:matchRequest forOneMatch:[oneMatch boolValue]];
    NSUInteger nRecords = 0;
    if (filteredList) nRecords = [filteredList count];
    Packet *packet = [Packet packetWithType:PacketTypeSendData];
    [packet setDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:nRecords], @"Records", nil]];
    [self sendPacketToClient:packet forClient:requesterID inSession:session];
    //NSLog(@"Quick Records = %lu", (long int)nRecords);
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    Packet *responsePacket;
    for (id item in filteredList) {
        NSString *dataType = NSStringFromClass([item class]);
        if ([dataType isEqualToString:@"TeamData"]) {
            NSDictionary *teamDictionary = [teamUtilities packageTeamForXFer:(TeamData *)item];
            responsePacket = [Packet packetWithType:PacketTypeTeamData];
            [responsePacket setDataDictionary:teamDictionary];
            //NSLog(@"Team dictionary = %@", teamDictionary);
        }
        else if ([dataType isEqualToString:@"TeamScore"]) {
            NSDictionary *scoreDictionary = [scoreUtilities packageScoreForXFer:(TeamScore *)item];
            responsePacket = [Packet packetWithType:PacketTypeScoreData];
            [responsePacket setDataDictionary:scoreDictionary];
            //NSLog(@"Score dictionary = %@", scoreDictionary);
        }
        else {
            responsePacket = [Packet packetWithType:PacketTypeScoreData];
            [responsePacket setDataDictionary:nil];
        }
        [self sendPacketToClient:responsePacket forClient:requesterID inSession:session];
    }
    });

    // Send async
}

-(NSData *)archiveData:(Packet *)packet {
    [packet setHeader:@"Robonauts"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:packet];
	return data;
}

-(Packet *)unarchiveData:(NSData *)data {
    Packet *packet = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return packet;
}

-(void)sendPacketToClient:(Packet *)packet forClient:(NSString *)receiverID inSession:(GKSession *)session {
    if (packet.packetNumber != -1)
		packet.packetNumber = sendPacketNumber++;
 
	GKSendDataMode dataMode = GKSendDataReliable;
    //NSLog(@"Receiver = %@", receiverID);
    [packet setReceiverId:receiverID];
    [packet setSenderId:session.peerID];
	NSData *data = [self archiveData:packet];
	NSError *error;
	if (![session sendData:data toPeers:[NSArray arrayWithObject:receiverID] withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to clients: %@", error);
	}
}

-(void)sendPacketToAllClients:(Packet *)packet inSession:(GKSession *)session {
    if (packet.packetNumber != -1)
		packet.packetNumber = sendPacketNumber++;
 
	GKSendDataMode dataMode = GKSendDataReliable;
    [packet setSenderId:session.peerID];
	NSData *data = [self archiveData:packet];
	NSError *error;

	if (![session sendDataToAllPeers:data withDataMode:dataMode error:&error])
	{
		NSLog(@"Error sending data to clients: %@", error);
	}
}

-(void)decodeSendData:(Packet *)packet {
    //NSLog(@"wheeee received data");
    //NSLog(@"decode from %@", packet.receiverId);
    NSDictionary *dataDictionary = packet.dataDictionary;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"StartReceivingData" object:nil userInfo:dataDictionary]];
}

-(void)decodeReceivedData:(Packet *)packet {
    //NSLog(@"wheeee received data");
    //NSLog(@"decode type %d", packet.packetType);
    NSDictionary *dataDictionary = packet.dataDictionary;
    if (!dataDictionary) {
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Empty Packet Received", @"Error", nil];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedData" object:nil userInfo:errorDictionary]];
        return;
    }
    if (packet.packetType == PacketTypeTeamData) {
        NSDictionary *teamDictionary = [teamUtilities unpackageTeamForXFer:dataDictionary];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedData" object:nil userInfo:teamDictionary]];
    }
    else if (packet.packetType == PacketTypeMatchData) {
        NSDictionary *matchDictionary = [matchUtilities unpackageMatchForXFer:dataDictionary];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedData" object:nil userInfo:matchDictionary]];
    }
    else if (packet.packetType == PacketTypeScoreData) {
        NSDictionary *scoreDictionary = [scoreUtilities unpackageScoreForXFer:dataDictionary];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedData" object:nil userInfo:scoreDictionary]];
    }
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
/*
-(void)checkConnectionStatus {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    BOOL autonConnectMode = [[prefs objectForKey:@"autoConnect"] boolValue];
    if (!autonConnectMode) return;
    
    NSNumber *bluetoothMode = [prefs objectForKey:@"bluetooth"];
    if ([bluetoothMode intValue] == Scouter) {
        if ([_matchMakingClient getClientState] == ClientStateSearchingForServers) {
        }
    }
}*/

-(void)autoConnect {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    BOOL autonConnectMode = [[prefs objectForKey:@"autoConnect"] boolValue];
    if (!autonConnectMode) return;
    
    NSNumber *bluetoothMode = [prefs objectForKey:@"bluetooth"];
    if ([bluetoothMode intValue] == Scouter) {
        if ([_matchMakingClient getClientState] == ClientStateIdle) {
            // Set the notification to receive information after a client had connected or disconnected
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClientStatus:) name:@"clientStatusChanged" object:nil];
            // Set the notification to receive information after the server changes status
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateServerStatus:) name:@"serverStatusChanged" object:nil];
            _matchMakingClient = [self setMatchMakingClient];
            [_matchMakingClient startSearchingForServersWithSessionID:SESSION_ID];
            [_matchMakingClient.session setDataReceiveHandler:self withContext:nil];
        }
    }
    else {
        if ([_matchMakingServer getServerState] == ServerStateIdle) {
            _matchMakingServer = [self setMatchMakingServer];
            [_matchMakingServer startAcceptingConnectionsForSessionID:SESSION_ID];
            [_matchMakingServer.session setDataReceiveHandler:self withContext:nil];
        }
    }
}

-(void)updateClientStatus:(NSNotification *)notification {
    if ([_matchMakingClient getClientState] == ClientStateConnected) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

-(void)updateServerStatus:(NSNotification *)notification {
    // check if available server is the one we want
    NSDictionary *dictionary = [notification userInfo];
    NSString *connectToServer = nil;
    if ([[dictionary objectForKey:@"status"] intValue] == ServerAvailable) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *serverName = [prefs objectForKey:@"serverName"];
        NSUInteger serverCount = [_matchMakingClient availableServerCount];
        for (int i=0; i<serverCount; i++) {
            NSString *serverID = [_matchMakingClient peerIDForAvailableServerAtIndex:i];
            if ([serverName isEqualToString:[_matchMakingClient displayNameForPeerID:serverID]]) {
                connectToServer = serverID;
                break;
            }
        }
        if (connectToServer) {
            [_matchMakingClient connectToServerWithPeerID:connectToServer];
        }
    }
}

-(void)disconnectOnResign {
    if (_matchMakingServer) {
        [_matchMakingServer endSession];
        _matchMakingServer = nil;
    }
    if (_matchMakingClient) {
        [_matchMakingClient disconnectFromServer];
        _matchMakingClient = nil;
    }
}
/*    switch ([_connectionUtility.matchMakingClient getClientState]) {
 case ClientStateIdle:
 _connectionUtility.matchMakingClient = [_connectionUtility setMatchMakingClient];
 [_connectionUtility.matchMakingClient startSearchingForServersWithSessionID:SESSION_ID];
 session = _connectionUtility.matchMakingClient.session;
 [session setDataReceiveHandler:_connectionUtility withContext:nil];
 break;
 
*/
@end
