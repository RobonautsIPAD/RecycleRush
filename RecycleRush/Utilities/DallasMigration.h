//
//  DallasMigration.h
//  RecycleRush
//
//  Created by FRC on 3/6/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataManager;

@interface DallasMigration : NSObject
@property (nonatomic, strong) DataManager *dataManager;
-(id)init:(DataManager *)initManager;
//-(void)dallasMigration1;
//-(void)dallasMigration2;
@end
