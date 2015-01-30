//
//  FieldDrawing.h
//  RecycleRush
//
//  Created by FRC on 1/30/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore;

@interface FieldDrawing : NSManagedObject

@property (nonatomic, retain) NSData * trace;
@property (nonatomic, retain) NSData * composite;
@property (nonatomic, retain) NSData * gameObjects;
@property (nonatomic, retain) TeamScore *fieldDrawing;
@property (nonatomic, retain) TeamScore *autonDrawing;

@end
