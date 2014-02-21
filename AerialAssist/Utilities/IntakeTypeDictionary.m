//
//  IntakeTypeDictionary.m
//  AerialAssist
//
//  Created by FRC on 2/21/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "IntakeTypeDictionary.h"

@implementation IntakeTypeDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:IntakeUnknown],
                         [NSNumber numberWithInt:IntakeNone],
                         [NSNumber numberWithInt:IntakeJVN],
                         [NSNumber numberWithInt:IntakeEveryBot],
                         [NSNumber numberWithInt:IntakeClamp],
                         [NSNumber numberWithInt:IntakeOther],
                         nil];
        objects = [NSArray arrayWithObjects:@"Unknown", @"None", @"JVN", @"EveryBot", @"Clamp", @"Other", nil];
        
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
    else return [NSNumber numberWithInt:IntakeUnknown];
}

-(NSArray *)getIntakeTypes {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
}

@end
