//
//  PacketDealCards.m
//  Snap
//
//  Created by Ray Wenderlich on 5/27/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "PacketQuickRequest.h"
#import "NSData+RoboAdditions.h"

@implementation PacketQuickRequest

+ (id)packetWithQuickRequest:(NSDictionary *)quickRequest {
//	return [[[self class] alloc] initWithCards:cards startingWithPlayerPeerID:startingPeerID];
}
/*
- (id)initWithCards:(NSDictionary *)cards startingWithPlayerPeerID:(NSString *)startingPeerID
{
	if ((self = [super initWithType:PacketTypeDealCards]))
	{
		self.cards = cards;
		self.startingPeerID = startingPeerID;
	}
	return self;
}

+ (id)packetWithData:(NSData *)data
{
	size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    
	NSString *startingPeerID = [data rw_stringAtOffset:offset bytesRead:&count];
	offset += count;
    
	NSDictionary *cards = [[self class] cardsFromData:data atOffset:offset];
    
	return [[self class] packetWithCards:cards startingWithPlayerPeerID:startingPeerID];
}

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.startingPeerID];
	[self addCards:self.cards toPayload:data];
}
*/
@end