//
//  enumerationDictionary.m
//  AerialAssist
//
//  Created by FRC on 10/3/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "EnumerationDictionary.h"
#import "FileIOMethods.h"

@implementation EnumerationDictionary

+(id)getKeyFromValue:(id)value forDictionary:(NSDictionary *)dictionary {
// Example Usage
    // text = [EnumerationDictionary getKeyFromValue:info.matchType forDictionary:matchTypeDictionary];

    NSArray *temp = [dictionary allKeysForObject:value];
    if ([temp count]) return [temp objectAtIndex:0];
    else return nil;
}

+(id)getValueFromKey:(id)key forDictionary:(NSDictionary *)dictionary {
//    valueObject = [EnumerationDictionary getValueFromKey:key forDictionary:allianceDictionary];
    return [dictionary objectForKey:key];
}

+(NSDictionary *)initializeBundledDictionary:(NSString *)fileName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return [FileIOMethods getDictionaryFromPListFile:plistPath];
}

@end
