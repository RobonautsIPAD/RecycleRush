//
//  Packet.h
//  RecycleRush
//
//  Created by FRC on 2/14/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

enum PacketType : NSInteger {
	PacketTypeSignInRequest = 0x64,    // server to client
	PacketTypeSignInResponse,          // client to server
    
	PacketTypeServerReady,             // server to client
	PacketTypeClientReady,             // client to server
    
	PacketTypeQuickRequest,            // requester to client
	PacketTypeQuickResponse,           // client to requester
    
    PacketTypeSendData,
	PacketTypeTeamRequest,
	PacketTypeTeamData,
    
	PacketTypeScoreRequest,
	PacketTypeScoreData,
    
	PacketTypeMatchRequest,
	PacketTypeMatchData,

    PacketTypeTournamentRequest,
	PacketTypeTournamentData,
};
typedef enum PacketType PacketType;

@interface Packet : NSObject
@property (nonatomic, strong) NSString *header;
@property (nonatomic, assign) PacketType packetType;
@property (nonatomic, assign) NSInteger packetNumber;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSString *receiverId;
@property (nonatomic, strong) NSDictionary *dataDictionary;

+ (id)packetWithType:(PacketType)packetType;

@end
