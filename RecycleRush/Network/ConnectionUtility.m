//
//  ConnectionUtility.m
//  RecycleRush
//
//  Created by FRC on 1/18/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "ConnectionUtility.h"
#import "Packet.h"
//#import "PacketQuickResponse.h"
#import "DataSync.h"
#import "ExportScoreData.h"
#import "ScoreUtilities.h"
#import "SyncMethods.h"
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"

@implementation ConnectionUtility {
    int sendPacketNumber;
    DataSync *dataSyncPackage;
    ExportScoreData *exportScore;
}

- (id)init:(DataManager *)initManager {
	if ((self = [super init])) {
        _dataManager = initManager;
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
        case PacketTypeQuickResponse:
            [self decodeQuickResponse:packet];
        default:
            break;
    }
}

- (void)sendQuickResponse:(NSString *)requesterID inSession:(GKSession *)session {
    if (!dataSyncPackage) dataSyncPackage = [[DataSync alloc] init:_dataManager];
    if (!exportScore) exportScore = [[ExportScoreData alloc] init:_dataManager];
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSArray *filteredSendList = [dataSyncPackage getFilteredResultsList:SyncAllSavedHere];
        NSLog(@"count = %ul", [filteredSendList count]);
    // Package each one
    for (TeamScore *score in filteredSendList) {
        NSDictionary *scoreDictionary = [exportScore packageScoreForBluetooth:score];
        Packet *packet = [Packet packetWithType:PacketTypeQuickResponse];
        [packet setDataDictionary:scoreDictionary];
        [self sendPacketToClient:packet forClient:requesterID inSession:session];
    }
//    });
    // Send async
//    Packet *packet = [PacketSignInResponse packetWithPlayerName:_localPlayerName];
 
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

-(void)decodeQuickResponse:(Packet *)packet {
    NSLog(@"wheeee received data");
    NSLog(@"decode from %@", packet.receiverId);
    NSDictionary *myType = packet.dataDictionary;
    NSLog(@"%@", myType);
    ScoreUtilities *scoreUtilities = [[ScoreUtilities alloc] init:_dataManager];
    NSDictionary *scoreDictionary = [scoreUtilities unpackageScoreForBluetooth:myType];
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
