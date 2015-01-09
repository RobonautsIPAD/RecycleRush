//
//  enumerationDictionary.m
//  RecycleRush
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
    id value = [dictionary objectForKey:key];
    if (!value) {
        NSArray *allKeys = [dictionary allKeys];
        for (NSString *item in allKeys) {
            if ([key caseInsensitiveCompare:item] == NSOrderedSame ) {
                value = [dictionary objectForKey:item];
                break;
            }
        }
    }
    return value;
}

+(NSString *)getCaseInsensitiveKey:(NSString *)item forDictionary:(NSDictionary *)dictionary {
    //    valueObject = [EnumerationDictionary getValueFromKey:key forDictionary:allianceDictionary];
    NSString *foundKey = nil;
    id value = [dictionary objectForKey:item];
    if (value) {
        foundKey = item;
    }
    else {
        NSArray *allKeys = [dictionary allKeys];
        for (NSString *key in allKeys) {
            if ([item caseInsensitiveCompare:key] == NSOrderedSame ) {
                foundKey = key;
                break;
            }
        }
    }
    return foundKey;
}

+(NSDictionary *)initializeBundledDictionary:(NSString *)fileName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    return [FileIOMethods getDictionaryFromPListFile:plistPath];
}

@end
