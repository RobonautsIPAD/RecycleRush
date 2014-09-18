//
//  TriStateDictionary.m
//  AerialAssist
//
//  Created by FRC on 8/7/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TriStateDictionary.h"

@implementation TriStateDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:TriUnknown],
                         [NSNumber numberWithInt:TriNo],
                         [NSNumber numberWithInt:TriYes],
                         nil];
        objects = [NSArray arrayWithObjects:@"Unknown", @"No", @"Yes", nil];
        
        dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
 NSLog(@"tri state = %@", dictionary);
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
    else return [NSNumber numberWithInt:TriUnknown];
}

-(NSArray *)getTriStateTypes {
    return objects;
}

@end
