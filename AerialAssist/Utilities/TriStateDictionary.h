//
//  TriStateDictionary.h
//  AerialAssist
//
//  Created by FRC on 8/7/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TriStateDictionary : NSObject
-(NSString *)getString:(id) key;
-(id)getEnumValue:(NSString *) value;
-(NSArray *)getTriStateTypes;


@end
