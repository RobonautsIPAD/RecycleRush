//
//  NumberEnumDictionary.m
//  AerialAssist
//
//  Created by FRC on 2/21/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "NumberEnumDictionary.h"

@implementation NumberEnumDictionary  {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:NumberUnknown],
                         [NSNumber numberWithInt:NOne],
                         [NSNumber numberWithInt:NTwo],
                         [NSNumber numberWithInt:NThree],
                         nil];
        objects = [NSArray arrayWithObjects:@"Unknown", @"One", @"Two", @"Three", nil];
        
        dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	}
	return self;
}

-(NSString *)getString:(id) key {
    if ([dictionary objectForKey:key]) {
        NSString *result = [dictionary objectForKey:key];
        if (!result) result = @"Unknown";
        return result;
    }
    else return nil;
}

-(id)getEnumValue:(NSString *) value {
    NSArray *temp = [dictionary allKeysForObject:value];
    if ([temp count]) return [temp objectAtIndex:0];
    else return [NSNumber numberWithInt:NumberUnknown];
}

-(NSArray *)getNumberTypes {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
}



@end
