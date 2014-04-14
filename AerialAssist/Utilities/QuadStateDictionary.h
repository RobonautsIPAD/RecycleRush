//
//  QuadStateDictionary.h
//  AerialAssist
//
//  Created by FRC on 4/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuadStateDictionary : NSObject
-(NSString *)getString:(id) key;
-(id)getEnumValue:(NSString *) value;
-(NSArray *)getQuadTypes;

@end
