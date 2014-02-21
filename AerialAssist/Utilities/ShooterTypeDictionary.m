//
//  ShooterTypeDictionary.m
//  AerialAssist
//
//  Created by FRC on 2/21/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "ShooterTypeDictionary.h"

@implementation ShooterTypeDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:ShooterUnknown],
                         [NSNumber numberWithInt:ShooterNone],
                         [NSNumber numberWithInt:ShooterWheel],
                         [NSNumber numberWithInt:ShooterPlunger],
                         [NSNumber numberWithInt:ShooterCatapult],
                         [NSNumber numberWithInt:ShooterKicker],
                         [NSNumber numberWithInt:ShooterOther],
                         nil];
        objects = [NSArray arrayWithObjects:@"Unknown", @"None", @"Wheel", @"Plunger", @"Catapult", @"Kicker", @"Other", nil];
        
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
    else return [NSNumber numberWithInt:ShooterUnknown];
}

-(NSArray *)getShooterTypes {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
}


@end

