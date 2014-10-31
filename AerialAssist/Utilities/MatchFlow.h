//
//  MatchFlow.h
//  AerialAssist
//
//  Created by FRC on 10/27/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MatchFlow : NSObject
+(NSUInteger)getPreviousMatchType:(NSArray *)matchTypeList forCurrent:(NSString *)typeString;
+(NSUInteger)getNextMatchType:(NSArray *)matchTypeList forCurrent:(NSString *)typeString;

@end
