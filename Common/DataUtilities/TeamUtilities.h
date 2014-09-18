//
//  TeamUtilities.h
//  AerialAssist
//
//  Created by FRC on 8/7/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DataManager;
@class TeamData;

@interface TeamUtilities : NSObject
@property (nonatomic, strong) DataManager *dataManager;

-(id)initWithDataManager:(DataManager *)initManager;
-(void)createTeamFromFile:(NSString *)filePath;

@end
