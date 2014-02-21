//
//  TrooleanDictionary.h
//  AerialAssist
//
//  Created by FRC on 2/21/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrooleanDictionary : NSObject
-(NSString *)getString:(id) key;
-(id)getEnumValue:(NSString *) value;
-(NSArray *)getTrooleanTypes;

@end
