//
//  Packet.h
//  Snap
//
//  Created by Ray Wenderlich on 5/25/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

const size_t PACKET_HEADER_SIZE;

typedef enum
{
	PacketTypeSignInRequest = 0x64,    // server to client
	PacketTypeSignInResponse,          // client to server
    
	PacketTypeServerReady,             // server to client
	PacketTypeClientReady,             // client to server
    
	PacketTypeQuickRequest,            // server to client
	PacketTypeClientQuickData,         // client to server
    
	PacketTypeRequest,                 // server to client
	PacketTypeClientSyncData,          // client to server
    
	PacketTypePlayerShouldSnap,        // client to server
	PacketTypePlayerCalledSnap,        // server to client
    
	PacketTypeOtherClientQuit,         // server to client
	PacketTypeServerQuit,              // server to client
	PacketTypeClientQuit,              // client to server
}
PacketType;

@interface Packet : NSObject

@property (nonatomic, assign) PacketType packetType;
@property (nonatomic, assign) int packetNumber;

+ (id)packetWithType:(PacketType)packetType;
- (id)initWithType:(PacketType)packetType;
+ (id)packetWithData:(NSData *)data;
+ (NSDictionary *)cardsFromData:(NSData *)data atOffset:(size_t) offset;
- (void)addCards:(NSDictionary *)cards toPayload:(NSMutableData *)data;

- (NSData *)data;

@end
