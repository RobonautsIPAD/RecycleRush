//
//  MatchDataInterfaces.h
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;
@class MatchData;

@interface MatchDataInterfaces : NSObject
@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NSDictionary *matchDataAttributes;

-(id)initWithDataManager:(DataManager *)initManager;
-(NSData *)packageMatchForXFer:(MatchData *)match;
-(MatchData *)unpackageMatchForXFer:(NSData *)xferData;

@end
