//
//  TunnelDictionary.h
//  AerialAssist
//
//  Created by FRC on 4/3/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TunnelDictionary : NSObject
-(NSString *)getString:(id) key;
-(id)getEnumValue:(NSString *) value;
-(NSArray *)getTunnelTypes;

@end
