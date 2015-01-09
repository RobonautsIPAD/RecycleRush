//
//  FieldDrawing.h
//  RecycleRush
//
//  Created by FRC on 1/8/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore;

@interface FieldDrawing : NSManagedObject

@property (nonatomic, retain) NSData * trace;
@property (nonatomic, retain) TeamScore *fieldDrawing;

@end
