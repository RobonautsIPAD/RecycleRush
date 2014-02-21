//
//  DriveTypeDictionary.m
// Robonauts Scouting
//
//  Created by FRC on 10/10/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "DriveTypeDictionary.h"

@implementation DriveTypeDictionary {
    NSDictionary *dictionary; 
    NSArray *objects;
}

- (id)init {
	if ((self = [super init])) {
        NSArray *keys = [NSArray arrayWithObjects:[NSNumber numberWithInt:DriveUnknown],
                         [NSNumber numberWithInt:Mech],
                         [NSNumber numberWithInt:Omni],
                         [NSNumber numberWithInt:Swerve],
                         [NSNumber numberWithInt:Traction],
                         [NSNumber numberWithInt:Multi],
                         [NSNumber numberWithInt:Tread],
                         [NSNumber numberWithInt:Butterfly],
                         [NSNumber numberWithInt:OtherDrive],
                         nil];
        objects = [NSArray arrayWithObjects:@"Unknown", @"Mech", @"Omni", @"Swerve", @"Traction", @"Multi", @"Tread", @"Butterfly", @"Other", nil];
        
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
    return @"Unknown";
}

-(id)getEnumValue:(NSString *) value {
    NSArray *temp = [dictionary allKeysForObject:value];
    if ([temp count]) return [temp objectAtIndex:0];
    else return [NSNumber numberWithInt:DriveUnknown];
}

-(NSArray *)getDriveTypes {
    return objects;
}

- (void)dealloc
{
    dictionary = nil;
    objects = nil;
#ifdef TEST_MODE
//	NSLog(@"dealloc %@", self);
#endif
}
@end
