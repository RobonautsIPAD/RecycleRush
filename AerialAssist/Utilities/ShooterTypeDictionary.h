//
//  ShooterTypeDictionary.h
//  AerialAssist
//
//  Created by FRC on 2/21/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShooterTypeDictionary : NSObject
-(NSString *)getString:(id) key;
-(id)getEnumValue:(NSString *) value;
-(NSArray *)getShooterTypes;

@end
