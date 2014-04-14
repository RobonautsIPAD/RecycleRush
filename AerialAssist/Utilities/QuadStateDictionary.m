//
//  QuadStateDictionary.m
//  AerialAssist
//
//  Created by FRC on 4/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "QuadStateDictionary.h"

@implementation QuadStateDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:QuadUnknown],
                         [NSNumber numberWithInt:QuadNo],
                         [NSNumber numberWithInt:QuadYes],
                         [NSNumber numberWithInt:QuadMaybe],
                         nil];
        objects = [NSArray arrayWithObjects:@"Unknown", @"No", @"Yes", @"Maybe", nil];
        
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
    else return [NSNumber numberWithInt:QuadUnknown];
}

-(NSArray *)getQuadTypes {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
}


@end
