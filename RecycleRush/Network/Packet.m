//
//  Packet.m
//  RecycleRush
//
//  Created by FRC on 2/14/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "Packet.h"

@implementation Packet
+ (id)packetWithType:(PacketType)packetType
{
	return [[[self class] alloc] initWithType:packetType];
}

-(id)initWithType:(PacketType *)packetType {
    if ((self = [super init])) {
        self.packetNumber = -1;
        self.packetType = packetType;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _header = [decoder decodeObjectForKey:@"header"];
        _packetType = [decoder decodeIntegerForKey:@"packetType"];
        _packetNumber = [decoder decodeIntegerForKey:@"packetNumber"];
        _senderId = [decoder decodeObjectForKey:@"senderId"];
        _receiverId = [decoder decodeObjectForKey:@"receiverId"];
        _dataDictionary = [decoder decodeObjectForKey:@"dataDictionary"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_header forKey:@"header"];
    [encoder encodeInteger:_packetType forKey:@"packetType"];
    [encoder encodeInteger:_packetNumber forKey:@"packetNumber"];
    [encoder encodeObject:_senderId forKey:@"senderId"];
    [encoder encodeObject:_receiverId forKey:@"receiverId"];
    [encoder encodeObject:_dataDictionary forKey:@"dataDictionary"];
}

@end
