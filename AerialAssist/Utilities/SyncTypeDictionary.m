//
//  SyncTypeDictionary.m
// Robonauts Scouting
//
//  Created by FRC on 12/19/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SyncTypeDictionary.h"

@implementation SyncTypeDictionary {
    NSDictionary *dictionary;
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:SyncTeams],
                         [NSNumber numberWithInt:SyncTournaments],
                         [NSNumber numberWithInt:SyncMatchResults],
                         [NSNumber numberWithInt:SyncMatchList],
                         nil];
        
        objects = [NSArray arrayWithObjects:@"Sync Team Data", @"Sync Tournament Names", @"Sync Match Results", @"Sync Match Schedule", nil];
        
        dictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	}
	return self;
}

-(NSString *)getSyncTypeString:(SyncType) key {
    NSString *result = [dictionary objectForKey:[NSNumber numberWithInt:key]];
    return result;
}

-(id)getSyncTypeEnum:(NSString *) value {
    NSArray *temp = [dictionary allKeysForObject:value];
    NSNumber *val = [temp objectAtIndex:0];
    return val;
}

-(NSArray *)getSyncTypes {
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
