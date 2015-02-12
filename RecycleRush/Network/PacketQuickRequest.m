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

+ (id)packetWithQuickRequest:(NSString *)requesterID {
	return [[[self class] alloc] initWithRequesterID:requesterID];
}

-(id)initWithRequesterID:(NSString *)requesterID {
    if ((self = [super initWithType:PacketTypeQuickRequest]))  {
        self.requesterID = requesterID;
    }
    return self;
}

/*+ (id)packetWithData:(NSData *)data
{
	size_t offset = PACKET_HEADER_SIZE;
	size_t count;
    
	NSString *startingPeerID = [data rw_stringAtOffset:offset bytesRead:&count];
	offset += count;
    
	NSDictionary *cards = [[self class] cardsFromData:data atOffset:offset];
    
	return [[self class] packetWithCards:cards startingWithPlayerPeerID:startingPeerID];
}*/

- (void)addPayloadToData:(NSMutableData *)data
{
	[data rw_appendString:self.requesterID];
}

@end
