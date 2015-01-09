//
//  enumerationDictionary.h
//  RecycleRush
//
//  Created by FRC on 10/3/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnumerationDictionary : NSObject
+(id)getValueFromKey:(id)key forDictionary:(NSDictionary *)dictionary;
+(id)getKeyFromValue:(id)value forDictionary:(NSDictionary *)dictionary;
+(NSString *)getCaseInsensitiveKey:(NSString *)item forDictionary:(NSDictionary *)dictionary;
+(NSDictionary *)initializeBundledDictionary:(NSString *)fileName;

@end
