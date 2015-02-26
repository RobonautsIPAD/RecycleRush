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
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"

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
    NSLog(@"Receiving");
    Packet *packet = [self unarchiveData:data];
    NSLog(@"dataDictionary = %@", packet.dataDictionary);
//    NSString *myType = (NSString*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"%@, %@", peerID, [session displayNameForPeer:peerID]);

     if (packet == nil) {
         NSLog(@"Invalid packet: %@", data);
         return;
     }

    switch (packet.packetType) {
		case PacketTypeQuickRequest:
            [self sendQuickResponse:peerID inSession:session];
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

- (void)sendQuickResponse:(NSString *)requesterID inSession:(GKSession *)session {
    if (!dataSyncPackage) dataSyncPackage = [[DataSync alloc] init:_dataManager];
    NSArray *filteredTeamList = [dataSyncPackage getFilteredTeamList:SyncAllSavedHere];
    NSArray *filteredScoreList = [dataSyncPackage getFilteredResultsList:SyncAllSavedHere];
    NSUInteger nRecords = 0;
    if (filteredTeamList) nRecords = [filteredTeamList count];
    if (filteredScoreList) nRecords += [filteredScoreList count];
    Packet *packet = [Packet packetWithType:PacketTypeSendData];
    [packet setDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:nRecords], @"Records", nil]];
    [self sendPacketToClient:packet forClient:requesterID inSession:session];

//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    for (TeamData *team in filteredTeamList) {
        NSDictionary *teamDictionary = [teamUtilities packageTeamForXFer:team];
        Packet *teamPacket = [Packet packetWithType:PacketTypeTeamData];
        NSLog(@"send quick %@", teamDictionary);
        [teamPacket setDataDictionary:teamDictionary];
        [self sendPacketToClient:teamPacket forClient:requesterID inSession:session];
    }
    for (TeamScore *score in filteredScoreList) {
        NSDictionary *scoreDictionary = [scoreUtilities packageScoreForXFer:score];
        Packet *scorePacket = [Packet packetWithType:PacketTypeScoreData];
        [scorePacket setDataDictionary:scoreDictionary];
        [self sendPacketToClient:scorePacket forClient:requesterID inSession:session];
    }
//    });
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
    NSLog(@"Receiver = %@", receiverID);
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
    NSLog(@"wheeee received data");
    NSLog(@"decode from %@", packet.receiverId);
    NSDictionary *dataDictionary = packet.dataDictionary;
    NSLog(@"%@", dataDictionary);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"StartReceivingData" object:nil userInfo:dataDictionary]];
}

-(void)decodeReceivedData:(Packet *)packet {
    NSLog(@"wheeee received data");
    NSLog(@"decode type %d", packet.packetType);
    NSDictionary *dataDictionary = packet.dataDictionary;
    NSLog(@"%@", dataDictionary);
    if (!dataDictionary) {
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Empty Packet Received", @"Error", nil];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ReceivedData" object:nil userInfo:errorDictionary]];
        return;
    }
    if (packet.packetType == PacketTypeTeamData) {
        NSDictionary *teamDictionary = [teamUtilities unpackageTeamForXFer:dataDictionary];
        NSLog(@"decode received = %@", teamDictionary);
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

@end
