//
//  PacketDealCards.h
//  Snap
//
//  Created by Ray Wenderlich on 5/27/12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "Packet.h"

@class Player;

@interface PacketQuickRequest : Packet

@property (nonatomic, copy) NSString *requesterID;

+ (id)packetWithQuickRequest:(NSString *)requesterID;

@end
