//
//  SyncOptionDictionary.m
// Robonauts Scouting
//
//  Created by FRC on 12/19/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SyncOptionDictionary.h"

@implementation SyncOptionDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:SyncAll],
                         [NSNumber numberWithInt:SyncAllSavedHere],
                         [NSNumber numberWithInt:SyncAllSavedSince],
                         nil];
        
        objects = [NSArray arrayWithObjects:@"Sync All", @"Sync All Saved on this Device", @"Sync All Since Last Sync", nil];
        
        dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	}
	return self;
}

-(NSString *)getSyncOptionString:(SyncOptions) key {
    NSString *result = [dictionary objectForKey:[NSNumber numberWithInt:key]];
    return result;
}

-(id)getSyncOptionEnum:(NSString *) value {
    NSArray *temp = [dictionary allKeysForObject:value];
    NSNumber *val = [temp objectAtIndex:0];
    return val;
}

-(NSArray *)getSyncOptions {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
#ifdef TEST_MODE
	NSLog(@"dealloc %@", self);
#endif
}


@end
