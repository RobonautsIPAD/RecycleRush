//
//  Photo.h
//  AerialAssist
//
//  Created by FRC on 3/9/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * fullImage;
@property (nonatomic, retain) NSString * thumbNail;
@property (nonatomic, retain) TeamData *teamPhoto;

@end
