//
//  FieldPhoto.h
//  RecycleRush
//
//  Created by FRC on 2/7/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore;

@interface FieldPhoto : NSManagedObject

@property (nonatomic, retain) NSData * paper;
@property (nonatomic, retain) TeamScore *teamScore;

@end
